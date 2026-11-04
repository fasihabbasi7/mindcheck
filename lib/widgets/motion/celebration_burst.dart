import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../utils/app_strings.dart';
import 'reveal.dart';

/// A small, calm celebration: a soft ring of light and a burst of tiny
/// sparkles that drift outwards and fade. Plays once, after [delay].
///
/// Place it over the area to celebrate (it fills its parent and ignores
/// touches). Nothing is drawn with reduce motion on.
class CelebrationBurst extends StatefulWidget {
  const CelebrationBurst({
    super.key,
    this.delay = Duration.zero,
    this.origin = Alignment.center,
  });

  final Duration delay;

  /// Where the burst starts, e.g. the centre of the score gauge.
  final Alignment origin;

  @override
  State<CelebrationBurst> createState() => _CelebrationBurstState();
}

class _CelebrationBurstState extends State<CelebrationBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  final List<_Spark> _sparks = _Spark.generate(30);
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotionOf(context)) return;
    _timer = Timer(widget.delay, () {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.revealCelebration,
      liveRegion: true,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _BurstPainter(
              animation: _controller,
              sparks: _sparks,
              origin: widget.origin,
            ),
          ),
        ),
      ),
    );
  }
}

class _Spark {
  const _Spark({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.star,
    required this.spin,
  });

  final double angle;

  /// How far it travels, in pixels.
  final double distance;
  final double size;
  final Color color;

  /// Four-pointed sparkle instead of a dot.
  final bool star;
  final double spin;

  static const List<Color> _palette = <Color>[
    AppColors.primary,
    AppColors.secondary,
    AppColors.lilac,
    Color(0xFFF5BDD9),
    Color(0xFFA8D8F5),
    Color(0xFFFFDDA6),
  ];

  static List<_Spark> generate(int count) {
    final math.Random random = math.Random(7);
    return <_Spark>[
      for (int i = 0; i < count; i++)
        _Spark(
          angle: (i / count) * math.pi * 2 + random.nextDouble() * 0.4,
          distance: 70 + random.nextDouble() * 90,
          size: 2.5 + random.nextDouble() * 3.5,
          color: _palette[random.nextInt(_palette.length)],
          star: random.nextDouble() < 0.4,
          spin: (random.nextDouble() - 0.5) * 4,
        ),
    ];
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.animation,
    required this.sparks,
    required this.origin,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<_Spark> sparks;
  final Alignment origin;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = animation.value;
    if (t <= 0 || t >= 1) return;
    final Offset center = origin.alongSize(size);

    // Soft expanding ring.
    final double ring = Curves.easeOutCubic.transform(t);
    canvas.drawCircle(
      center,
      30 + ring * 110,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * (1 - ring)
        ..color = AppColors.secondary.withValues(alpha: 0.55 * (1 - ring)),
    );

    // Sparkles: shoot out quickly, slow down, drift down a touch, fade.
    final double travel = Curves.easeOutQuart.transform(t);
    final double fade = t < 0.6 ? 1.0 : 1 - (t - 0.6) / 0.4;
    final Paint paint = Paint();
    for (final _Spark s in sparks) {
      final Offset position = center +
          Offset(math.cos(s.angle), math.sin(s.angle)) * s.distance * travel +
          Offset(0, 18 * t * t);
      paint.color = s.color.withValues(alpha: fade.clamp(0.0, 1.0));
      final double r = s.size * (1 - 0.3 * t);
      if (s.star) {
        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.rotate(s.spin * t);
        canvas.drawPath(_star(r * 1.8), paint);
        canvas.restore();
      } else {
        canvas.drawCircle(position, r, paint);
      }
    }
  }

  /// A small four-pointed sparkle centred on (0, 0).
  Path _star(double r) {
    final double w = r * 0.28;
    return Path()
      ..moveTo(0, -r)
      ..quadraticBezierTo(w, -w, r, 0)
      ..quadraticBezierTo(w, w, 0, r)
      ..quadraticBezierTo(-w, w, -r, 0)
      ..quadraticBezierTo(-w, -w, 0, -r)
      ..close();
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.origin != origin || oldDelegate.sparks != sparks;
}
