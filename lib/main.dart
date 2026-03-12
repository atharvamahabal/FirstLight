import 'dart:math' as dart_math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'screens/home_screen.dart';
import 'screens/spin_screen.dart';
import 'screens/slots_screen.dart';
import 'screens/ritual_screen.dart';
import 'screens/achievements_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const FirstLightApp());
}

class FirstLightApp extends StatelessWidget {
  const FirstLightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FirstLight',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;

  // App-level state
  int _streak = 7;
  int _xp = 340;
  int _badgeCount = 10;

  // Confetti — rain-style from top
  final List<ConfettiParticle> _confetti = [];
  late AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addListener(() {
        setState(() {
          for (final p in _confetti) {
            p.x += p.vx;
            p.y += p.vy;
            p.rotation += p.rotSpeed;
            // Land effect: slow down near bottom
            if (p.y > 0.85) {
              p.vy *= 0.85;
              p.vx *= 0.9;
            }
            // Fade only in last 30% of animation
            if (_confettiCtrl.value > 0.7) {
              p.opacity = ((1 - _confettiCtrl.value) / 0.3).clamp(0, 1);
            }
          }
        });
      });
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _spawnConfetti(int count) {
    final rng = dart_math.Random();
    _confetti.clear();
    for (int i = 0; i < count; i++) {
      final p = ConfettiParticle.random(rng);
      // Start from top of screen
      p.y = -0.05 - rng.nextDouble() * 0.2;
      p.vy = 0.004 + rng.nextDouble() * 0.005;
      p.vx = (rng.nextDouble() - 0.5) * 0.003;
      p.opacity = 1.0;
      _confetti.add(p);
    }
    _confettiCtrl.reset();
    _confettiCtrl.forward();
  }

  void _addXp(int amount) {
    setState(() => _xp += amount);
  }

  void _goTo(int i) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = i);
  }

  void _onTaskDone(int xpEarned) {
    _addXp(xpEarned);
    _spawnConfetti(60);
    _goTo(0);
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Everything?',
            style: TextStyle(color: AppColors.text, fontFamily: 'Syne', fontWeight: FontWeight.w700)),
        content: const Text('This will reset your XP, streak, and badges to zero.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _xp = 0;
                _streak = 0;
                _badgeCount = 0;
              });
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.pink)),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen() => switch (_currentIndex) {
        0 => HomeScreen(
            streak: _streak,
            xp: _xp,
            badgeCount: _badgeCount,
            onSpin: () => _goTo(1),
            onConfetti: _spawnConfetti,
            onReset: _reset,
          ),
        1 => SpinScreen(onTaskDone: _onTaskDone, onConfetti: _spawnConfetti, onAddXp: _addXp),
        2 => SlotsScreen(onConfetti: _spawnConfetti),
        3 => RitualScreen(onConfetti: _spawnConfetti, onAddXp: _addXp),
        4 => AchievementsScreen(xp: _xp),
        _ => const SizedBox.shrink(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBody: true,
      body: AmbientBackground(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_currentIndex),
                child: _buildScreen(),
              ),
            ),
            // Confetti rain overlay
            if (_confetti.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: ConfettiPainter(_confetti)),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(currentIndex: _currentIndex, onTap: _goTo),
    );
  }
}

// ── Bottom Navigation ──────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    ('🌅', 'Home'),
    ('🎡', 'Spin'),
    ('🎰', '777'),
    ('✅', 'Ritual'),
    ('🏆', 'Trophies'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [AppColors.bg, AppColors.bg.withOpacity(0.7)],
        ),
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: active ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(_items[i].$1,
                            style: TextStyle(
                              fontSize: 20,
                              shadows: active
                                  ? [Shadow(color: AppColors.purple, blurRadius: 12)]
                                  : null,
                            )),
                      ),
                      const SizedBox(height: 4),
                      Text(_items[i].$2,
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w500,
                            color: active ? AppColors.purple : AppColors.textDim,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
