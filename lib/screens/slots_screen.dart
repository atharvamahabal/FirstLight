import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/data.dart';
import '../widgets/common.dart';

class SlotsScreen extends StatefulWidget {
  final void Function(int count) onConfetti;
  final VoidCallback? onJackpot;
  const SlotsScreen({super.key, required this.onConfetti, this.onJackpot});

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen>
    with TickerProviderStateMixin {
  bool _spinning = false;
  List<int> _displayed = [0, 1, 2];
  List<int>? _results;
  String? _comboText;
  bool _isJackpot = false;
  bool _showCombo = false;
  double _dragOffset = 0.0;

  // Lever animation
  late AnimationController _leverCtrl;
  late Animation<double> _leverAnim;

  final List<ScrollController> _scrollCtrls =
      List.generate(3, (_) => ScrollController());

  @override
  void initState() {
    super.initState();
    _leverCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _leverAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _leverCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _leverCtrl.dispose();
    for (final c in _scrollCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _pull() async {
    if (_spinning) return;
    setState(() {
      _spinning = true;
      _showCombo = false;
      _results = null;
    });

    final rng = Random();
    final picks = List.generate(3, (_) => rng.nextInt(slotSymbols.length));

    const itemH = 80.0;
    final futures = List.generate(3, (r) async {
      final targetIndex = picks[r] + slotSymbols.length * 4;
      if (_scrollCtrls[r].hasClients) {
        await _scrollCtrls[r].animateTo(
          targetIndex * itemH,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
        );
      }
      if (!mounted) return;
      setState(() => _displayed[r] = picks[r]);
    });
    await Future.wait(futures);

    await Future.delayed(const Duration(milliseconds: 300));
    _computeCombo(picks);
    setState(() {
      _spinning = false;
      _results = picks;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _showCombo = true);

    if (_isJackpot) {
      widget.onConfetti(80);
      widget.onJackpot?.call();
    }
  }

  void _computeCombo(List<int> picks) {
    final names = picks.map((i) => slotNames[i]).toList();
    _isJackpot = picks[0] == picks[1] && picks[1] == picks[2];
    final key1 = names.join('+');
    final key2 = (List.from(names)..sort()).join('+');
    _comboText = slotCombos[key1] ??
        slotCombos[key2] ??
        'Focus on ${names[0]} + ${names[1]} today!\nEg: Pick one small action for each and do it in the morning 💪';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Life Slots',
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 3,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('777 Challenge 🎰',
              style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.1)),
          const SizedBox(height: 22),

          // Slot machine + lever
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Slot machine
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: AppColors.amber.withOpacity(0.22)),
                  ),
                  child: Column(
                    children: [
                      const Text('◆  PULL FOR TODAY\'S COMBO  ◆',
                          style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 3,
                              color: AppColors.amber,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Row(children: List.generate(3, (r) => _buildReel(r))),
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _spinning
                              ? 'Spinning...'
                              : _results == null
                                  ? 'Your life combo awaits...'
                                  : _isJackpot
                                      ? '🎉 JACKPOT! ${slotNames[_results![0]].toUpperCase()}!'
                                      : '${slotNames[_results![0]]} × ${slotNames[_results![1]]} × ${slotNames[_results![2]]}',
                          key: ValueKey(
                              _results.toString() + _spinning.toString()),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isJackpot && !_spinning
                                ? AppColors.amber
                                : AppColors.textMuted,
                            shadows: _isJackpot && !_spinning
                                ? [
                                    Shadow(
                                        color: AppColors.amber, blurRadius: 12)
                                  ]
                                : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Visual Lever
              _buildLever(),
            ],
          ),

          const SizedBox(height: 20),

          // Combo card
          AnimatedOpacity(
            opacity: _showCombo ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: AnimatedSlide(
              offset: _showCombo ? Offset.zero : const Offset(0, 0.1),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: _comboText == null
                  ? const SizedBox.shrink()
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.amber.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TODAY\'S CHALLENGE',
                              style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 2,
                                  color: AppColors.amber)),
                          const SizedBox(height: 8),
                          Text(_comboText!,
                              style: const TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5)),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReel(int r) {
    const itemH = 80.0;
    final items = List.generate(
        slotSymbols.length * 6, (i) => slotSymbols[i % slotSymbols.length]);
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: r == 0 ? 0 : 5, right: r == 2 ? 0 : 5),
        height: 115,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        clipBehavior: Clip.hardEdge,
        child: ListView.builder(
          controller: _scrollCtrls[r],
          itemCount: items.length,
          itemExtent: itemH,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, i) => SizedBox(
            height: itemH,
            child: Center(
              child: Text(
                items[i],
                style: const TextStyle(fontSize: 30, height: 1.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLever() {
    const maxDrag = 70.0;
    const triggerThreshold = 50.0;
    const trackHeight = 130.0;
    const ballSize = 36.0;
    const stickHeight = 60.0;

    return GestureDetector(
      onVerticalDragUpdate: _spinning
          ? null
          : (details) {
              setState(() {
                _dragOffset =
                    (_dragOffset + details.delta.dy).clamp(0.0, maxDrag);
                _leverCtrl.value = _dragOffset / maxDrag;
              });
            },
      onVerticalDragEnd: _spinning
          ? null
          : (details) {
              if (_dragOffset >= triggerThreshold) {
                _leverCtrl.forward().then((_) async {
                  await Future.delayed(const Duration(milliseconds: 150));
                  _leverCtrl.reverse();
                  setState(() => _dragOffset = 0.0);
                  _pull();
                });
              } else {
                _leverCtrl.reverse();
                setState(() => _dragOffset = 0.0);
              }
            },
      child: SizedBox(
        width: 44,
        height: 200,
        child: AnimatedBuilder(
          animation: _leverAnim,
          builder: (_, __) {
            final pull = _leverAnim.value; // 0.0 = top, 1.0 = bottom

            // How far the ball+stick group has traveled down the track
            // Ball starts aligned with the top of the track, and ends aligned with the bottom.
            final travel = pull * trackHeight;
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                // Track groove — fixed position
                Positioned(
                  top: ballSize / 2, // starts at center of ball when at top
                  child: Container(
                    width: 12,
                    height: trackHeight,
                    decoration: BoxDecoration(
                      color: AppColors.glass,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                  ),
                ),
                // Inner track glow line
                Positioned(
                  top: ballSize / 2 + 4,
                  child: Container(
                    width: 3,
                    height: trackHeight - 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Stick — attached below ball, moves with it
                // Positioned(
                //   top: travel + ballSize - 4,
                //   child: Container(
                //     width: 4,
                //     height: stickHeight,
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //         begin: Alignment.topCenter,
                //         end: Alignment.bottomCenter,
                //         colors: [
                //           AppColors.amber,
                //           AppColors.amberDark,
                //         ],
                //       ),
                //       borderRadius: BorderRadius.circular(2),
                //       boxShadow: [
                //         BoxShadow(
                //           color: AppColors.amber.withOpacity(0.5),
                //           blurRadius: 8,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // Ball handle — moves down the track
                Positioned(
                  top: travel,
                  child: Container(
                    width: ballSize,
                    height: ballSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        center: Alignment(-0.3, -0.3),
                        colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.amber
                              .withOpacity(_spinning ? 0.2 : 0.7),
                          blurRadius: _spinning ? 4 : 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Text('🎰', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
                // Pull label
                Positioned(
                  bottom: 0,
                  child: Column(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: _spinning
                            ? AppColors.textDim
                            : AppColors.amber.withOpacity(0.8),
                      ),
                      Text(
                        _spinning ? '...' : 'PULL',
                        style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 1.5,
                          color:
                              _spinning ? AppColors.textDim : AppColors.amber,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
