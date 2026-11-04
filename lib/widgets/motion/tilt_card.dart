import 'package:flutter/material.dart';

import 'reveal.dart';

/// Gives its child a subtle 3D tilt towards the finger while it is touched,
/// with a soft light reflection, then springs back when released.
///
/// It only listens to touches, so taps, long-presses and scrolling still
/// work exactly as before. If the finger moves more than a little (the user
/// is scrolling), the card straightens again.
class TiltCard extends StatefulWidget {
  const TiltCard({
    super.key,
    required this.child,
    this.radius = 24,
    this.maxAngle = 0.10,
  });

  final Widget child;

  /// Corner radius of the child, so the light reflection matches it.
  final double radius;

  /// Largest tilt in radians (0.10 ≈ 6 degrees).
  final double maxAngle;

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  /// Finger position from -1 to 1 on each axis; zero means flat.
  Offset _tilt = Offset.zero;
  bool _pressed = false;
  Offset? _downAt;

  void _update(Offset local) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final Size size = box.size;
    setState(() {
      _pressed = true;
      _tilt = Offset(
        (local.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
        (local.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
      );
    });
  }

  void _release() {
    _downAt = null;
    if (!_pressed && _tilt == Offset.zero) return;
    setState(() {
      _pressed = false;
      _tilt = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotionOf(context)) return widget.child;

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        _downAt = event.localPosition;
        _update(event.localPosition);
      },
      onPointerMove: (PointerMoveEvent event) {
        final Offset? start = _downAt;
        if (start == null) return;
        // Moving far means scrolling, not pressing: straighten up.
        if ((event.localPosition - start).distance > 14) {
          _release();
        } else {
          _update(event.localPosition);
        }
      },
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(end: _tilt),
        duration: Duration(milliseconds: _pressed ? 140 : 420),
        curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
        builder: (BuildContext context, Offset tilt, Widget? child) {
          final double strength = tilt.distance.clamp(0.0, 1.0);
          final Matrix4 transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0012) // perspective
            ..rotateX(-tilt.dy * widget.maxAngle)
            ..rotateY(tilt.dx * widget.maxAngle);

          return Transform.scale(
            scale: 1 - 0.025 * strength,
            child: Transform(
              alignment: Alignment.center,
              transform: transform,
              child: Stack(
                children: <Widget>[
                  child!,
                  // Soft light reflection that follows the finger.
                  if (strength > 0.01)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(widget.radius),
                            gradient: RadialGradient(
                              center: Alignment(tilt.dx, tilt.dy),
                              radius: 1.1,
                              colors: <Color>[
                                Colors.white.withValues(
                                  alpha: 0.16 * strength,
                                ),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
