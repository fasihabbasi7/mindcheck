import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../data/helplines.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';

/// Support information shown when someone reports thoughts of self-harm
/// (PHQ-9 question 9). It appears under the question as soon as the
/// answer is chosen, and again at the top of the report.
///
/// It shows the helpline for the phone's region first (when we list one),
/// then findahelpline.com, which covers every country. Other countries'
/// lines can be opened below. Numbers are selectable so they can be copied.
class SafetySupportCard extends StatefulWidget {
  const SafetySupportCard({super.key});

  @override
  State<SafetySupportCard> createState() => _SafetySupportCardState();
}

class _SafetySupportCardState extends State<SafetySupportCard> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final TextTheme text = context.textStyles;
    final Color foreground = colors.onTertiaryContainer;
    final Helpline? local = helplineForThisDevice();
    final List<Helpline> others =
        helplines.where((Helpline h) => h != local).toList();

    Widget line(String value, {IconData icon = Icons.call_rounded}) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SelectableText(
                value,
                style: text.bodyMedium?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      );
    }

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
            if (local != null) line(local.line),
            line(AppStrings.safetyHelplineWorld, icon: Icons.public_rounded),

            // Other countries, folded away so the card stays short.
            TextButton.icon(
              onPressed: () => setState(() => _showAll = !_showAll),
              style: TextButton.styleFrom(
                foregroundColor: foreground,
                padding: EdgeInsets.zero,
              ),
              icon: Icon(
                _showAll
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
              ),
              label: Text(
                _showAll
                    ? AppStrings.safetyHideCountries
                    : AppStrings.safetyShowCountries,
              ),
            ),
            if (_showAll)
              for (final Helpline h in others) line(h.line),
          ],
        ),
      ),
    );
  }
}
