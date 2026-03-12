import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HomeScreen extends StatefulWidget {
  final int streak;
  final int xp;
  final int tasksCompleted;
  final VoidCallback onSpin;
  final void Function(int count) onConfetti;
  final VoidCallback onReset;

  const HomeScreen({
    super.key,
    required this.streak,
    required this.xp,
    required this.tasksCompleted,
    required this.onSpin,
    required this.onConfetti,
    required this.onReset,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late String _timeStr;
  late String _dateStr;
  String _petEmoji = '🐣';
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _updateTime());
    _floatCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -10)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timeStr = DateFormat('hh:mm a').format(now);
      _dateStr = DateFormat('EEEE · MMM d').format(now).toUpperCase();
    });
  }

  void _tapPet() {
    final reactions = ['😄', '🥳', '💪', '✨', '🎉', '💫'];
    final r = reactions[DateTime.now().millisecond % reactions.length];
    setState(() => _petEmoji = r);
    widget.onConfetti(5);
    Future.delayed(const Duration(milliseconds: 800),
        () => setState(() => _petEmoji = '🐣'));
  }

  @override
  void dispose() {
    _timer.cancel();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 100),
      child: Column(
        children: [
          // Reset button — top right
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: widget.onReset,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        size: 13, color: AppColors.textMuted),
                    SizedBox(width: 4),
                    Text('Reset',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Clock
          GradientText(
            _timeStr,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppColors.amber],
              stops: [0.3, 1.0],
            ),
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 80,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: -3,
            ),
          ),
          Text(_dateStr,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted, letterSpacing: 2)),
          const SizedBox(height: 24),

          // Pet
          GestureDetector(
            onTap: _tapPet,
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.3),
                    duration: const Duration(seconds: 3),
                    curve: Curves.easeInOut,
                    builder: (_, scale, __) => Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            AppColors.purple.withOpacity(0.35),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),
                    onEnd: () => setState(() {}),
                  ),
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: Text(_petEmoji,
                          style: const TextStyle(fontSize: 68, shadows: [
                            Shadow(
                                color: Color(0x809B7FF4),
                                blurRadius: 24,
                                offset: Offset(0, 10))
                          ])),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          const Text('GOOD MORNING',
              style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 2)),
          const SizedBox(height: 4),
          GradientText(
            'Rise & Conquer ✦',
            gradient: const LinearGradient(
                colors: [AppColors.text, AppColors.purple], stops: [0.6, 1.0]),
            style: const TextStyle(
                fontFamily: 'Syne', fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              _StatPill(
                  value: '${widget.streak}',
                  label: '🔥 Streak',
                  valueColor: AppColors.amber),
              const SizedBox(width: 12),
              _StatPill(
                  value: '${widget.xp}',
                  label: '⚡ XP',
                  valueColor: AppColors.purple),
              const SizedBox(width: 12),
              _StatPill(
                  value: '${widget.tasksCompleted}',
                  label: '✅ Tasks',
                  valueColor: AppColors.mint),
            ],
          ),
          const SizedBox(height: 28),

          // Only Spin Your Day button
          PrimaryButton(label: '✦  SPIN YOUR DAY', onTap: widget.onSpin),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  const _StatPill(
      {required this.value, required this.label, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        radius: BorderRadius.circular(14),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: valueColor)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 9, color: AppColors.textMuted, letterSpacing: 1),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
