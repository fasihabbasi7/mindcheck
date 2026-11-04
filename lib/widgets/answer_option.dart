import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../utils/constants.dart';

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

    final Color background = selected
        ? colors.primaryContainer
        : shaded
            ? colors.surfaceContainerHighest
            : mind.glassFill;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? colors.primary : mind.glassBorder,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
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
                              ? colors.onPrimaryContainer
                              : colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
