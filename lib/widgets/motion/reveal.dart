import 'dart:async';

import 'package:flutter/material.dart';

/// True when the user has asked the system to reduce motion.
bool reduceMotionOf(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Fades and slides its child up into place after [delay].
///
/// Use a growing delay on a list of sections to make them arrive one after
/// another ("staggered"). With reduce motion turned on, the child simply
/// appears.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 550),
    this.offset = 22,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// How far below its final position the child starts, in pixels.
  final double offset;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _progress =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotionOf(context)) {
      _controller.value = 1;
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _progress,
      child: AnimatedBuilder(
        animation: _progress,
        child: widget.child,
        builder: (BuildContext context, Widget? child) => Transform.translate(
          offset: Offset(0, (1 - _progress.value) * widget.offset),
          child: child,
        ),
      ),
    );
  }
}

/// Animates a number from 0 to 1 after [delay] and hands it to [builder].
///
/// Used for the score count-up and the bars that fill one by one.
/// [onComplete] runs once when the animation finishes.
class DelayedProgress extends StatefulWidget {
  const DelayedProgress({
    super.key,
    required this.builder,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    this.onComplete,
  });

  final Widget Function(BuildContext context, double progress) builder;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onComplete;

  @override
  State<DelayedProgress> createState() => _DelayedProgressState();
}

class _DelayedProgressState extends State<DelayedProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _progress =
      CurvedAnimation(parent: _controller, curve: widget.curve);
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) widget.onComplete?.call();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotionOf(context)) {
      _controller.value = 1;
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (BuildContext context, _) =>
          widget.builder(context, _progress.value),
    );
  }
}
