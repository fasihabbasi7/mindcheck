import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';

/// Support information shown when someone reports thoughts of self-harm
/// (PHQ-9 question 9). It appears under the question as soon as the
/// answer is chosen, and again at the top of the report.
///
/// The helpline text is selectable so it can be copied into the dialler.
class SafetySupportCard extends StatelessWidget {
  const SafetySupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final TextTheme text = context.textStyles;
    final Color foreground = colors.onTertiaryContainer;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.tertiary.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.favorite_rounded, color: foreground),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    AppStrings.safetyTitle,
                    style: text.titleMedium?.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.safetyBody,
              style: text.bodyMedium?.copyWith(color: foreground),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.safetyEmergency,
              style: text.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.safetyHelplinesTitle.toUpperCase(),
              style: text.labelSmall?.copyWith(
                color: foreground,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final String line in const <String>[
              AppStrings.safetyHelplinePakistan,
              AppStrings.safetyHelplineWorld,
            ])
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.call_rounded, size: 18, color: foreground),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SelectableText(
                        line,
                        style: text.bodyMedium?.copyWith(color: foreground),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
