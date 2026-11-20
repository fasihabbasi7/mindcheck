import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../utils/constants.dart';
import 'motion/glow_edge.dart';

/// One tappable answer choice on the question screen.
class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.shaded = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Only used by the ASRS screener, whose official form shades some
  /// answer boxes. Shown as a slightly darker background.
  final bool shaded;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final MindColors mind = context.mind;

    final bool dark = context.isDarkMode;
    // Glass when idle; a glowing lavender gradient when chosen.
    final Gradient fill = selected
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.alphaBlend(
                colors.primary.withValues(alpha: dark ? 0.35 : 0.14),
                mind.glassFill,
              ),
              Color.alphaBlend(
                colors.secondary.withValues(alpha: dark ? 0.30 : 0.26),
                mind.glassFill,
              ),
            ],
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: shaded
                ? <Color>[
                    colors.surfaceContainerHighest,
                    colors.surfaceContainerHighest.withValues(alpha: 0.8),
                  ]
                : <Color>[
                    Color.alphaBlend(
                      Colors.white.withValues(alpha: dark ? 0.08 : 0.5),
                      mind.glassFill,
                    ),
                    mind.glassFill.withValues(alpha: dark ? 0.7 : 0.75),
                  ],
          );

    final BorderRadius radius = BorderRadius.circular(AppRadius.md);
    final Widget box = AnimatedContainer(
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, selected ? -2 : 0, 0),
      decoration: BoxDecoration(
        gradient: fill,
        borderRadius: radius,
        border: Border.all(
          color: selected
              ? Colors.transparent
              : (dark ? mind.glassBorder : Colors.white),
          width: 1.2,
        ),
        boxShadow: selected
            ? <BoxShadow>[
                BoxShadow(
                  color: colors.primary.withValues(alpha: dark ? 0.45 : 0.3),
                  blurRadius: 22,
                  spreadRadius: -2,
                  offset: const Offset(0, 8),
                ),
              ]
            : <BoxShadow>[
                BoxShadow(
                  color: mind.cardShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  _RadioDot(selected: selected),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      label,
                      style: context.textStyles.titleSmall?.copyWith(
                        color: selected
                            ? (dark ? colors.onSurface : colors.primary)
                            : colors.onSurface,
                        fontWeight: selected ? FontWeight.w700 : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      // The chosen answer gets the shimmering glow edge.
      child: GlowEdge(
        radius: AppRadius.md,
        strength: selected ? 1 : 0,
        child: box,
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;

    return AnimatedContainer(
      duration: AppDurations.fast,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colors.primary : Colors.transparent,
        border: Border.all(
          color: selected ? colors.primary : colors.onSurfaceVariant,
          width: 1.6,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 16, color: colors.onPrimary)
          : null,
    );
  }
}
