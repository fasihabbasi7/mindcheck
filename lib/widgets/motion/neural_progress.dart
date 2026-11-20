import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import 'reveal.dart';

/// Progress shown as a glowing nerve: a gently waving line that fills with
/// light, with "synapse" dots that switch on as you pass them and a bright
/// head that pulses. Each time [pulse] changes, a flash runs along the
/// filled part, as if a signal just arrived.
class NeuralProgress extends StatefulWidget {
  const NeuralProgress({
    super.key,
    required this.value,
    this.pulse = 0,
    this.height = 28,
    this.nodes = 10,
  });

  /// 0.0 to 1.0
  final double value;

  /// Change this number to fire a flash (e.g. after each answer).
  final int pulse;
  final double height;

  /// How many synapse dots sit along the line.
  final int nodes;

  /// Where the head of the line is for [fraction], in this widget's own
  /// coordinates. Used to aim the light that flies in from an answer.
  static Offset headAt(Size size, double fraction) {
    final double x = _pad + (size.width - _pad * 2) * fraction.clamp(0.0, 1.0);
    return Offset(x, _yAt(x, size));
  }

  static const double _pad = 8;

  static double _yAt(double x, Size size) =>
      size.height / 2 + math.sin(x / size.width * math.pi * 3) * size.height * 0.18;

  @override
  State<NeuralProgress> createState() => _NeuralProgressState();
}

class _NeuralProgressState extends State<NeuralProgress>
    with TickerProviderStateMixin {
  // Smoothly moves the fill to the new value.
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late Animation<double> _fillValue = AlwaysStoppedAnimation<double>(
    widget.value,
  );

  // The travelling flash after each answer.
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  // Slow breathing glow on the head.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotionOf(context)) {
      _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeuralProgress old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _fillValue = Tween<double>(
        begin: _fillValue.value,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _fill, curve: Curves.easeOutCubic));
      _fill.forward(from: 0);
    }
    if (old.pulse != widget.pulse && !reduceMotionOf(context)) {
      _flash.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fill.dispose();
    _flash.dispose();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double shown = widget.value.clamp(0.0, 1.0);
    return Semantics(
      label: 'Progress',
      value: '${(shown * 100).round()} percent',
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: CustomPaint(
          painter: _NervePainter(
            fill: _fillValue,
            flash: _flash,
            breath: _breath,
            nodes: widget.nodes,
            track: context.colors.primary.withValues(alpha: 0.16),
            isDark: context.isDarkMode,
            repaint: Listenable.merge(<Listenable>[_fill, _flash, _breath]),
          ),
        ),
      ),
    );
  }
}

class _NervePainter extends CustomPainter {
  _NervePainter({
    required this.fill,
    required this.flash,
    required this.breath,
    required this.nodes,
    required this.track,
    required this.isDark,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final Animation<double> fill;
  final Animation<double> flash;
  final Animation<double> breath;
  final int nodes;
  final Color track;
  final bool isDark;

  Path _path(Size size, double upTo) {
    const double pad = NeuralProgress._pad;
    final double end = pad + (size.width - pad * 2) * upTo;
    final Path path = Path()..moveTo(pad, NeuralProgress._yAt(pad, size));
    for (double x = pad; x <= end; x += 3) {
      path.lineTo(x, NeuralProgress._yAt(x, size));
    }
    path.lineTo(end, NeuralProgress._yAt(end, size));
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double value = fill.value.clamp(0.0, 1.0);
    const double pad = NeuralProgress._pad;

    // Unlit track
    canvas.drawPath(
      _path(size, 1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = track,
    );
    if (value <= 0) {
      _drawNodes(canvas, size, 0);
      return;
    }

    final Path lit = _path(size, value);
    final Rect bounds = Offset.zero & size;
    const LinearGradient gradient = LinearGradient(
      colors: <Color>[AppColors.secondary, AppColors.primary, Color(0xFFE58BD8)],
    );

    // Soft glow under the lit line
    canvas.drawPath(
      lit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..shader = gradient.createShader(bounds)
        ..color = Colors.white.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // The lit line itself
    canvas.drawPath(
      lit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..shader = gradient.createShader(bounds),
    );

    _drawNodes(canvas, size, value);

    // Flash: a bright spot racing from the start to the head.
    if (flash.isAnimating || (flash.value > 0 && flash.value < 1)) {
      final double f = Curves.easeInOutCubic.transform(flash.value);
      final double x = pad + (size.width - pad * 2) * value * f;
      final Offset p = Offset(x, NeuralProgress._yAt(x, size));
      final double fade = math.sin(flash.value * math.pi);
      canvas.drawCircle(
        p,
        10,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9 * fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }

    // Head: breathing halo plus a bright core.
    final Offset head = NeuralProgress.headAt(size, value);
    final double b = breath.value;
    canvas.drawCircle(
      head,
      9 + 4 * b,
      Paint()
        ..color = (isDark ? AppColors.secondary : AppColors.primary)
            .withValues(alpha: 0.35 + 0.2 * b)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(head, 4.5, Paint()..color = Colors.white);
  }

  void _drawNodes(Canvas canvas, Size size, double value) {
    const double pad = NeuralProgress._pad;
    for (int i = 0; i <= nodes; i++) {
      final double f = i / nodes;
      final double x = pad + (size.width - pad * 2) * f;
      final Offset p = Offset(x, NeuralProgress._yAt(x, size));
      final bool on = f <= value + 0.0001;
      if (on) {
        canvas.drawCircle(
          p,
          5,
          Paint()
            ..color = AppColors.secondary.withValues(alpha: 0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
      canvas.drawCircle(
        p,
        on ? 2.6 : 2,
        Paint()..color = on ? Colors.white : track.withValues(alpha: 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_NervePainter old) =>
      old.track != track || old.isDark != isDark || old.nodes != nodes;
}
