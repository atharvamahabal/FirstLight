import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/data.dart';
import '../widgets/common.dart';

class SpinScreen extends StatefulWidget {
  final void Function(int xpEarned) onTaskDone;
  final void Function(int count) onConfetti;
  final void Function(int xp) onAddXp;
  const SpinScreen({
    super.key,
    required this.onTaskDone,
    required this.onConfetti,
    required this.onAddXp,
  });

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _currentAngle = 0;
  bool _spinning = false;
  WheelSegment? _result;
  bool _showResult = false;

  // Timer state
  int _timerSecondsLeft = 0;
  Timer? _timer;
  bool _timerRunning = false;
  bool _timerDone = false;

  // Breathing state (for breathe tasks)
  bool _breatheMode = false;
  int _breathePhase = 0; // 0=in,1=hold,2=out
  int _breatheCount = 0;
  String _breatheText = '';

  // Text input
  final TextEditingController _textCtrl = TextEditingController();
  bool _textSubmitted = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _timer?.cancel();
    _textCtrl.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning) return;
    _timer?.cancel();
    setState(() {
      _spinning = true;
      _showResult = false;
      _timerRunning = false;
      _timerDone = false;
      _breatheMode = false;
      _textSubmitted = false;
      _textCtrl.clear();
    });

    final rng = Random();
    // Pick random segment directly
    final randomIdx = rng.nextInt(wheelSegments.length);
    final extraSpins = (rng.nextDouble() * 4 + 5) * 2 * pi;
    final segArc = (2 * pi) / wheelSegments.length;
    // Target angle that lands on randomIdx
    final targetOffset = -(randomIdx * segArc + segArc / 2 + pi / 2);
    final rounds = (extraSpins / (2 * pi)).ceil();
    final targetAngle = rounds * 2 * pi + targetOffset;

    final startAngle = _currentAngle % (2 * pi);
    _anim = Tween<double>(begin: startAngle, end: startAngle + (targetAngle - startAngle).abs() + extraSpins)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuart));
    _ctrl.reset();
    _ctrl.forward().then((_) {
      _currentAngle = _anim.value;
      _computeResult();
      setState(() {
        _spinning = false;
        _showResult = true;
      });
      widget.onConfetti(60); // rain confetti on spin finish
    });
  }

  void _computeResult() {
    final arc = (2 * pi) / wheelSegments.length;
    final normalised =
        ((-_currentAngle - pi / 2) % (2 * pi) + (2 * pi)) % (2 * pi);
    final idx = (normalised / arc).floor() % wheelSegments.length;
    setState(() {
      _result = wheelSegments[idx];
      _timerSecondsLeft = _result!.timerSeconds ?? 0;
      _breatheMode = _result!.label.toLowerCase().contains('breathe') ||
          _result!.label.toLowerCase().contains('meditat');
    });
  }

  void _startTimer() {
    if (_result == null || _timerSecondsLeft <= 0) return;
    setState(() => _timerRunning = true);
    if (_breatheMode) _startBreatheGuide();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_timerSecondsLeft > 0) {
          _timerSecondsLeft--;
        } else {
          _timerRunning = false;
          _timerDone = true;
          t.cancel();
          if (_breatheMode) setState(() => _breatheText = '✦ Complete! ✦');
          widget.onAddXp(_result!.xp);
          widget.onConfetti(40);
        }
      });
    });
  }

  // Breathing phases: 10s in → 5s hold → 5s out × 4 sets
  static const _breathPhases = [
    (10, 'Breathe IN 🌬️'),
    (5,  'Hold 🫁'),
    (5,  'Breathe OUT 💨'),
  ];

  void _startBreatheGuide() {
    _breatheCount = 0;
    _breathePhase = 0;
    _runBreathePhase();
  }

  void _runBreathePhase() {
    if (!_timerRunning || !mounted) return;
    final (dur, text) = _breathPhases[_breathePhase];
    setState(() => _breatheText = text);
    Future.delayed(Duration(seconds: dur), () {
      if (!_timerRunning || !mounted) return;
      _breathePhase = (_breathePhase + 1) % 3;
      if (_breathePhase == 0) {
        _breatheCount++;
        if (_breatheCount >= 4) return; // 4 sets done
      }
      _runBreathePhase();
    });
  }

  String _formatTimer(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _markDone() {
    widget.onTaskDone(_result?.xp ?? 10);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Challenge',
              style: TextStyle(
                  fontSize: 11, letterSpacing: 3,
                  color: AppColors.textMuted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          // Single-line title
          const Text('Spin the Wheel 🎡',
              style: TextStyle(
                  fontFamily: 'Syne', fontSize: 28,
                  fontWeight: FontWeight.w800, height: 1.1)),
          const SizedBox(height: 22),

          // Wheel
          Center(
            child: GestureDetector(
              onTap: _spinning ? null : _spin,
              child: SizedBox(
                width: 280,
                height: 300,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 0,
                      child: CustomPaint(
                          size: const Size(20, 22), painter: _PointerPainter()),
                    ),
                    Positioned(
                      top: 18,
                      child: AnimatedBuilder(
                        animation: _spinning
                            ? _anim
                            : AlwaysStoppedAnimation(_currentAngle),
                        builder: (_, __) => CustomPaint(
                          size: const Size(260, 260),
                          painter: _WheelPainter(
                            angle: _spinning ? _anim.value : _currentAngle,
                            isSpinning: _spinning,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Center(
            child: Text(
              _spinning ? 'SPINNING...' : 'TAP THE WHEEL TO SPIN',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textDim, letterSpacing: 1.5),
            ),
          ),
          const SizedBox(height: 18),

          // Result card
          AnimatedOpacity(
            opacity: _showResult ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: AnimatedSlide(
              offset: _showResult ? Offset.zero : const Offset(0, 0.1),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: _result == null
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        GlassCard(
                          bgColor: Color(_result!.color).withOpacity(0.07),
                          borderColor: Color(_result!.color).withOpacity(0.25),
                          child: Row(
                            children: [
                              Text(_result!.emoji,
                                  style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_result!.category,
                                        style: const TextStyle(
                                            fontSize: 9, letterSpacing: 2,
                                            color: AppColors.textMuted)),
                                    const SizedBox(height: 3),
                                    Text(_result!.label,
                                        style: const TextStyle(
                                            fontFamily: 'Syne', fontSize: 16,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              // XP badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.amber.withOpacity(0.3)),
                                ),
                                child: Text('+${_result!.xp} XP',
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.amber,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),

                        // Timer section
                        if (_result!.timerSeconds != null) ...[
                          const SizedBox(height: 14),
                          _buildTimerSection(),
                        ],

                        // Breathing guide
                        if (_breatheMode && _timerRunning) ...[
                          const SizedBox(height: 12),
                          _buildBreatheGuide(),
                        ],

                        // Text input
                        if (_result!.hasTextInput) ...[
                          const SizedBox(height: 14),
                          _buildTextInput(),
                        ],

                        // Mark done button
                        if (_timerDone ||
                            (_result!.timerSeconds == null && !_result!.hasTextInput)) ...[
                          const SizedBox(height: 14),
                          SecondaryButton(
                            label: '✓  Mark as Done  (+${_result!.xp} XP)',
                            onTap: _markDone,
                          ),
                        ],
                        if (_textSubmitted && _result!.hasTextInput) ...[
                          const SizedBox(height: 14),
                          SecondaryButton(
                            label: '✓  Mark as Done  (+${_result!.xp} XP)',
                            onTap: _markDone,
                          ),
                        ],
                      ],
                    ),
            ),
          ),

          // Upcoming segments (greyed preview)
          const SizedBox(height: 28),
          const Text('MORE CHALLENGES',
              style: TextStyle(
                  fontSize: 10, letterSpacing: 2.5,
                  color: AppColors.textDim, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...wheelSegments.take(6).map((s) => _GreySegmentRow(segment: s)),
          const SizedBox(height: 8),
          const Center(
            child: Text('• • •',
                style: TextStyle(color: AppColors.textDim, letterSpacing: 6, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return GlassCard(
      bgColor: AppColors.purple.withOpacity(0.06),
      borderColor: AppColors.purple.withOpacity(0.2),
      child: Column(
        children: [
          Text(
            _formatTimer(_timerSecondsLeft),
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: AppColors.purple,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          if (!_timerRunning && !_timerDone)
            GestureDetector(
              onTap: _startTimer,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.purpleDark, AppColors.purple]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.purple.withOpacity(0.35),
                        blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Text('▶  START TIMER',
                    style: TextStyle(
                        fontFamily: 'Syne', fontSize: 13,
                        fontWeight: FontWeight.w700, color: Colors.white,
                        letterSpacing: 1)),
              ),
            ),
          if (_timerRunning)
            const Text('RUNNING... XP awarded on completion',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          if (_timerDone)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✦ ', style: TextStyle(color: AppColors.mint, fontSize: 14)),
                Text('Done! +${_result!.xp} XP awarded',
                    style: const TextStyle(
                        fontFamily: 'Syne', fontSize: 13,
                        fontWeight: FontWeight.w700, color: AppColors.mint)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBreatheGuide() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: GlassCard(
        key: ValueKey(_breatheText),
        bgColor: AppColors.mint.withOpacity(0.05),
        borderColor: AppColors.mint.withOpacity(0.2),
        child: Center(
          child: Text(
            _breatheText,
            style: const TextStyle(
                fontFamily: 'Syne', fontSize: 20,
                fontWeight: FontWeight.w700, color: AppColors.mint),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Column(
      children: [
        TextField(
          controller: _textCtrl,
          maxLines: 3,
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Type your thought here...',
            hintStyle: const TextStyle(color: AppColors.textDim, fontSize: 14),
            filled: true,
            fillColor: AppColors.glass,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.purple.withOpacity(0.5), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.purple.withOpacity(0.3), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.purple, width: 2),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 10),
        if (!_textSubmitted)
          SecondaryButton(
            label: '✓  Submit Thought  (+${_result!.xp} XP)',
            onTap: () {
              if (_textCtrl.text.trim().isEmpty) return;
              setState(() => _textSubmitted = true);
              widget.onAddXp(_result!.xp);
              widget.onConfetti(20);
            },
          ),
        if (_textSubmitted)
          const Text('✦  Thought saved!',
              style: TextStyle(
                  color: AppColors.mint, fontFamily: 'Syne',
                  fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ── Greyed upcoming segment row ────────────────────────────────────────────────
class _GreySegmentRow extends StatelessWidget {
  final WheelSegment segment;
  const _GreySegmentRow({required this.segment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: 0.3,
        child: Row(
          children: [
            Text(segment.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(segment.label,
                  style: const TextStyle(
                      fontFamily: 'Syne', fontSize: 13,
                      fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            ),
            Text(segment.category,
                style: const TextStyle(
                    fontSize: 9, letterSpacing: 1.5,
                    color: AppColors.textDim)),
          ],
        ),
      ),
    );
  }
}

// ── Wheel Painter ──────────────────────────────────────────────────────────────
class _WheelPainter extends CustomPainter {
  final double angle;
  final bool isSpinning;
  _WheelPainter({required this.angle, this.isSpinning = false});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 2;
    final arc = (2 * pi) / wheelSegments.length;

    for (int i = 0; i < wheelSegments.length; i++) {
      final seg = wheelSegments[i];
      final start = angle + i * arc;
      final segColor = Color(seg.color);

      final fillPaint = Paint()..color = segColor.withOpacity(0.18);
      canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: r), start, arc, true, fillPaint);

      final borderPaint = Paint()
        ..color = segColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: r), start, arc, true, borderPaint);

      final mid = start + arc / 2;
      final ex = cx + cos(mid) * r * 0.65;
      final ey = cy + sin(mid) * r * 0.65;
      final tp = TextPainter(
        text: TextSpan(text: seg.emoji, style: const TextStyle(fontSize: 20)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(ex - tp.width / 2, ey - tp.height / 2));

      final words = seg.label.split(' ');
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(mid);
      canvas.translate(r * 0.35, 0);
      canvas.rotate(pi / 2);
      for (int wi = 0; wi < words.length; wi++) {
        final wtp = TextPainter(
          text: TextSpan(
            text: words[wi],
            style: const TextStyle(
                fontSize: 9, fontWeight: FontWeight.w600,
                color: Color(0xB3FFFFFF)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final dy = (wi - (words.length - 1) / 2) * 11;
        wtp.paint(canvas, Offset(-wtp.width / 2, dy - wtp.height / 2));
      }
      canvas.restore();
    }

    // Center spin button — elevated pill look
    final btnShadow = Paint()
      ..color = AppColors.purple.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(cx, cy), 28, btnShadow);

    final btnBg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9B7FF4), Color(0xFF7C3AED)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 28));
    canvas.drawCircle(Offset(cx, cy), 28, btnBg);

    final btnBorder = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), 28, btnBorder);

    // Inner highlight
    final highlight = Paint()
      ..color = Colors.white.withOpacity(0.12);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy - 4), radius: 18),
        pi, pi, false, highlight);

    final starPainter = TextPainter(
      text: const TextSpan(
          text: '▶', style: TextStyle(fontSize: 14, color: Colors.white)),
      textDirection: TextDirection.ltr,
    )..layout();
    starPainter.paint(
        canvas, Offset(cx - starPainter.width / 2 + 1, cy - starPainter.height / 2));

    // Outer glow ring
    final glowPaint = Paint()
      ..color = AppColors.purple.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(cx, cy), r + 2, glowPaint);
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.angle != angle;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.amber
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
    paint.maskFilter = null;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
