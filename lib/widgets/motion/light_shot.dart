import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'reveal.dart';

/// Fires a small comet of light across the screen, from [from] to [to]
/// (both in global screen coordinates), along a curved path. It is drawn in
/// the app's overlay, above everything, and removes itself when done.
///
/// [onArrive] runs when the comet reaches [to], e.g. to flash the progress
/// line it lands in. With reduce motion on, nothing is drawn and
/// [onArrive] runs straight away.
void fireLightShot(
  BuildContext context, {
  required Offset from,
  required Offset to,
  VoidCallback? onArrive,
}) {
  if (reduceMotionOf(context)) {
    onArrive?.call();
    return;
  }
  final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    onArrive?.call();
    return;
  }
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (BuildContext context) => _LightShot(
      from: from,
      to: to,
      onArrive: onArrive,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _LightShot extends StatefulWidget {
  const _LightShot({
    required this.from,
    required this.to,
    required this.onDone,
    this.onArrive,
  });

  final Offset from;
  final Offset to;
  final VoidCallback onDone;
  final VoidCallback? onArrive;

  @override
  State<_LightShot> createState() => _LightShotState();
}

class _LightShotState extends State<_LightShot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );
  bool _arrived = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (!_arrived && _controller.value >= 0.82) {
        _arrived = true;
        widget.onArrive?.call();
      }
    });
    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ShotPainter(
          animation: _controller,
          from: widget.from,
          to: widget.to,
        ),
      ),
    );
  }
}

class _ShotPainter extends CustomPainter {
  _ShotPainter({
    required this.animation,
    required this.from,
    required this.to,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Offset from;
  final Offset to;

  /// Point on a curved path that bows out to the side.
  Offset _at(double t) {
    final Offset mid = Offset.lerp(from, to, 0.5)!;
    final Offset dir = to - from;
    final Offset normal = Offset(-dir.dy, dir.dx) / (dir.distance + 0.001);
    final Offset control = mid + normal * math.min(140.0, dir.distance * 0.35);
    final double u = 1 - t;
    return from * (u * u) + control * (2 * u * t) + to * (t * t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double v = animation.value;
    final double t = Curves.easeInOutCubic.transform(v.clamp(0.0, 0.85) / 0.85);
    final double fade = v < 0.85 ? 1 : 1 - (v - 0.85) / 0.15;

    // Trail
    for (int k = 12; k >= 0; k--) {
      final double tk = (t - k * 0.025).clamp(0.0, 1.0);
      final double strength = (1 - k / 13) * fade;
      canvas.drawCircle(
        _at(tk),
        2 + 5 * strength,
        Paint()
          ..color = Color.lerp(
            const Color(0xFFF6C4F3),
            AppColors.secondary,
            k / 12,
          )!
              .withValues(alpha: 0.55 * strength)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    // Head
    final Offset head = _at(t);
    canvas.drawCircle(
      head,
      16,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.35 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      head,
      5,
      Paint()..color = Colors.white.withValues(alpha: fade),
    );

    // Splash when it lands
    if (v > 0.82) {
      final double s = (v - 0.82) / 0.18;
      canvas.drawCircle(
        to,
        6 + 22 * s,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * (1 - s)
          ..color = Colors.white.withValues(alpha: 0.8 * (1 - s)),
      );
    }
  }

  @override
  bool shouldRepaint(_ShotPainter old) => old.from != from || old.to != to;
}
