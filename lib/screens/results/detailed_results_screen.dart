import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../models/assessment_model.dart';
import '../../models/assessment_result_model.dart';
import '../../models/report_model.dart';
import '../../models/trait_score_model.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/result_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/mind_background.dart';
import '../../widgets/result_chart.dart';
import 'result_widgets.dart';

/// Every trait or area explained in detail: what it means, how it may show
/// up for you, a question to reflect on and a practical tip.
class DetailedResultsScreen extends ConsumerWidget {
  const DetailedResultsScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(resultsProvider);
    final AssessmentResult? result =
        ref.read(resultsProvider.notifier).byId(resultId);

    Widget body;
    if (result == null) {
      body = Center(
        child: EmptyState(
          icon: Icons.insights_rounded,
          title: AppStrings.resultNotFoundTitle,
          message: AppStrings.resultNotFoundBody,
          action: SecondaryButton(
            expanded: false,
            label: AppStrings.back,
            onPressed: () => context.pop(),
          ),
        ),
      );
    } else {
      final AssessmentModel? assessment =
          ref.watch(assessmentRepositoryProvider).getById(result.assessmentId);
      body = ref.watch(reportConfigProvider(result.assessmentId)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object e, StackTrace s) => const SizedBox.shrink(),
            data: (ReportConfig report) => _DetailsBody(
              result: result,
              assessment: assessment,
              report: report,
            ),
          );
    }

    return Scaffold(
      body: MindBackground(child: SafeArea(child: body)),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.result,
    required this.assessment,
    required this.report,
  });

  final AssessmentResult result;
  final AssessmentModel? assessment;
  final ReportConfig report;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.textStyles;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.xl,
      ),
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: CircleIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: AppStrings.back,
            onPressed: () => context.pop(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(AppStrings.detailedResults, style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${assessment?.title ?? ''} · '
          '${Helpers.formatDate(result.completedAt)} · '
          '${result.answers.length} answers in '
          '${Helpers.formatDuration(result.durationSeconds)}',
          style: text.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final TraitScore trait in result.traits) ...<Widget>[
          _TraitDetailCard(trait: trait, report: report),
          const SizedBox(height: AppSpacing.md),
        ],
        ReportCard(
          title: AppStrings.howScored,
          icon: Icons.calculate_outlined,
          child: Text(
            report.note,
            style: text.bodyMedium?.copyWith(color: context.colors.onSurface),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (assessment != null)
          ReportCard(
            title: AppStrings.source,
            icon: Icons.menu_book_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(assessment!.sourceName, style: text.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(assessment!.citation, style: text.bodySmall),
                if (assessment!.copyrightNotice != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(assessment!.copyrightNotice!, style: text.bodySmall),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Full explanation of one trait.
class _TraitDetailCard extends StatelessWidget {
  const _TraitDetailCard({required this.trait, required this.report});

  final TraitScore trait;
  final ReportConfig report;

  @override
  Widget build(BuildContext context) {
    final TraitText? text = report.traitTexts[trait.traitId];
    final TextTheme styles = context.textStyles;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TraitBar(
            name: trait.name,
            percent: trait.percent,
            levelLabel: report.levelLabel(trait.level),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(trait.description, style: styles.bodySmall),
          if (text != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            _Labelled(
              icon: Icons.visibility_outlined,
              label: AppStrings.howItShowsUp,
              text: text.forLevel(trait.level),
            ),
            const SizedBox(height: AppSpacing.md),
            _Labelled(
              icon: Icons.psychology_alt_outlined,
              label: AppStrings.reflectOn,
              text: text.reflect,
              italic: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _Labelled(
              icon: Icons.lightbulb_outline_rounded,
              label: AppStrings.tryThis,
              text: text.tip,
            ),
          ],
        ],
      ),
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({
    required this.icon,
    required this.label,
    required this.text,
    this.italic = false,
  });

  final IconData icon;
  final String label;
  final String text;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: context.colors.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label.toUpperCase(),
                style: context.textStyles.labelSmall?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurface,
                  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
