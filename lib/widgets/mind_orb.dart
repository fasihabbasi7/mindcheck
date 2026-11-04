import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_theme.dart';
import '../utils/constants.dart';

/// MindCheck's hero illustration: a glowing "neural sphere".
///
/// Layers (back to front):
///  1. a breathing glow
///  2. the back halves of two tilted orbits
///  3. a rotating aurora ring
///  4. a glossy purple sphere with a pulsing neural network inside it
///  5. the front halves of the orbits with travelling light dots
///
/// Everything is drawn in code with a [CustomPainter], so no image file is
/// needed. Pass an [icon] to show a symbol in the centre (the network then
/// fades into the background). Animation stops automatically when the user
/// has "reduce motion" turned on.
class MindOrb extends StatefulWidget {
  const MindOrb({
    super.key,
    this.size = 200,
    this.icon,
    this.animate = true,
  });

  /// Diameter of the sphere itself. The widget is 1.6x this size so the
  /// glow, ring and orbits have room.
  final double size;
  final IconData? icon;
  final bool animate;

  @override
  State<MindOrb> createState() => _MindOrbState();
}

class _MindOrbState extends State<MindOrb> with SingleTickerProviderStateMixin {
  // One 12-second loop drives every moving part. All motions use whole-number
  // multiples of this loop, so the animation repeats without any jump.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
    value: 0.15,
  );

  // The node layout is the same for every orb, so build it only once.
  static final _NeuralNetwork _network = _NeuralNetwork.generate();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(MindOrb oldWidget) {
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
    final double box = widget.size * 1.6;
    final Color glow = context.mind.glow;
    final bool isDark = context.isDarkMode;
    final bool hasIcon = widget.icon != null;

    final Widget centre = hasIcon
        ? Center(
            child: Icon(
              widget.icon,
              size: widget.size * 0.36,
              color: Colors.white,
              shadows: <Shadow>[
                Shadow(
                  color: AppColors.primaryDeep.withValues(alpha: 0.7),
                  blurRadius: 18,
                ),
              ],
            ),
          )
        : const SizedBox.expand();

    return Semantics(
      image: true,
      label: 'MindCheck illustration',
      child: RepaintBoundary(
        child: SizedBox(
          width: box,
          height: box,
          child: AnimatedBuilder(
            animation: _controller,
            child: centre,
            builder: (BuildContext context, Widget? child) {
              final double t = _controller.value;
              // Gentle float: 3 up-and-down cycles per loop (every 4 s).
              final double floatY =
                  math.sin(t * 2 * math.pi * 3) * widget.size * 0.03;

              return Transform.translate(
                offset: Offset(0, floatY),
                child: CustomPaint(
                  painter: _OrbPainter(
                    t: t,
                    network: _network,
                    glow: glow,
                    isDark: isDark,
                    dimNetwork: hasIcon,
                  ),
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Fixed positions of the "neurons" and which ones are connected.
/// Positions are inside a circle of radius 1 and scaled when painting.
class _NeuralNetwork {
  const _NeuralNetwork(this.nodes, this.edges);

  final List<Offset> nodes;
  final List<(int, int)> edges;

  factory _NeuralNetwork.generate() {
    // A fixed seed gives the same pleasant layout on every launch.
    final math.Random random = math.Random(11);
    final List<Offset> nodes = <Offset>[];

    int attempts = 0;
    while (nodes.length < 20 && attempts < 3000) {
      attempts++;
      final Offset point = Offset(
        random.nextDouble() * 2 - 1,
        random.nextDouble() * 2 - 1,
      );
      if (point.distance > 0.95) continue;
      // Keep nodes spread out.
      if (nodes.any((Offset n) => (n - point).distance < 0.34)) continue;
      nodes.add(point);
    }

    final List<(int, int)> edges = <(int, int)>[];
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        if ((nodes[i] - nodes[j]).distance < 0.6) edges.add((i, j));
      }
    }
    return _NeuralNetwork(nodes, edges);
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.t,
    required this.network,
    required this.glow,
    required this.isDark,
    required this.dimNetwork,
  });

  /// Animation progress, 0.0 to 1.0.
  final double t;
  final _NeuralNetwork network;
  final Color glow;
  final bool isDark;
  final bool dimNetwork;

  static const double _tau = 2 * math.pi;
  static const Color _pink = Color(0xFFF3B8F0);
  static const Color _cyan = Color(0xFF9FD8FF);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.shortestSide / 1.6 / 2; // sphere radius
    final Rect sphere = Rect.fromCircle(center: c, radius: r);
    final double breathe = 0.5 + 0.5 * math.sin(t * _tau * 4);

    // 1. Breathing glow
    final double glowR = r * (1.7 + 0.08 * breathe);
    canvas.drawCircle(
      c,
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[glow, glow.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: glowR)),
    );

    // 2. Back halves of the orbits (behind the sphere)
    _drawOrbits(canvas, c, r, front: false);

    // 3. Rotating aurora ring: a soft blurred band plus a thin sharp line
    final double ringR = r * 1.2;
    final Rect ringRect = Rect.fromCircle(center: c, radius: ringR);
    final Shader sweep = SweepGradient(
      colors: <Color>[
        AppColors.primary.withValues(alpha: 0),
        AppColors.secondary,
        _pink,
        _cyan,
        AppColors.primary.withValues(alpha: 0),
      ],
      stops: const <double>[0.0, 0.35, 0.6, 0.8, 1.0],
      transform: GradientRotation(t * _tau * 2),
    ).createShader(ringRect);
    canvas.drawCircle(
      c,
      ringR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12
        ..shader = sweep
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.08),
    );
    canvas.drawCircle(
      c,
      ringR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, r * 0.018)
        ..shader = sweep,
    );

    // 4a. Soft shadow under the sphere
    canvas.drawCircle(
      c.translate(0, r * 0.18),
      r * 0.9,
      Paint()
        ..color = AppColors.primaryDeep.withValues(alpha: isDark ? 0.55 : 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.25),
    );

    // 4b. Sphere body
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.45),
          radius: 1.05,
          colors: <Color>[
            Color(0xFFEDE8FF),
            Color(0xFFB7A8F6),
            AppColors.primary,
            Color(0xFF3E2F9E),
          ],
          stops: <double>[0.0, 0.3, 0.72, 1.0],
        ).createShader(sphere),
    );

    // 4c. Neural network, clipped to the sphere
    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));
    _drawNetwork(canvas, c, r);
    canvas.restore();

    // 4d. Darker edge for depth
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          colors: <Color>[Color(0x00000000), Color(0x402A1E7A)],
          stops: <double>[0.72, 1.0],
        ).createShader(sphere),
    );

    // 4e. Rim light along the bottom-right edge
    canvas.drawArc(
      sphere.deflate(r * 0.04),
      math.pi * 0.05,
      math.pi * 0.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.03
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.02),
    );

    // 4f. Glassy highlight, top-left
    final Offset spot = c + Offset(-r * 0.36, -r * 0.42);
    final double spotR = r * 0.34;
    canvas.drawCircle(
      spot,
      spotR,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0.65),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: spot, radius: spotR)),
    );

    // 5. Front halves of the orbits (in front of the sphere)
    _drawOrbits(canvas, c, r, front: true);
  }

  void _drawNetwork(Canvas canvas, Offset c, double r) {
    final double strength = dimNetwork ? 0.45 : 1.0;
    final double sway = math.sin(t * _tau) * 0.12; // slow rotation
    final double cosA = math.cos(sway);
    final double sinA = math.sin(sway);

    // Current position of every node (each drifts slightly).
    final List<Offset> points = <Offset>[
      for (int i = 0; i < network.nodes.length; i++)
        () {
          final Offset n = network.nodes[i];
          final double x = n.dx + math.sin(t * _tau * 2 + i) * 0.03;
          final double y = n.dy + math.cos(t * _tau * 2 + i * 1.3) * 0.03;
          return c +
              Offset(
                (x * cosA - y * sinA) * r * 0.78,
                (x * sinA + y * cosA) * r * 0.78,
              );
        }(),
    ];

    // Connections
    final Paint line = Paint()
      ..strokeWidth = math.max(1.0, r * 0.012)
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.28 * strength);
    for (final (int a, int b) in network.edges) {
      canvas.drawLine(points[a], points[b], line);
    }

    // Signals travelling along every third connection
    for (int k = 0; k < network.edges.length; k += 3) {
      final (int a, int b) = network.edges[k];
      final double progress = (t * 3 + k * 0.137) % 1.0;
      final Offset p = Offset.lerp(points[a], points[b], progress)!;
      final double fade = math.sin(progress * math.pi) * strength;

      canvas.drawCircle(
        p,
        r * 0.05,
        Paint()
          ..color = _cyan.withValues(alpha: 0.55 * fade)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.04),
      );
      canvas.drawCircle(
        p,
        r * 0.018,
        Paint()..color = Colors.white.withValues(alpha: fade),
      );
    }

    // Neurons, each pulsing at its own moment
    for (int i = 0; i < points.length; i++) {
      final double pulse = 0.5 + 0.5 * math.sin(t * _tau * 3 + i * 0.9);
      canvas.drawCircle(
        points[i],
        r * (0.04 + 0.03 * pulse),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3 * pulse * strength)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.03),
      );
      canvas.drawCircle(
        points[i],
        r * (0.022 + 0.008 * pulse),
        Paint()
          ..color =
              Colors.white.withValues(alpha: (0.7 + 0.3 * pulse) * strength),
      );
    }
  }

  void _drawOrbits(
    Canvas canvas,
    Offset c,
    double r, {
    required bool front,
  }) {
    const List<double> tilts = <double>[-0.42, 0.5];
    const List<int> speeds = <int>[2, -3];
    const List<Color> dotColors = <Color>[_pink, _cyan];
    final Color lineColor = isDark ? Colors.white : AppColors.primary;

    for (int o = 0; o < tilts.length; o++) {
      final double a = r * 1.42; // half width
      final double b = r * 0.36; // half height

      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(tilts[o]);

      // The lower half of each ellipse is "in front" of the sphere.
      canvas.drawArc(
        Rect.fromCenter(center: Offset.zero, width: a * 2, height: b * 2),
        front ? 0 : math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, r * 0.01)
          ..color = lineColor.withValues(alpha: front ? 0.45 : 0.2),
      );

      final double angle = t * _tau * speeds[o] + o * 2.1;
      final bool dotInFront = math.sin(angle) > 0;
      if (dotInFront == front) {
        final Offset dot = Offset(a * math.cos(angle), b * math.sin(angle));
        canvas.drawCircle(
          dot,
          r * 0.09,
          Paint()
            ..color = dotColors[o].withValues(alpha: 0.65)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.06),
        );
        canvas.drawCircle(dot, r * 0.035, Paint()..color = Colors.white);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.glow != glow ||
        oldDelegate.isDark != isDark ||
        oldDelegate.dimNetwork != dimNetwork;
  }
}

/// A small frosted chip that floats next to the [MindOrb],
/// like the "Stress Level" / "Focus Power" cards in the design reference.
class OrbitChip extends StatelessWidget {
  const OrbitChip({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final MindColors mind = context.mind;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: mind.glassFill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: mind.glassBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: mind.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: context.colors.primary),
            ),
            const SizedBox(width: 8),
            Text(label, style: context.textStyles.labelMedium),
          ],
        ),
      ),
    );
  }
}
