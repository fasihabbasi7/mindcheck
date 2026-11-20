import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../hero_brain.dart';
import 'reveal.dart';

/// "Brain scan" for a report: the brain picture with one glowing region per
/// trait. Regions switch on one after another (at [start], then every
/// [step]), glow brighter for higher scores, and are joined by lines of
/// light that draw themselves across the brain.
///
/// The positions are decorative: they do not claim that a trait lives in
/// that part of the brain.
class BrainScan extends StatefulWidget {
  const BrainScan({
    super.key,
    required this.levels,
    this.start = Duration.zero,
    this.step = const Duration(milliseconds: 140),
    this.height = 170,
  });

  /// One value per trait, 0 to 100.
  final List<double> levels;
  final Duration start;
  final Duration step;
  final double height;

  @override
  State<BrainScan> createState() => _BrainScanState();
}

class _BrainScanState extends State<BrainScan>
    with SingleTickerProviderStateMixin {
  static const Duration _glowIn = Duration(milliseconds: 600);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.start +
        widget.step * math.max(widget.levels.length, 1) +
        _glowIn,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotionOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double h = widget.height;
    final double w = h * HeroBrain.imageAspect;

    return ExcludeSemantics(
      child: Center(
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Opacity(
                opacity: 0.9,
                child: Image.asset(HeroBrain.asset, fit: BoxFit.contain),
              ),
              CustomPaint(
                painter: _ScanPainter(
                  animation: _controller,
                  levels: widget.levels,
                  start: widget.start,
                  step: widget.step,
                  glowIn: _glowIn,
                  total: _controller.duration!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanPainter extends CustomPainter {
  _ScanPainter({
    required this.animation,
    required this.levels,
    required this.start,
    required this.step,
    required this.glowIn,
    required this.total,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<double> levels;
  final Duration start;
  final Duration step;
  final Duration glowIn;
  final Duration total;

  // Spots on the brain picture, as fractions of its width and height.
  static const List<Offset> _spots = <Offset>[
    Offset(0.36, 0.30),
    Offset(0.50, 0.19),
    Offset(0.64, 0.29),
    Offset(0.70, 0.47),
    Offset(0.58, 0.58),
    Offset(0.42, 0.58),
    Offset(0.30, 0.47),
    Offset(0.50, 0.40),
  ];

  static const List<Color> _colours = <Color>[
    Color(0xFFF6C4F3),
    AppColors.secondary,
    Color(0xFFA8D8F5),
    Color(0xFFFFDDA6),
  ];

  /// 0..1 how far trait [i] has switched on.
  double _on(int i) {
    final double ms = animation.value * total.inMilliseconds;
    final double begin = (start + step * i).inMilliseconds.toDouble();
    return ((ms - begin) / glowIn.inMilliseconds).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final int n = math.min(levels.length, _spots.length);
    Offset at(int i) =>
        Offset(_spots[i].dx * size.width, _spots[i].dy * size.height);

    // Lines of light joining each region to the next.
    for (int i = 1; i < n; i++) {
      final double grow = Curves.easeOutCubic.transform(_on(i));
      if (grow <= 0) continue;
      final Offset a = at(i - 1);
      final Offset b = Offset.lerp(a, at(i), grow)!;
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.85),
      );
    }

    // Glowing regions: bigger and brighter for higher scores.
    for (int i = 0; i < n; i++) {
      final double on = Curves.easeOutBack.transform(_on(i));
      if (on <= 0) continue;
      final double level = (levels[i] / 100).clamp(0.0, 1.0);
      final Offset p = at(i);
      final Color colour = _colours[i % _colours.length];
      final double r = size.height * (0.07 + 0.09 * level) * on;

      canvas.drawCircle(
        p,
        r * 1.8,
        Paint()
          ..color = colour.withValues(
            alpha: (0.25 + 0.45 * level) * on.clamp(0.0, 1.0),
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.9),
      );
      canvas.drawCircle(
        p,
        math.max(2.5, r * 0.32),
        Paint()..color = Colors.white.withValues(alpha: on.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_ScanPainter old) => old.levels != levels;
}
