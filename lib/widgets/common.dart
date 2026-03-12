import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

// ── Glass Card ────────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? radius;
  final Color? borderColor;
  final Color? bgColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.borderColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.glass,
        borderRadius: radius ?? BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? AppColors.glassBorder, width: 1),
      ),
      child: child,
    );
  }
}

// ── Ambient Background ────────────────────────────────────────────────────────
class AmbientBackground extends StatefulWidget {
  final Widget child;
  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with TickerProviderStateMixin {
  late AnimationController _ctrl1, _ctrl2, _ctrl3;
  late Animation<Offset> _orb1, _orb2;
  late Animation<double> _orb3Scale;

  @override
  void initState() {
    super.initState();
    _ctrl1 = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _ctrl2 = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat(reverse: true);
    _ctrl3 = AnimationController(vsync: this, duration: const Duration(seconds: 14))
      ..repeat(reverse: true);

    _orb1 = Tween<Offset>(begin: Offset.zero, end: const Offset(40, 30))
        .animate(CurvedAnimation(parent: _ctrl1, curve: Curves.easeInOut));
    _orb2 = Tween<Offset>(begin: Offset.zero, end: const Offset(-30, -40))
        .animate(CurvedAnimation(parent: _ctrl2, curve: Curves.easeInOut));
    _orb3Scale = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _ctrl3, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.bg),
        AnimatedBuilder(
          animation: _orb1,
          builder: (_, __) => Positioned(
            top: -100 + _orb1.value.dy,
            left: -100 + _orb1.value.dx,
            child: _Orb(size: 420, color: const Color(0xFF7C3AED), opacity: 0.30),
          ),
        ),
        AnimatedBuilder(
          animation: _orb2,
          builder: (_, __) => Positioned(
            bottom: -140 + _orb2.value.dy,
            right: -120 + _orb2.value.dx,
            child: _Orb(size: 320, color: const Color(0xFFF5A623), opacity: 0.20),
          ),
        ),
        AnimatedBuilder(
          animation: _orb3Scale,
          builder: (_, __) => Center(
            child: Transform.scale(
              scale: _orb3Scale.value,
              child: _Orb(size: 280, color: const Color(0xFFF472B6), opacity: 0.14),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Orb({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }
}

// ── Gradient Text ─────────────────────────────────────────────────────────────
class GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle style;

  const GradientText(this.text, {super.key, required this.gradient, required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style),
    );
  }
}

// ── Primary Button ────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color startColor;
  final Color endColor;
  final Color shadowColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.startColor = AppColors.purpleDark,
    this.endColor = AppColors.purple,
    this.shadowColor = AppColors.purple,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.4),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ── Secondary Button ──────────────────────────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SecondaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// ── Confetti Particle ─────────────────────────────────────────────────────────
class ConfettiParticle {
  double x, y, vx, vy, rotation, rotSpeed, opacity, size;
  int type; // 0=circle ball, 1=ribbon, 2=glitter star
  final Color color;
  final bool isCircle;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotSpeed,
    required this.color,
    required this.size,
    required this.isCircle,
    this.opacity = 1.0,
    this.type = 0,
  });

  static const _colors = [
    AppColors.purple,
    AppColors.amber,
    AppColors.mint,
    AppColors.pink,
    Colors.white,
    Color(0xFF60A5FA),
    Color(0xFFF87171),
    Color(0xFF34D399),
  ];

  factory ConfettiParticle.random(Random rng) {
    final t = rng.nextInt(3);
    return ConfettiParticle(
      x: rng.nextDouble(),
      y: -rng.nextDouble() * 0.3,
      vx: (rng.nextDouble() - 0.5) * 0.005,
      vy: 0.003 + rng.nextDouble() * 0.006,
      rotation: rng.nextDouble() * 2 * pi,
      rotSpeed: (rng.nextDouble() - 0.5) * 0.18,
      color: _colors[rng.nextInt(_colors.length)],
      size: 4.0 + rng.nextDouble() * 5.0,
      isCircle: t == 0,
      type: t,
      opacity: 1.0,
    );
  }
}

// ── Confetti Painter ──────────────────────────────────────────────────────────
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.opacity <= 0) continue;
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity)
        ..isAntiAlias = true;

      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);

      switch (p.type) {
        case 0: // Shiny circle ball
          canvas.drawCircle(Offset.zero, p.size, paint);
          // Highlight
          final shine = Paint()..color = Colors.white.withOpacity(p.opacity * 0.35);
          canvas.drawCircle(
              Offset(-p.size * 0.28, -p.size * 0.28), p.size * 0.38, shine);
          break;

        case 1: // Ribbon — tall thin rectangle that twists
          final ribbonPaint = Paint()
            ..color = p.color.withOpacity(p.opacity);
          final rect = RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size * 0.55,
              height: p.size * 3.8,
            ),
            const Radius.circular(2),
          );
          canvas.drawRRect(rect, ribbonPaint);
          // Ribbon shimmer stripe
          final shimmer = Paint()..color = Colors.white.withOpacity(p.opacity * 0.25);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(-p.size * 0.1, 0),
                width: p.size * 0.12,
                height: p.size * 3.2,
              ),
              const Radius.circular(1),
            ),
            shimmer,
          );
          break;

        case 2: // Glitter star
          _drawStar(canvas, p.size, paint);
          // Sparkle center glow
          final glow = Paint()
            ..color = Colors.white.withOpacity(p.opacity * 0.85)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
          canvas.drawCircle(Offset.zero, p.size * 0.28, glow);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double r, Paint paint) {
    final path = Path();
    const n = 5;
    final inner = r * 0.42;
    for (int i = 0; i < n * 2; i++) {
      final radius = i.isEven ? r : inner;
      final angle = (i * pi / n) - pi / 2;
      final x = radius * cos(angle);
      final y = radius * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConfettiPainter old) => true;
}
