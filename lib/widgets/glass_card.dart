import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_theme.dart';
import '../utils/constants.dart';
import 'motion/glow_edge.dart';
import 'motion/tilt_card.dart';

/// MindCurio's "glowing glass" card, used on every screen:
///
///  * a see-through glass fill that is brighter at the top, like light
///    falling on glass
///  * a thin edge whose lavender, rose and sky colours slowly travel round
///    the card, with a bright highlight along the top
///  * a soft coloured glow underneath instead of a grey shadow
///
/// Pass [onTap] to make it tappable; tappable cards also tilt in 3D while
/// touched (turn off with [tilt]: false). [accent] tints the edge and glow,
/// e.g. with a test's own colour. [color] replaces the glass fill.
///
/// With [frosted] the card becomes real frosted glass: whatever is behind it
/// is blurred through it. It costs a little more to draw, so use it for a
/// few hero cards rather than long lists.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.onTap,
    this.color,
    this.accent,
    this.frosted = false,
    this.glow = true,
    this.tilt,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  /// Optional fill colour instead of glass.
  final Color? color;

  /// Colour for the edge and the glow underneath.
  final Color? accent;
  final bool frosted;

  /// The coloured glow underneath. Turn off for cards inside other cards.
  final bool glow;

  /// 3D tilt on touch. Defaults to on for tappable cards.
  final bool? tilt;

  @override
  Widget build(BuildContext context) {
    final Widget card = _buildCard(context);
    if (tilt ?? onTap != null) {
      return TiltCard(radius: radius, child: card);
    }
    return card;
  }

  Widget _buildCard(BuildContext context) {
    final MindColors mind = context.mind;
    final bool dark = context.isDarkMode;
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    final Color tint = accent ?? AppColors.primary;

    final Widget content = InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(padding: padding, child: child),
    );

    // Glass fill: brighter at the top, with a hint of the accent colour.
    final Gradient fill = color != null
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color.alphaBlend(Colors.white.withValues(alpha: 0.25), color!),
              color!,
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? <Color>[
                    Color.alphaBlend(
                      Colors.white.withValues(alpha: 0.10),
                      mind.glassFill.withValues(alpha: 0.6),
                    ),
                    Color.alphaBlend(
                      tint.withValues(alpha: 0.10),
                      mind.glassFill.withValues(alpha: 0.55),
                    ),
                    mind.glassFill.withValues(alpha: 0.5),
                  ]
                : <Color>[
                    Colors.white.withValues(alpha: frosted ? 0.72 : 0.92),
                    Colors.white.withValues(alpha: frosted ? 0.48 : 0.74),
                    Color.alphaBlend(
                      tint.withValues(alpha: 0.07),
                      Colors.white.withValues(alpha: frosted ? 0.4 : 0.66),
                    ),
                  ],
            stops: const <double>[0, 0.55, 1],
          );

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: fill,
      ),
      child: Material(type: MaterialType.transparency, child: content),
    );

    if (frosted) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: surface,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: glow
            ? <BoxShadow>[
                // Coloured glow
                BoxShadow(
                  color: tint.withValues(alpha: dark ? 0.28 : 0.16),
                  blurRadius: 30,
                  spreadRadius: -4,
                  offset: const Offset(0, 14),
                ),
                // Soft contact shadow
                BoxShadow(
                  color: mind.cardShadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: GlowEdge(
        radius: radius,
        accent: accent,
        child: ClipRRect(borderRadius: borderRadius, child: surface),
      ),
    );
  }
}

/// A small glossy gradient square with a white icon and a soft glow, used
/// for card headers so every card has a bright focal point.
class GlowIcon extends StatelessWidget {
  const GlowIcon({
    super.key,
    required this.icon,
    this.size = 36,
    this.colors,
  });

  final IconData icon;
  final double size;

  /// Gradient colours (top-left to bottom-right). Defaults to lavender.
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final List<Color> c =
        colors ?? const <Color>[AppColors.secondary, AppColors.primary];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: c,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: c.last.withValues(alpha: 0.4),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: size * 0.06,
            left: size * 0.14,
            right: size * 0.14,
            height: size * 0.38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.3),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Icon(icon, size: size * 0.52, color: Colors.white),
        ],
      ),
    );
  }
}
