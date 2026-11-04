import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../models/assessment_result_model.dart';
import '../../models/report_model.dart';
import '../../models/trait_score_model.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/result_chart.dart';

/// Picks the [count] traits with the highest (or lowest) tendency.
List<TraitScore> pickTraits(
  List<TraitScore> traits, {
  required bool highest,
  required int count,
}) {
  final List<TraitScore> sorted =
      traits.where((TraitScore t) => t.answered > 0).toList()
        ..sort(
          (TraitScore a, TraitScore b) => highest
              ? b.tendency.compareTo(a.tendency)
              : a.tendency.compareTo(b.tendency),
        );
  return sorted.take(count).toList();
}

/// Glass card with a title, used for each part of a report.
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.frosted = false,
  });

  final String title;
  final IconData? icon;
  final Widget child;
  final bool frosted;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      frosted: frosted,
      padding: const EdgeInsets.all(AppSpacing.lg + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 20, color: context.colors.primary),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(title, style: context.textStyles.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

/// Small rounded label showing a trait level, e.g. "Higher".
class LevelChip extends StatelessWidget {
  const LevelChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: context.textStyles.labelSmall?.copyWith(
          color: context.colors.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A highlighted trait with its level and personalised explanation.
class InsightTile extends StatelessWidget {
  const InsightTile({
    super.key,
    required this.trait,
    required this.report,
    this.isLast = false,
  });

  final TraitScore trait;
  final ReportConfig report;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final TraitText? text = report.traitTexts[trait.traitId];

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(trait.name, style: context.textStyles.titleSmall),
              ),
              LevelChip(label: report.levelLabel(trait.level)),
            ],
          ),
          if (text != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              text.forLevel(trait.level),
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A bullet line with an icon.
class BulletLine extends StatelessWidget {
  const BulletLine({
    super.key,
    required this.text,
    this.icon = Icons.check_circle_outline_rounded,
    this.isLast = false,
  });

  final String text;
  final IconData icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: context.colors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows how this result differs from the previous attempt of the same
/// assessment, plus a trend line when there are several attempts.
class ComparisonCard extends StatelessWidget {
  const ComparisonCard({
    super.key,
    required this.current,
    required this.earlier,
  });

  final AssessmentResult current;

  /// Earlier attempts of the same assessment, newest first. Not empty.
  final List<AssessmentResult> earlier;

  @override
  Widget build(BuildContext context) {
    final AssessmentResult previous = earlier.first;
    final OverallScore? now = current.overall;
    final OverallScore? before = previous.overall;

    // Oldest to newest, at most the last 8 attempts.
    final List<AssessmentResult> timeline = <AssessmentResult>[
      ...earlier.take(7).toList().reversed,
      current,
    ];

    return ReportCard(
      title: AppStrings.compareTitle,
      icon: Icons.compare_arrows_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Previous attempt: ${Helpers.formatDate(previous.completedAt)}',
            style: context.textStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (now != null && before != null)
            _DeltaRow(
              name: AppStrings.overallScore,
              before: before.value,
              after: now.value,
              bold: true,
            ),
          for (final TraitScore trait in current.traits)
            if (_previousTrait(previous, trait.traitId) != null)
              _DeltaRow(
                name: trait.name,
                before: _previousTrait(previous, trait.traitId)!.percent,
                after: trait.percent,
              ),
          if (now != null && timeline.length >= 2) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              '${AppStrings.compareTrend} (${timeline.length} attempts)',
              style: context.textStyles.labelMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            TrendChart(
              values: <double>[
                for (final AssessmentResult r in timeline)
                  r.overall?.value ?? 0,
              ],
              maxY: now.max,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(AppStrings.compareNote, style: context.textStyles.bodySmall),
        ],
      ),
    );
  }

  static TraitScore? _previousTrait(AssessmentResult result, String id) {
    for (final TraitScore t in result.traits) {
      if (t.traitId == id) return t;
    }
    return null;
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({
    required this.name,
    required this.before,
    required this.after,
    this.bold = false,
  });

  final String name;
  final double before;
  final double after;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final int delta = after.round() - before.round();
    final IconData icon = delta > 0
        ? Icons.arrow_upward_rounded
        : delta < 0
            ? Icons.arrow_downward_rounded
            : Icons.remove_rounded;
    final TextStyle? style = bold
        ? context.textStyles.titleSmall
        : context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurface,
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(name, style: style)),
          Text(
            '${before.round()} → ${after.round()}',
            style: context.textStyles.labelMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(icon, size: 16, color: context.colors.primary),
          SizedBox(
            width: 34,
            child: Text(
              delta > 0 ? '+$delta' : '$delta',
              textAlign: TextAlign.end,
              style: context.textStyles.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
