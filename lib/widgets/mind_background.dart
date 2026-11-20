import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme/app_theme.dart';
import 'motion/aurora_background.dart';
import 'motion/floating_particles.dart';

/// The soft lavender background used behind every screen.
///
/// It draws a vertical gradient plus two blurred "glows" and also makes the
/// status bar icons dark or light depending on the theme.
///
/// A flowing aurora of light moves gently behind every screen (turn off
/// with [aurora]: false). Set [particles] to add slowly drifting specks of
/// light. Use it on a few "showcase" screens (Home, onboarding, results).
class MindBackground extends StatelessWidget {
  const MindBackground({
    super.key,
    required this.child,
    this.particles = false,
    this.aurora = true,
  });

  final Widget child;
  final bool particles;
  final bool aurora;

  // Aurora colours: lavender, rose and sky, brighter in dark mode.
  static const List<Color> _auroraLight = <Color>[
    Color(0xFFB9AEF5),
    Color(0xFFF5BDD9),
    Color(0xFFA8D8F5),
  ];
  static const List<Color> _auroraDark = <Color>[
    Color(0xFF7565D8),
    Color(0xFFB0509A),
    Color(0xFF3A78D8),
  ];

  @override
  Widget build(BuildContext context) {
    final MindColors mind = context.mind;
    final bool isDark = context.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[mind.gradientTop, mind.gradientBottom],
            stops: const <double>[0.0, 0.65],
          ),
        ),
        child: Stack(
          children: <Widget>[
            if (aurora)
              Positioned.fill(
                child: AuroraBackground(
                  colors: isDark ? _auroraDark : _auroraLight,
                  intensity: isDark ? 0.42 : 0.38,
                ),
              ),
            _Glow(
              color: mind.glow,
              size: 340,
              alignment: const Alignment(1.4, -1.1),
            ),
            _Glow(
              color: mind.glow.withValues(alpha: 0.6),
              size: 280,
              alignment: const Alignment(-1.5, 0.15),
            ),
            if (particles)
              Positioned.fill(
                child: FloatingParticles(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : context.colors.primary.withValues(alpha: 0.35),
                ),
              ),
            Positioned.fill(child: child),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.color,
    required this.size,
    required this.alignment,
  });

  final Color color;
  final double size;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: alignment,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[color, color.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
