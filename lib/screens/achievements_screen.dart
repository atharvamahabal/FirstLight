import 'package:flutter/material.dart' hide Badge;
import '../theme.dart';
import '../models/data.dart';
import '../widgets/common.dart';

class AchievementsScreen extends StatelessWidget {
  final int xp;
  final int streak;
  final bool allLocked;
  final int tasksCompleted;
  final int spinsCompleted;
  final int ritualsCompleted;
  final int jackpots;
  final int bodyCompleted;
  final int mindCompleted;
  final int calmCompleted;
  final int hustleCompleted;
  final List<ActivityEntry> activity;
  const AchievementsScreen(
      {super.key,
      required this.xp,
      required this.streak,
      required this.allLocked,
      required this.tasksCompleted,
      required this.spinsCompleted,
      required this.ritualsCompleted,
      required this.jackpots,
      required this.bodyCompleted,
      required this.mindCompleted,
      required this.calmCompleted,
      required this.hustleCompleted,
      required this.activity});

  Color _bgColor(BadgeColor c) => switch (c) {
        BadgeColor.purple => AppColors.purple.withOpacity(0.10),
        BadgeColor.amber => AppColors.amber.withOpacity(0.08),
        BadgeColor.mint => AppColors.mint.withOpacity(0.08),
        BadgeColor.pink => AppColors.pink.withOpacity(0.08),
      };

  Color _borderColor(BadgeColor c) => switch (c) {
        BadgeColor.purple => AppColors.purple.withOpacity(0.22),
        BadgeColor.amber => AppColors.amber.withOpacity(0.22),
        BadgeColor.mint => AppColors.mint.withOpacity(0.22),
        BadgeColor.pink => AppColors.pink.withOpacity(0.22),
      };

  Color _tierColor(BadgeColor c) => switch (c) {
        BadgeColor.purple => AppColors.purple,
        BadgeColor.amber => AppColors.amber,
        BadgeColor.mint => AppColors.mint,
        BadgeColor.pink => AppColors.pink,
      };

  ({int current, int target, String requirement})? _progressFor(Badge b) {
    return switch (b.name) {
      'First Flame' => (
          current: tasksCompleted.clamp(0, 1),
          target: 1,
          requirement: 'Complete 1 task'
        ),
      '7-Day Streak' => (
          current: streak.clamp(0, 7),
          target: 7,
          requirement: 'Maintain a 7-day streak'
        ),
      'Body Warrior' => (
          current: bodyCompleted.clamp(0, 10),
          target: 10,
          requirement: 'Complete 10 BODY challenges'
        ),
      'Zen Master' => (
          current: calmCompleted.clamp(0, 5),
          target: 5,
          requirement: 'Complete 5 CALM challenges'
        ),
      'Hustle King' => (
          current: hustleCompleted.clamp(0, 5),
          target: 5,
          requirement: 'Complete 5 HUSTLE tasks'
        ),
      'Lucky 777' => (
          current: jackpots.clamp(0, 1),
          target: 1,
          requirement: 'Hit a jackpot in 777 slots'
        ),
      'Rising Star' => (
          current: xp.clamp(0, 1000),
          target: 1000,
          requirement: 'Reach 1000 XP'
        ),
      'Launch Pad' => (
          current: ritualsCompleted.clamp(0, 20),
          target: 20,
          requirement: 'Complete 20 morning rituals'
        ),
      'Eagle Eye' => (
          current: spinsCompleted.clamp(0, 50),
          target: 50,
          requirement: 'Spin the wheel 50 times'
        ),
      'Graduate' => (
          current: tasksCompleted.clamp(0, 50),
          target: 50,
          requirement: 'Complete 50 tasks total'
        ),
      _ => null,
    };
  }

  String _fmtTime(int timestampMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = allLocked
        ? 0
        : badges.where((b) {
            final p = _progressFor(b);
            if (p != null) return p.current >= p.target;
            return !b.locked;
          }).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with XP in top right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Trophy Room',
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 3,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('Achievements 🏆',
                        style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.1)),
                  ],
                ),
              ),
              // XP pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.purpleDark.withOpacity(0.8),
                      AppColors.purple.withOpacity(0.8)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.purple.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.purple.withOpacity(0.3),
                        blurRadius: 16)
                  ],
                ),
                child: Column(
                  children: [
                    Text('$xp',
                        style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const Text('⚡ XP',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.white70,
                            letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text('$unlockedCount / ${badges.length} unlocked',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text('$tasksCompleted tasks completed',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textDim, letterSpacing: 1)),
          const SizedBox(height: 14),

          if (activity.isNotEmpty) ...[
            const Text('RECENT ACTIVITY',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2.5,
                    color: AppColors.textDim,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            FlatCard(
              child: SizedBox(
                height: 118,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: activity.length > 8 ? 8 : activity.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final a = activity[i];
                    final time = _fmtTime(a.timestampMs);
                    final right = a.xp > 0
                        ? '+${a.xp} XP'
                        : (a.type == 'slots' ? 'JACKPOT' : '');
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text(a.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(a.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'Syne',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text)),
                          ),
                          const SizedBox(width: 10),
                          Text(time,
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textDim)),
                          const SizedBox(width: 10),
                          if (right.isNotEmpty)
                            Text(right,
                                style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w700,
                                    color: a.type == 'slots'
                                        ? AppColors.pink
                                        : AppColors.amber)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Expanded(
            child: GridView.builder(
              itemCount: badges.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (_, i) {
                final b = badges[i];
                final p = _progressFor(b);
                final progress = p == null
                    ? (b.locked ? 0.0 : 1.0)
                    : (p.current / p.target).clamp(0.0, 1.0);
                final locked =
                    allLocked ? true : (p == null ? b.locked : progress < 1.0);
                final progressText =
                    p == null ? null : '${p.current}/${p.target}';
                final badge = Badge(
                  icon: b.icon,
                  name: b.name,
                  tier: b.tier,
                  description: b.description,
                  color: b.color,
                  locked: locked,
                );
                return _BadgeCard(
                  badge: badge,
                  bgColor: _bgColor(b.color),
                  borderColor: _borderColor(b.color),
                  tierColor: _tierColor(b.color),
                  progress: allLocked ? 0 : progress,
                  progressText: allLocked ? null : progressText,
                  requirement: p?.requirement,
                  onInfo: () => _showInfo(
                    context,
                    badge,
                    _tierColor(b.color),
                    progressText: allLocked ? null : progressText,
                    requirement: p?.requirement,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(
    BuildContext context,
    Badge b,
    Color tierColor, {
    String? progressText,
    String? requirement,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(b.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(b.name,
                style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: tierColor)),
            const SizedBox(height: 6),
            Text(b.tier,
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: tierColor.withOpacity(0.7))),
            const SizedBox(height: 14),
            Text(b.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textMuted, height: 1.5)),
            if (requirement != null) ...[
              const SizedBox(height: 10),
              Text(requirement,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textDim, height: 1.4)),
            ],
            if (progressText != null) ...[
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: Text('Progress: $progressText',
                    style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text)),
              ),
            ],
            const SizedBox(height: 8),
            if (b.locked)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🔒  Locked — keep grinding!',
                    style: TextStyle(fontSize: 13, color: AppColors.textDim)),
              ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatefulWidget {
  final Badge badge;
  final Color bgColor, borderColor, tierColor;
  final double progress;
  final String? progressText;
  final String? requirement;
  final VoidCallback onInfo;
  const _BadgeCard({
    required this.badge,
    required this.bgColor,
    required this.borderColor,
    required this.tierColor,
    required this.progress,
    required this.progressText,
    required this.requirement,
    required this.onInfo,
  });

  @override
  State<_BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<_BadgeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _scale = Tween<double>(begin: 1, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.badge;
    final opacity = (0.18 + 0.82 * widget.progress).clamp(0.18, 1.0);
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onInfo(); // show info on tap
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Opacity(
          opacity: b.locked ? opacity : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.borderColor),
              boxShadow: b.locked
                  ? null
                  : [
                      BoxShadow(
                          color: widget.tierColor.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 6))
                    ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.progress <= 0.01
                        ? ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ]),
                            child: Text(b.icon,
                                style: const TextStyle(fontSize: 26)),
                          )
                        : Text(b.icon, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(b.name,
                          style: const TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1.3),
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 3),
                    Text(b.tier,
                        style: TextStyle(
                            fontSize: 7,
                            letterSpacing: 1.2,
                            color: b.locked
                                ? AppColors.textDim
                                : widget.tierColor)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.tierColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.progressText == null
                            ? 'ℹ info'
                            : 'ℹ ${widget.progressText}',
                        style: TextStyle(fontSize: 7, color: widget.tierColor),
                      ),
                    ),
                  ],
                ),
                if (widget.progressText != null && widget.progress < 1.0)
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 6,
                        color: Colors.white.withOpacity(0.06),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: widget.progress.clamp(0.0, 1.0),
                            child: Container(
                              color: widget.tierColor.withOpacity(0.85),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
