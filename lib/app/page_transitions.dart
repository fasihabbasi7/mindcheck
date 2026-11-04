import 'package:flutter/material.dart';

/// MindCheck's page transition: the new page fades in while lifting
/// slightly and growing from 96% to full size, and the page underneath
/// sinks back a little. Calm, with a sense of depth.
class MindPageTransition extends StatelessWidget {
  const MindPageTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  /// Drives the page coming in (0 → 1) or going out (1 → 0).
  final Animation<double> animation;

  /// Drives this page when another page is pushed on top of it.
  final Animation<double> secondaryAnimation;
  final Widget child;

  static final Animatable<double> _fadeIn =
      CurveTween(curve: const Interval(0, 0.7, curve: Curves.easeOut));
  static final Animatable<Offset> _lift = Tween<Offset>(
    begin: const Offset(0, 0.03),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));
  static final Animatable<double> _grow = Tween<double>(begin: 0.96, end: 1)
      .chain(CurveTween(curve: Curves.easeOutCubic));
  static final Animatable<double> _sink = Tween<double>(begin: 1, end: 0.97)
      .chain(CurveTween(curve: Curves.easeOutCubic));

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: secondaryAnimation.drive(_sink),
      child: FadeTransition(
        opacity: animation.drive(_fadeIn),
        child: SlideTransition(
          position: animation.drive(_lift),
          child: ScaleTransition(
            scale: animation.drive(_grow),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Lets the theme use [MindPageTransition] for every normal page.
class MindPageTransitionsBuilder extends PageTransitionsBuilder {
  const MindPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return MindPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}
