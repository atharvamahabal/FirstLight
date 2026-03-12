import 'package:flutter/material.dart' hide Badge;
import '../theme.dart';
import '../models/data.dart';
import '../widgets/common.dart';

class AchievementsScreen extends StatelessWidget {
  final int xp;
  const AchievementsScreen({super.key, required this.xp});

  Color _bgColor(BadgeColor c) => switch (c) {
        BadgeColor.purple => AppColors.purple.withOpacity(0.10),
        BadgeColor.amber  => AppColors.amber.withOpacity(0.08),
        BadgeColor.mint   => AppColors.mint.withOpacity(0.08),
        BadgeColor.pink   => AppColors.pink.withOpacity(0.08),
      };

  Color _borderColor(BadgeColor c) => switch (c) {
        BadgeColor.purple => AppColors.purple.withOpacity(0.22),
        BadgeColor.amber  => AppColors.amber.withOpacity(0.22),
        BadgeColor.mint   => AppColors.mint.withOpacity(0.22),
        BadgeColor.pink   => AppColors.pink.withOpacity(0.22),
      };

  Color _tierColor(BadgeColor c) => switch (c) {
        BadgeColor.purple => AppColors.purple,
        BadgeColor.amber  => AppColors.amber,
        BadgeColor.mint   => AppColors.mint,
        BadgeColor.pink   => AppColors.pink,
      };

  @override
  Widget build(BuildContext context) {
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
                        style: TextStyle(fontSize: 11, letterSpacing: 3,
                            color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('Achievements 🏆',
                        style: TextStyle(fontFamily: 'Syne', fontSize: 28,
                            fontWeight: FontWeight.w800, height: 1.1)),
                  ],
                ),
              ),
              // XP pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.purpleDark.withOpacity(0.8), AppColors.purple.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.purple.withOpacity(0.4)),
                  boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.3), blurRadius: 16)],
                ),
                child: Column(
                  children: [
                    Text('$xp',
                        style: const TextStyle(
                            fontFamily: 'Syne', fontSize: 22,
                            fontWeight: FontWeight.w800, color: Colors.white)),
                    const Text('⚡ XP',
                        style: TextStyle(fontSize: 9, color: Colors.white70, letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text('${badges.where((b) => !b.locked).length} / ${badges.length} unlocked',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1)),
          const SizedBox(height: 14),

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
                return _BadgeCard(
                  badge: b,
                  bgColor: _bgColor(b.color),
                  borderColor: _borderColor(b.color),
                  tierColor: _tierColor(b.color),
                  onInfo: () => _showInfo(context, b, _tierColor(b.color)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, Badge b, Color tierColor) {
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
                    fontFamily: 'Syne', fontSize: 22,
                    fontWeight: FontWeight.w800, color: tierColor)),
            const SizedBox(height: 6),
            Text(b.tier,
                style: TextStyle(
                    fontSize: 10, letterSpacing: 2, color: tierColor.withOpacity(0.7))),
            const SizedBox(height: 14),
            Text(b.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textMuted, height: 1.5)),
            const SizedBox(height: 8),
            if (b.locked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
  final VoidCallback onInfo;
  const _BadgeCard({
    required this.badge,
    required this.bgColor,
    required this.borderColor,
    required this.tierColor,
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
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
          opacity: b.locked ? 0.28 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.borderColor),
              boxShadow: b.locked
                  ? null
                  : [BoxShadow(
                      color: widget.tierColor.withOpacity(0.15),
                      blurRadius: 20, offset: const Offset(0, 6))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                b.locked
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      1, 0,
                        ]),
                        child: Text(b.icon, style: const TextStyle(fontSize: 26)),
                      )
                    : Text(b.icon, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(b.name,
                      style: const TextStyle(
                          fontFamily: 'Syne', fontSize: 9,
                          fontWeight: FontWeight.w700, height: 1.3),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 3),
                Text(b.tier,
                    style: TextStyle(
                        fontSize: 7, letterSpacing: 1.2,
                        color: b.locked ? AppColors.textDim : widget.tierColor)),
                if (!b.locked) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.tierColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('ℹ info',
                        style: TextStyle(fontSize: 7, color: widget.tierColor)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
