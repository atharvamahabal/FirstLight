import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/data.dart';
import '../widgets/common.dart';

class RitualScreen extends StatefulWidget {
  final void Function(int count) onConfetti;
  final void Function(int xp) onAddXp;
  final void Function(RitualItem item)? onTaskDone;
  const RitualScreen({
    super.key,
    required this.onConfetti,
    required this.onAddXp,
    this.onTaskDone,
  });

  @override
  State<RitualScreen> createState() => _RitualScreenState();
}

class _RitualScreenState extends State<RitualScreen> {
  late List<RitualItem> _rituals;
  int? _activeTimerIndex;
  int _timerSecondsLeft = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _rituals = defaultRituals
        .map((r) => RitualItem(
              emoji: r.emoji,
              name: r.name,
              duration: r.duration,
              timerSeconds: r.timerSeconds,
              xp: r.xp,
            ))
        .toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _doneCount => _rituals.where((r) => r.done).length;
  double get _progress => _rituals.isEmpty ? 0 : _doneCount / _rituals.length;

  void _toggle(int i) {
    final item = _rituals[i];
    if (item.done) {
      setState(() => item.done = false);
      return;
    }
    // If has timer and not currently running, start timer
    if (item.timerSeconds != null && _activeTimerIndex != i) {
      _startTimer(i);
      return;
    }
    // If no timer or timer done
    _complete(i);
  }

  void _startTimer(int i) {
    _timer?.cancel();
    setState(() {
      _activeTimerIndex = i;
      _timerSecondsLeft = _rituals[i].timerSeconds!;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_timerSecondsLeft > 0) {
          _timerSecondsLeft--;
        } else {
          t.cancel();
          _activeTimerIndex = null;
          _complete(i);
        }
      });
    });
  }

  void _complete(int i) {
    setState(() => _rituals[i].done = true);
    widget.onConfetti(50); // rain confetti
    final cb = widget.onTaskDone;
    if (cb != null) {
      cb(_rituals[i]);
    } else {
      widget.onAddXp(_rituals[i].xp);
    }
    if (_doneCount == _rituals.length) {
      widget.onConfetti(80);
    }
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Morning Ritual',
              style: TextStyle(fontSize: 11, letterSpacing: 3,
                  color: AppColors.textMuted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Your Flow Today 🌅',
              style: TextStyle(fontFamily: 'Syne', fontSize: 28,
                  fontWeight: FontWeight.w800, height: 1.1)),
          const SizedBox(height: 20),

          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_doneCount / ${_rituals.length} done',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1)),
              const Text('18 mins total',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(builder: (context, c) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 5,
                width: double.infinity,
                color: Colors.white.withOpacity(0.07),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    width: c.maxWidth * _progress,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.purple, AppColors.mint]),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.7), blurRadius: 12)],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 18),

          // Active tasks
          Expanded(
            child: ListView(
              children: [
                ..._rituals.asMap().entries.map((e) {
                  final i = e.key;
                  final item = e.value;
                  final isTimerActive = _activeTimerIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RitualTile(
                      item: item,
                      isTimerActive: isTimerActive,
                      timerSecondsLeft: isTimerActive ? _timerSecondsLeft : 0,
                      onTap: () => _toggle(i),
                      fmt: _fmt,
                    ),
                  );
                }),

                const SizedBox(height: 16),
                // Upcoming (greyed)
                const Text('COMING UP',
                    style: TextStyle(fontSize: 10, letterSpacing: 2.5,
                        color: AppColors.textDim, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                ...upcomingRituals.take(3).map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Opacity(
                        opacity: 0.28,
                        child: Row(
                          children: [
                            Text(r.emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(r.name,
                                    style: const TextStyle(
                                        fontFamily: 'Syne', fontSize: 13,
                                        color: AppColors.textMuted))),
                            Text(r.duration,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textDim)),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 8),
                const Center(
                  child: Text('• • •',
                      style: TextStyle(
                          color: AppColors.textDim, letterSpacing: 6, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RitualTile extends StatelessWidget {
  final RitualItem item;
  final bool isTimerActive;
  final int timerSecondsLeft;
  final VoidCallback onTap;
  final String Function(int) fmt;

  const _RitualTile({
    required this.item,
    required this.isTimerActive,
    required this.timerSecondsLeft,
    required this.onTap,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: item.done
              ? AppColors.mint.withOpacity(0.05)
              : isTimerActive
                  ? AppColors.purple.withOpacity(0.07)
                  : AppColors.glass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.done
                ? AppColors.mint.withOpacity(0.25)
                : isTimerActive
                    ? AppColors.purple.withOpacity(0.35)
                    : AppColors.glassBorder,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.done ? AppColors.mint : Colors.transparent,
                    border: Border.all(
                      color: item.done ? AppColors.mint : AppColors.glassBorder,
                      width: 2,
                    ),
                    boxShadow: item.done
                        ? [BoxShadow(color: AppColors.mint.withOpacity(0.4), blurRadius: 10)]
                        : null,
                  ),
                  child: item.done
                      ? const Icon(Icons.check, size: 14, color: Color(0xFF0A1A12))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: item.done ? AppColors.mint.withOpacity(0.7) : AppColors.text,
                          decoration: item.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(item.duration,
                          style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
                    ],
                  ),
                ),
                // XP badge
                Text('+${item.xp} XP',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.amber.withOpacity(0.7),
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text(item.emoji, style: const TextStyle(fontSize: 20)),
              ],
            ),
            // Timer countdown
            if (isTimerActive) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: AppColors.purple),
                  const SizedBox(width: 6),
                  Text(
                    fmt(timerSecondsLeft),
                    style: const TextStyle(
                        fontFamily: 'Syne', fontSize: 22,
                        fontWeight: FontWeight.w800, color: AppColors.purple,
                        letterSpacing: 2),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
