import 'dart:convert';
import 'dart:math' as dart_math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'models/data.dart';
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
      title: 'Aurora',
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

  // All start at zero — no hardcoded values
  int _streak = 0;
  int _xp = 0;
  int _tasksCompleted = 0;
  bool _allLocked = true;
  int _spinsCompleted = 0;
  int _ritualsCompleted = 0;
  int _jackpots = 0;
  int _bodyCompleted = 0;
  int _mindCompleted = 0;
  int _calmCompleted = 0;
  int _hustleCompleted = 0;
  List<ActivityEntry> _activity = [];

  final List<ConfettiParticle> _confetti = [];
  late AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addListener(() {
        setState(() {
          for (final p in _confetti) {
            p.x += p.vx;
            p.y += p.vy;
            p.rotation += p.rotSpeed;
            p.vy += 0.00018;
            p.vx += (p.rotSpeed > 0 ? 0.00008 : -0.00008);
            if (p.y > 0.88) {
              p.vy *= 0.72;
              p.vx *= 0.78;
              p.rotSpeed *= 0.85;
            }
            if (_confettiCtrl.value > 0.8) {
              p.opacity = ((1 - _confettiCtrl.value) / 0.2).clamp(0, 1);
            }
          }
        });
      });
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final activityJson = prefs.getStringList('activity') ?? const [];
    final decodedActivity = <ActivityEntry>[];
    for (final s in activityJson) {
      try {
        decodedActivity
            .add(ActivityEntry.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }
    setState(() {
      _xp = prefs.getInt('xp') ?? 0;
      _streak = prefs.getInt('streak') ?? 0;
      _tasksCompleted = prefs.getInt('tasksCompleted') ?? 0;
      _spinsCompleted = prefs.getInt('spinsCompleted') ?? 0;
      _ritualsCompleted = prefs.getInt('ritualsCompleted') ?? 0;
      _jackpots = prefs.getInt('jackpots') ?? 0;
      _bodyCompleted = prefs.getInt('bodyCompleted') ?? 0;
      _mindCompleted = prefs.getInt('mindCompleted') ?? 0;
      _calmCompleted = prefs.getInt('calmCompleted') ?? 0;
      _hustleCompleted = prefs.getInt('hustleCompleted') ?? 0;
      _activity = decodedActivity;
      _allLocked = prefs.getBool('allLocked') ?? true;
      if (_xp > 0 || _tasksCompleted > 0 || _jackpots > 0) _allLocked = false;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('xp', _xp);
    await prefs.setInt('streak', _streak);
    await prefs.setInt('tasksCompleted', _tasksCompleted);
    await prefs.setInt('spinsCompleted', _spinsCompleted);
    await prefs.setInt('ritualsCompleted', _ritualsCompleted);
    await prefs.setInt('jackpots', _jackpots);
    await prefs.setInt('bodyCompleted', _bodyCompleted);
    await prefs.setInt('mindCompleted', _mindCompleted);
    await prefs.setInt('calmCompleted', _calmCompleted);
    await prefs.setInt('hustleCompleted', _hustleCompleted);
    await prefs.setBool('allLocked', _allLocked);
    await prefs.setStringList(
      'activity',
      _activity.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _spawnConfetti(int count) {
    final rng = dart_math.Random();
    _confetti.clear();
    final total = (count * 12).clamp(100, 1000);
    for (int i = 0; i < total; i++) {
      final p = ConfettiParticle.random(rng);
      p.y = -0.02 - rng.nextDouble() * 0.35;
      p.vy = 0.003 + rng.nextDouble() * 0.006;
      p.vx = (rng.nextDouble() - 0.5) * 0.005;
      p.opacity = 1.0;
      p.type = i % 3;
      _confetti.add(p);
    }
    _confettiCtrl.reset();
    _confettiCtrl.forward();
  }

  void _addXp(int amount) {
    setState(() {
      _xp += amount;
      _tasksCompleted++;
      if (_xp > 0) _allLocked = false;
    });
    _saveProgress();
  }

  void _goTo(int i) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = i);
  }

  void _onSpinDone(WheelSegment seg) {
    setState(() {
      _xp += seg.xp;
      _tasksCompleted++;
      _streak++;
      _spinsCompleted++;
      if (_xp > 0) _allLocked = false;
      switch (seg.category) {
        case 'BODY':
          _bodyCompleted++;
          break;
        case 'MIND':
          _mindCompleted++;
          break;
        case 'CALM':
          _calmCompleted++;
          break;
        case 'HUSTLE':
          _hustleCompleted++;
          break;
      }
      _activity.insert(
        0,
        ActivityEntry(
          type: 'spin',
          label: seg.label,
          emoji: seg.emoji,
          xp: seg.xp,
          category: seg.category,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      if (_activity.length > 30) _activity = _activity.take(30).toList();
    });
    _saveProgress();
    _spawnConfetti(60);
    _goTo(0);
  }

  void _onRitualDone(RitualItem item) {
    setState(() {
      _xp += item.xp;
      _tasksCompleted++;
      _ritualsCompleted++;
      if (_xp > 0) _allLocked = false;
      _activity.insert(
        0,
        ActivityEntry(
          type: 'ritual',
          label: item.name,
          emoji: item.emoji,
          xp: item.xp,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      if (_activity.length > 30) _activity = _activity.take(30).toList();
    });
    _saveProgress();
  }

  void _onJackpot() {
    setState(() {
      _jackpots++;
      _allLocked = false;
      _activity.insert(
        0,
        ActivityEntry(
          type: 'slots',
          label: '777 Jackpot',
          emoji: '🎰',
          xp: 0,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      if (_activity.length > 30) _activity = _activity.take(30).toList();
    });
    _saveProgress();
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Everything?',
            style: TextStyle(
                color: AppColors.text,
                fontFamily: 'Syne',
                fontWeight: FontWeight.w700)),
        content: const Text(
            'This will reset your XP, streak, tasks and badges to zero.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _xp = 0;
                _streak = 0;
                _tasksCompleted = 0;
                _allLocked = true;
                _spinsCompleted = 0;
                _ritualsCompleted = 0;
                _jackpots = 0;
                _bodyCompleted = 0;
                _mindCompleted = 0;
                _calmCompleted = 0;
                _hustleCompleted = 0;
                _activity = [];
              });
              _saveProgress();
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
            tasksCompleted: _tasksCompleted,
            onSpin: () => _goTo(1),
            onConfetti: _spawnConfetti,
            onReset: _reset,
          ),
        1 => SpinScreen(onTaskDone: _onSpinDone, onConfetti: _spawnConfetti),
        2 => SlotsScreen(onConfetti: _spawnConfetti, onJackpot: _onJackpot),
        3 => RitualScreen(
            onConfetti: _spawnConfetti,
            onAddXp: _addXp,
            onTaskDone: _onRitualDone,
          ),
        4 => AchievementsScreen(
            xp: _xp,
            streak: _streak,
            allLocked: _allLocked,
            tasksCompleted: _tasksCompleted,
            spinsCompleted: _spinsCompleted,
            ritualsCompleted: _ritualsCompleted,
            jackpots: _jackpots,
            bodyCompleted: _bodyCompleted,
            mindCompleted: _mindCompleted,
            calmCompleted: _calmCompleted,
            hustleCompleted: _hustleCompleted,
            activity: _activity,
          ),
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
                  ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_currentIndex),
                child: _buildScreen(),
              ),
            ),
            if (_confetti.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: ConfettiPainter(_confetti)),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _currentIndex == 0
          ? null
          : _BottomNav(currentIndex: _currentIndex, onTap: _goTo),
    );
  }
}

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                  ? [
                                      Shadow(
                                          color: AppColors.purple,
                                          blurRadius: 12)
                                    ]
                                  : null,
                            )),
                      ),
                      const SizedBox(height: 4),
                      Text(_items[i].$2,
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w500,
                            color:
                                active ? AppColors.purple : AppColors.textDim,
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
