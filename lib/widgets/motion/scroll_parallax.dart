import 'package:flutter/material.dart';

import 'reveal.dart';

/// Moves its child more slowly than the page while the page scrolls, so it
/// seems to sit further back (a "parallax" effect). The child also shrinks
/// very slightly as it moves away.
///
/// Must be placed inside a scrolling list. Outside one, or with reduce
/// motion on, the child is shown unchanged.
class ScrollParallax extends StatelessWidget {
  const ScrollParallax({
    super.key,
    required this.child,
    this.factor = 0.35,
    this.maxScroll = 500,
  });

  final Widget child;

  /// 0 = scrolls normally, 1 = stays fixed on screen.
  final double factor;

  /// The effect stops after this many pixels of scrolling.
  final double maxScroll;

  @override
  Widget build(BuildContext context) {
    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    if (scrollable == null || reduceMotionOf(context)) return child;
    final ScrollPosition position = scrollable.position;

    return AnimatedBuilder(
      animation: position,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double pixels = position.hasPixels
            ? position.pixels.clamp(0.0, maxScroll)
            : 0.0;
        return Transform.translate(
          offset: Offset(0, pixels * factor),
          child: Transform.scale(
            scale: 1 - pixels / maxScroll * 0.08,
            child: child,
          ),
        );
      },
    );
  }
}
