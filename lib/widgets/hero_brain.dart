import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_theme.dart';

/// MindCheck's main hero: the 3D brain image, brought to life in code.
///
/// The picture itself (assets/images/brain.webp) already contains the brain
/// and its orbit ring. On top of it this widget adds:
///  * a soft glow behind the brain that slowly breathes
///  * a gentle floating motion
///  * a ground shadow that shrinks as the brain rises
///  * a light pulse that travels along the front of the orbit ring
///  * twinkling sparkles
///
/// Animation stops automatically when the user has "reduce motion" turned on.
class HeroBrain extends StatefulWidget {
  const HeroBrain({super.key, this.width = 300, this.animate = true});

  static const String asset = 'assets/images/brain.webp';

  /// Width / height of the brain image file (1130 x 792 at full size).
  static const double imageAspect = 1130 / 792;

  /// Width of the brain image. The widget is a little taller than the image
  /// to leave room for the shadow underneath.
  final double width;
  final bool animate;

  /// Total height this widget takes up for a given [width].
  static double heightFor(double width) => width / imageAspect * 1.22;

  @override
  State<HeroBrain> createState() => _HeroBrainState();
}

class _HeroBrainState extends State<HeroBrain>
    with SingleTickerProviderStateMixin {
  // One 8-second loop drives everything. Every motion uses whole-number
  // multiples of it, so the animation repeats smoothly.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
    value: 0.1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(HeroBrain oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final bool shouldRun = widget.animate && !reduceMotion;

    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldRun && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shrink on very narrow screens instead of overflowing.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          _buildBrain(context, math.min(widget.width, constraints.maxWidth)),
    );
  }

  Widget _buildBrain(BuildContext context, double w) {
    final double imageHeight = w / HeroBrain.imageAspect;
    final bool isDark = context.isDarkMode;
    final Color glow = context.mind.glow;

    final Widget image = Image.asset(
      HeroBrain.asset,
      width: w,
      height: imageHeight,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
    );

    return Semantics(
      image: true,
      label: 'Illustration of a glowing brain',
      child: RepaintBoundary(
        child: SizedBox(
          width: w,
          height: HeroBrain.heightFor(w),
          child: AnimatedBuilder(
            animation: _controller,
            child: image,
            builder: (BuildContext context, Widget? child) {
              final double t = _controller.value;
              // -1 .. 1, one full float cycle every 4 seconds.
              final double wave = math.sin(t * 2 * math.pi * 2);
              final double floatY = wave * imageHeight * 0.035;

              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GlowAndShadowPainter(
                        t: t,
                        wave: wave,
                        imageHeight: imageHeight,
                        glow: glow,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: imageHeight * 0.04 + floatY,
                    width: w,
                    height: imageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        child!,
                        CustomPaint(painter: _RingPulsePainter(t: t)),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SparklePainter(t: t, isDark: isDark),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

const double _tau = 2 * math.pi;

/// Soft glow behind the brain and the shadow on the "floor" below it.
class _GlowAndShadowPainter extends CustomPainter {
  _GlowAndShadowPainter({
    required this.t,
    required this.wave,
    required this.imageHeight,
    required this.glow,
    required this.isDark,
  });

  final double t;
  final double wave;
  final double imageHeight;
  final Color glow;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    // Breathing glow
    final Offset glowCentre = Offset(size.width * 0.5, imageHeight * 0.48);
    final double glowR = size.width * (0.52 + 0.03 * math.sin(t * _tau));
    canvas.drawCircle(
      glowCentre,
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            glow.withValues(alpha: isDark ? 0.9 : 1.0),
            glow.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: glowCentre, radius: glowR)),
    );

    // Floor shadow: bigger and darker when the brain is lower (wave > 0).
    final double scale = 1 + 0.1 * wave;
    final Rect shadow = Rect.fromCenter(
      center: Offset(size.width * 0.5, imageHeight * 1.12),
      width: size.width * 0.5 * scale,
      height: imageHeight * 0.07 * scale,
    );
    canvas.drawOval(
      shadow,
      Paint()
        ..color = AppColors.primaryDeep
            .withValues(alpha: (isDark ? 0.55 : 0.28) * (0.85 + 0.15 * wave))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, imageHeight * 0.04),
    );
  }

  @override
  bool shouldRepaint(_GlowAndShadowPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.glow != glow ||
      oldDelegate.isDark != isDark ||
      oldDelegate.imageHeight != imageHeight;
}

/// A comet of light that runs along the front half of the orbit ring that is
/// part of the brain image. The ellipse below was measured from the image
/// (in pixels of the full-size 1130 x 792 file).
class _RingPulsePainter extends CustomPainter {
  _RingPulsePainter({required this.t});

  final double t;

  static const double _imageWidth = 1130;
  static const double _cx = 560.5;
  static const double _cy = 320.9;
  static const double _minor = 137.6; // semi-axis towards the viewer
  static const double _major = 574.6; // semi-axis left-right
  // Directions of the two axes (ring is tilted about 16 degrees).
  static const double _ux = 0.2859;
  static const double _uy = 0.9583;
  static const double _vx = -0.9583;
  static const double _vy = 0.2859;

  static const Color _pink = Color(0xFFF6C4F3);

  Offset _pointAt(double angle, double scale) {
    final double c = math.cos(angle);
    final double s = math.sin(angle);
    return Offset(
      (_cx + _ux * _minor * c + _vx * _major * s) * scale,
      (_cy + _uy * _minor * c + _vy * _major * s) * scale,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // One pulse every 4 seconds; it is visible for the first 70% of that.
    final double cycle = (t * 2) % 1.0;
    if (cycle > 0.7) return;
    final double progress = cycle / 0.7;
    final double fade = math.sin(progress * math.pi);

    final double scale = size.width / _imageWidth;
    // From the right end of the ring, across the front, to the left end.
    const double range = 80 * math.pi / 180;
    final double head = -range + progress * 2 * range;

    // Fading trail
    for (int i = 6; i >= 1; i--) {
      final double strength = fade * (1 - i / 7);
      canvas.drawCircle(
        _pointAt(head - i * 0.04, scale),
        scale * (13 - i),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55 * strength)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 6),
      );
    }

    // Head: coloured halo plus a bright core
    final Offset p = _pointAt(head, scale);
    canvas.drawCircle(
      p,
      scale * 48,
      Paint()
        ..color = _pink.withValues(alpha: 0.6 * fade)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 26),
    );
    canvas.drawCircle(
      p,
      scale * 13,
      Paint()..color = Colors.white.withValues(alpha: fade),
    );
  }

  @override
  bool shouldRepaint(_RingPulsePainter oldDelegate) => oldDelegate.t != t;
}

/// Four-pointed sparkles that softly twinkle around the brain.
class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.t, required this.isDark});

  final double t;
  final bool isDark;

  // (x, y) as a fraction of the widget size, base radius in logical pixels,
  // twinkle speed (whole number), and phase offset.
  static const List<(double, double, double, int, double)> _sparkles =
      <(double, double, double, int, double)>[
    (0.06, 0.20, 11.0, 1, 0.0),
    (0.82, 0.04, 13.0, 2, 1.7),
    (0.97, 0.66, 9.0, 1, 3.1),
    (0.20, 0.80, 10.0, 2, 4.4),
    (0.55, 0.03, 7.0, 3, 2.3),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Color core = isDark ? const Color(0xFFF3E9FF) : Colors.white;
    final Color halo = isDark ? AppColors.secondary : AppColors.primary;

    for (final (double fx, double fy, double radius, int speed, double phase)
        in _sparkles) {
      final double twinkle = 0.5 + 0.5 * math.sin(t * _tau * speed + phase);
      final double r = radius * (0.55 + 0.45 * twinkle);
      final Offset centre = Offset(fx * size.width, fy * size.height);

      canvas.drawCircle(
        centre,
        r * 0.9,
        Paint()
          ..color = halo.withValues(alpha: 0.25 * twinkle)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.8),
      );
      canvas.drawPath(
        _starPath(centre, r),
        Paint()..color = core.withValues(alpha: 0.45 + 0.55 * twinkle),
      );
    }
  }

  /// A four-pointed star with gently curved sides.
  Path _starPath(Offset c, double r) {
    final double k = r * 0.12; // how "pinched" the middle is
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - r)
      ..close();
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.isDark != isDark;
}
