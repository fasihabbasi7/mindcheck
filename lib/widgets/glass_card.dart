import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../utils/constants.dart';
import 'motion/tilt_card.dart';

/// A rounded, semi-transparent card, like the stat cards in the design
/// reference. Pass [onTap] to make it tappable. Tappable cards tilt
/// gently in 3D while touched (turn off with [tilt]: false).
///
/// With [frosted] set to true the card becomes real frosted glass: whatever
/// is behind it (the brain, the background glow) is blurred through it.
/// Frosted cards cost a little more to draw, so use them for a few hero
/// cards rather than for long lists.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.onTap,
    this.color,
    this.frosted = false,
    this.tilt,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  /// Optional fill colour (not used when [frosted] is true).
  final Color? color;
  final bool frosted;

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
    final BorderRadius borderRadius = BorderRadius.circular(radius);

    final Widget content = InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(padding: padding, child: child),
    );

    if (!frosted) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: mind.cardShadow,
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: color ?? mind.glassFill,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(color: mind.glassBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: content,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: mind.cardShadow.withValues(alpha: mind.cardShadow.a * 0.6),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[mind.frostTop, mind.frostBottom],
              ),
              border: Border.all(
                color: mind.glassBorder.withValues(
                  alpha: context.isDarkMode ? 0.18 : 0.8,
                ),
              ),
            ),
            child: Material(type: MaterialType.transparency, child: content),
          ),
        ),
      ),
    );
  }
}
