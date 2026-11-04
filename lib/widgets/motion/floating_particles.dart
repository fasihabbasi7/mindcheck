import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'reveal.dart';

/// Soft specks of light that drift slowly upwards, like dust in sunlight.
///
/// Draws behind the content and never takes touches. It pauses when the
/// screen is hidden (Flutter's TickerMode) and is not drawn at all with
/// reduce motion on.
class FloatingParticles extends StatefulWidget {
  const FloatingParticles({
    super.key,
    required this.color,
    this.count = 18,
  });

  final Color color;
  final int count;

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  // One slow 24-second loop moves every particle.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  late final List<_Particle> _particles = _Particle.generate(widget.count);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotionOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotionOf(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(
            animation: _controller,
            particles: _particles,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.alpha,
  });

  /// Start position as a fraction of the screen (0–1).
  final double x;
  final double y;
  final double radius;

  /// Whole number of trips up the screen per loop, so the loop is seamless.
  final int speed;
  final double phase;
  final double alpha;

  static List<_Particle> generate(int count) {
    final math.Random random = math.Random(42); // same pattern every time
    return <_Particle>[
      for (int i = 0; i < count; i++)
        _Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: 1.5 + random.nextDouble() * 3,
          speed: 1 + random.nextInt(2),
          phase: random.nextDouble() * math.pi * 2,
          alpha: 0.25 + random.nextDouble() * 0.5,
        ),
    ];
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.animation,
    required this.particles,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<_Particle> particles;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = animation.value;
    final Paint paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    for (final _Particle p in particles) {
      // Rise steadily, wrapping from top back to bottom.
      final double y = (p.y - t * p.speed) % 1.0;
      // Sway gently side to side.
      final double sway = math.sin(t * math.pi * 2 * p.speed + p.phase) * 14;
      // Twinkle softly.
      final double twinkle =
          0.6 + 0.4 * math.sin(t * math.pi * 4 * p.speed + p.phase);
      paint.color = color.withValues(alpha: color.a * p.alpha * twinkle);
      canvas.drawCircle(
        Offset(p.x * size.width + sway, y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.particles != particles;
}
