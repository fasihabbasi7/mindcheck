import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'reveal.dart';

/// Slowly flowing aurora light, drawn by a GPU shader
/// (`shaders/aurora.frag`).
///
/// If the shader cannot be loaded on a phone, nothing is drawn and the
/// normal gradient background shows instead. With reduce motion (or the
/// app's "Reduce effects" switch) the aurora is shown as a still picture.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    required this.colors,
    this.intensity = 0.35,
  });

  /// Three colours, top to bottom.
  final List<Color> colors;
  final double intensity;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  // Loaded once and shared by every screen.
  static Future<ui.FragmentProgram?>? _program;

  static Future<ui.FragmentProgram?> _load() {
    return _program ??= ui.FragmentProgram.fromAsset('shaders/aurora.frag')
        .then<ui.FragmentProgram?>((ui.FragmentProgram p) => p)
        .catchError((Object _) => null);
  }

  ui.FragmentShader? _shader;
  late final Ticker _ticker = createTicker(_onTick);
  final ValueNotifier<double> _time = ValueNotifier<double>(12);

  void _onTick(Duration elapsed) {
    // Start at 12 s so the very first frame already looks "in motion".
    _time.value = 12 + elapsed.inMicroseconds / 1e6;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_load().then((ui.FragmentProgram? program) {
      if (!mounted || program == null) return;
      setState(() => _shader = program.fragmentShader());
    }));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotionOf(context)) {
      if (_ticker.isActive) _ticker.stop();
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shader?.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ui.FragmentShader? shader = _shader;
    if (shader == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _AuroraPainter(
            shader: shader,
            time: _time,
            colors: widget.colors,
            intensity: widget.intensity,
          ),
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({
    required this.shader,
    required this.time,
    required this.colors,
    required this.intensity,
  }) : super(repaint: time);

  final ui.FragmentShader shader;
  final ValueNotifier<double> time;
  final List<Color> colors;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    // The order must match the uniforms in aurora.frag.
    int i = 0;
    shader
      ..setFloat(i++, size.width)
      ..setFloat(i++, size.height)
      ..setFloat(i++, time.value);
    for (int c = 0; c < 3; c++) {
      final Color color = colors[c % colors.length];
      shader
        ..setFloat(i++, color.r)
        ..setFloat(i++, color.g)
        ..setFloat(i++, color.b)
        ..setFloat(i++, color.a);
    }
    shader.setFloat(i, intensity);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.shader != shader ||
      old.intensity != intensity ||
      old.colors != colors;
}
