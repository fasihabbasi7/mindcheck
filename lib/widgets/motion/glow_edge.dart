import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'reveal.dart';

/// One slow clock shared by every glowing card, so all card edges shimmer
/// in step and the app runs a single animation for them instead of one per
/// card. Placed once around the whole app (see app.dart).
class ShimmerClock extends StatefulWidget {
  const ShimmerClock({super.key, required this.child});

  final Widget child;

  /// The shared 0→1 loop, or a still value when there is no clock or
  /// reduce motion is on.
  static Animation<double> of(BuildContext context) {
    final _ShimmerScope? scope =
        context.dependOnInheritedWidgetOfExactType<_ShimmerScope>();
    return scope?.animation ?? const AlwaysStoppedAnimation<double>(0.12);
  }

  @override
  State<ShimmerClock> createState() => _ShimmerClockState();
}

class _ShimmerClockState extends State<ShimmerClock>
    with SingleTickerProviderStateMixin {
  // One full turn of the edge colours every 10 seconds: calm, not busy.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
    value: 0.12,
  );

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
  Widget build(BuildContext context) =>
      _ShimmerScope(animation: _controller, child: widget.child);
}

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_ShimmerScope old) => old.animation != animation;
}

/// Draws the "glowing glass" edge on top of its child: a thin border whose
/// lavender, rose and sky colours slowly travel around the card, plus a
/// bright glass highlight along the top edge.
///
/// The child is cached in its own layer, so only the thin edge is redrawn
/// as it shimmers.
class GlowEdge extends StatelessWidget {
  const GlowEdge({
    super.key,
    required this.child,
    this.radius = 24,
    this.accent,
    this.strength = 1,
  });

  final Widget child;
  final double radius;

  /// Tints the edge, e.g. with a test's own colour.
  final Color? accent;

  /// 0 to 1: how bright the edge is.
  final double strength;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _GlowEdgePainter(
        animation: ShimmerClock.of(context),
        radius: radius,
        accent: accent,
        strength: strength,
        dark: Theme.of(context).brightness == Brightness.dark,
      ),
      child: RepaintBoundary(child: child),
    );
  }
}

class _GlowEdgePainter extends CustomPainter {
  _GlowEdgePainter({
    required this.animation,
    required this.radius,
    required this.accent,
    required this.strength,
    required this.dark,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final double radius;
  final Color? accent;
  final double strength;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || strength <= 0) return;
    final Rect rect = (Offset.zero & size).deflate(0.6);
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final double a = (dark ? 0.75 : 0.95) * strength;

    final Color lead = accent ?? AppColors.primary;
    final List<Color> colours = <Color>[
      lead.withValues(alpha: a),
      const Color(0xFFF2B8DD).withValues(alpha: a * 0.85),
      Colors.white.withValues(alpha: a * (dark ? 0.35 : 0.9)),
      const Color(0xFFA8D8F5).withValues(alpha: a * 0.85),
      AppColors.secondary.withValues(alpha: a),
      lead.withValues(alpha: a),
    ];

    // Travelling gradient border.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = dark ? 1.2 : 1.5
        ..shader = SweepGradient(
          colors: colours,
          transform: GradientRotation(animation.value * math.pi * 2),
        ).createShader(rect),
    );

    // Glass highlight: a bright line that fades out down the sides.
    canvas.drawRRect(
      rrect.deflate(1.4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.white.withValues(alpha: (dark ? 0.28 : 0.9) * strength),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const <double>[0, 0.45],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlowEdgePainter old) =>
      old.radius != radius ||
      old.accent != accent ||
      old.strength != strength ||
      old.dark != dark ||
      old.animation != animation;
}
