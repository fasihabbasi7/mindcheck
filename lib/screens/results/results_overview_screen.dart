import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../models/assessment_model.dart';
import '../../models/assessment_result_model.dart';
import '../../models/report_model.dart';
import '../../models/trait_score_model.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/result_provider.dart';
import '../../services/pdf_report_service.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/assessment_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/mind_background.dart';
import '../../widgets/motion/celebration_burst.dart';
import '../../widgets/motion/reveal.dart';
import '../../widgets/result_chart.dart';
import '../../widgets/safety_support_card.dart';
import 'result_widgets.dart';

/// The main report for a completed assessment: overall result, chart,
/// highlighted traits, suggestions and the disclaimer.
class ResultsOverviewScreen extends ConsumerWidget {
  const ResultsOverviewScreen({
    super.key,
    required this.resultId,
    this.fresh = false,
  });

  final String resultId;

  /// True when opened straight after finishing an assessment; "Done" then
  /// returns Home instead of going back.
  final bool fresh;

  void _close(BuildContext context) {
    if (!fresh && context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AssessmentResult? result =
        ref.watch(resultsProvider.notifier).byId(resultId);
    // Rebuild when the list of results changes.
    ref.watch(resultsProvider);

    if (result == null) {
      return _NotFoundScaffold(onBack: () => _close(context));
    }

    final AssessmentModel? assessment =
        ref.watch(assessmentRepositoryProvider).getById(result.assessmentId);
    final AsyncValue<ReportConfig> report =
        ref.watch(reportConfigProvider(result.assessmentId));

    return Scaffold(
      body: MindBackground(
        particles: true,
        child: SafeArea(
          child: report.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object e, StackTrace s) =>
                _NotFound(onBack: () => _close(context)),
            data: (ReportConfig config) => _OverviewBody(
              result: result,
              assessment: assessment,
              report: config,
              earlier: ref.read(resultsProvider.notifier).earlierThan(result),
              fresh: fresh,
              onClose: () => _close(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({
    required this.result,
    required this.assessment,
    required this.report,
    required this.earlier,
    required this.fresh,
    required this.onClose,
  });

  final AssessmentResult result;
  final AssessmentModel? assessment;
  final ReportConfig report;

  /// Earlier attempts of the same assessment, newest first.
  final List<AssessmentResult> earlier;

  /// Just finished: play the small celebration.
  final bool fresh;
  final VoidCallback onClose;

  /// When the score starts counting up, and how long it takes.
  static const Duration _gaugeDelay = Duration(milliseconds: 350);
  static const Duration _gaugeDuration = Duration(milliseconds: 1400);

  /// Wraps each section so they arrive one after another.
  static List<Widget> _staggered(List<Widget> sections) {
    final List<Widget> out = <Widget>[];
    int step = 0;
    for (final Widget section in sections) {
      if (section is SizedBox) {
        out.add(section); // spacing stays as it is
        continue;
      }
      out.add(
        Reveal(
          delay: Duration(milliseconds: 90 * math.min(step, 8)),
          child: section,
        ),
      );
      step++;
    }
    return out;
  }

  /// Asks for confirmation (the PDF contains personal results), then
  /// builds the PDF on the device and opens the share sheet.
  Future<void> _sharePdf(BuildContext context) async {
    final AssessmentModel? a = assessment;
    if (a == null) return;
    final bool ok = await confirmAction(
      context,
      title: AppStrings.shareTitle,
      message: AppStrings.shareBody,
      confirmLabel: AppStrings.createPdf,
    );
    if (!ok) return;
    try {
      await const PdfReportService().share(
        result: result,
        assessment: a,
        report: report,
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.shareError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.textStyles;
    final OverallScore? overall = result.overall;
    final List<TraitScore> traits = result.traits;
    final int pickCount = traits.length >= 5 ? 2 : 1;

    final ReportSection? top = report.topSection;
    final ReportSection? focus = report.focusSection;
    final bool showSupport =
        overall != null && (report.support?.appliesTo(overall.value) ?? false);
    final int? shaded = result.extras['shadedCount'];
    final bool safety = result.extras['safetyFlag'] == 1;
    // Celebrate finishing, but never next to a worrying result.
    final bool celebrate = fresh && !showSupport && !safety;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.xl,
      ),
      children: _staggered(<Widget>[
        // ---------- Top bar ----------
        Row(
          children: <Widget>[
            CircleIconButton(
              icon: Icons.close_rounded,
              tooltip: AppStrings.done,
              onPressed: onClose,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(AppStrings.yourReport, style: text.titleMedium),
            const Spacer(),
            if (assessment != null)
              CircleIconButton(
                icon: Icons.ios_share_rounded,
                tooltip: AppStrings.sharePdf,
                onPressed: () => _sharePdf(context),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // ---------- Header ----------
        Row(
          children: <Widget>[
            if (assessment != null) ...<Widget>[
              AssessmentIcon(assessment: assessment!, size: 52),
              const SizedBox(width: AppSpacing.md + 2),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    assessment?.title ?? AppStrings.yourReport,
                    style: text.headlineSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Helpers.formatDateTime(result.completedAt),
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // ---------- Safety support (PHQ-9 question 9) ----------
        if (safety) ...<Widget>[
          const SafetySupportCard(),
          const SizedBox(height: AppSpacing.md),
        ],

        // ---------- Main result ----------
        Stack(
          children: <Widget>[
            GlassCard(
              frosted: true,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: <Widget>[
                  if (overall != null && report.isSpectrum)
                    SpectrumBar(
                      fraction: overall.fraction,
                      leftLabel: report.spectrumLeft ?? '',
                      rightLabel: report.spectrumRight ?? '',
                    )
                  else if (overall != null)
                    ScoreGauge(
                      fraction: overall.fraction,
                      valueText: overall.display,
                      countTo: overall.value,
                      caption: 'out of ${overall.max.round()}',
                      delay: _gaugeDelay,
                    )
                  else
                    TraitRadarChart(traits: traits),
                  const SizedBox(height: AppSpacing.lg),
                  if (overall != null) ...<Widget>[
                    Text(
                      overall.label.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: text.labelSmall?.copyWith(letterSpacing: 1.2),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Text(
                    result.headline,
                    textAlign: TextAlign.center,
                    style: text.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    overall?.bandSummary ?? report.intro ?? '',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (celebrate)
              Positioned.fill(
                child: CelebrationBurst(
                  // Starts as the score finishes counting up.
                  delay: _gaugeDelay + _gaugeDuration,
                  origin: const Alignment(0, -0.35),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ---------- Spectrum strengths ----------
        if (overall != null && overall.strengths.isNotEmpty) ...<Widget>[
          ReportCard(
            title: AppStrings.naturalStrengths,
            icon: Icons.auto_awesome_rounded,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final String s in overall.strengths) LevelChip(label: s),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ---------- Profile ----------
        if (traits.length >= 2) ...<Widget>[
          ReportCard(
            title: AppStrings.yourProfile,
            icon: Icons.insights_rounded,
            child: Column(
              children: <Widget>[
                if (overall != null && traits.length >= 3) ...<Widget>[
                  TraitRadarChart(traits: traits, height: 240),
                  const SizedBox(height: AppSpacing.lg),
                ],
                for (int i = 0; i < traits.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == traits.length - 1 ? 0 : AppSpacing.md,
                    ),
                    child: TraitBar(
                      name: traits[i].name,
                      percent: traits[i].percent,
                      levelLabel: report.levelLabel(traits[i].level),
                      // Bars fill one by one after the main score.
                      delay: _gaugeDelay +
                          const Duration(milliseconds: 500) +
                          Duration(milliseconds: 140 * i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ---------- ASRS shaded boxes ----------
        if (shaded != null) ...<Widget>[
          ReportCard(
            title: AppStrings.originalScoring,
            icon: Icons.grid_on_rounded,
            child: Text(
              '$shaded of ${result.extras['asrsItems'] ?? 6} screener answers '
              'fell in the shaded '
              'boxes of the official ASRS form. Under the original scoring '
              'rule, 4 or more shaded answers was the screening threshold.',
              style: text.bodyMedium?.copyWith(color: context.colors.onSurface),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ---------- Highlighted traits ----------
        if (top != null && traits.isNotEmpty) ...<Widget>[
          _HighlightCard(
            section: top,
            traits: pickTraits(
              traits,
              highest: top.pickHighest,
              count: pickCount,
            ),
            report: report,
            icon: Icons.star_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (focus != null && traits.length >= 3) ...<Widget>[
          _HighlightCard(
            section: focus,
            traits: pickTraits(
              traits,
              highest: focus.pickHighest,
              count: pickCount,
            ),
            report: report,
            icon: Icons.self_improvement_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ---------- Support ----------
        if (showSupport) ...<Widget>[
          GlassCard(
            color: context.colors.primaryContainer.withValues(alpha: 0.7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.favorite_outline_rounded,
                  color: context.colors.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    report.support!.text,
                    style: text.bodyMedium?.copyWith(
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ---------- Comparison ----------
        if (earlier.isNotEmpty) ...<Widget>[
          ComparisonCard(current: result, earlier: earlier),
          const SizedBox(height: AppSpacing.md),
        ],

        // ---------- Suggestions ----------
        if (report.suggestions.isNotEmpty) ...<Widget>[
          ReportCard(
            title: AppStrings.thingsToKeepInMind,
            icon: Icons.lightbulb_outline_rounded,
            child: Column(
              children: <Widget>[
                for (int i = 0; i < report.suggestions.length; i++)
                  BulletLine(
                    text: report.suggestions[i],
                    isLast: i == report.suggestions.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ---------- Disclaimer ----------
        _Disclaimer(assessment: assessment),
        const SizedBox(height: AppSpacing.xl),

        PrimaryButton(
          label: AppStrings.seeDetails,
          icon: Icons.arrow_forward_rounded,
          onPressed: () =>
              context.push(AppRoutes.resultDetailsPath(result.id)),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (assessment != null) ...<Widget>[
          SecondaryButton(
            label: AppStrings.sharePdf,
            icon: Icons.picture_as_pdf_outlined,
            onPressed: () => _sharePdf(context),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        SecondaryButton(label: AppStrings.done, onPressed: onClose),
      ]),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.section,
    required this.traits,
    required this.report,
    required this.icon,
  });

  final ReportSection section;
  final List<TraitScore> traits;
  final ReportConfig report;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ReportCard(
      title: section.title,
      icon: icon,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < traits.length; i++)
            InsightTile(
              trait: traits[i],
              report: report,
              isLast: i == traits.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer({required this.assessment});

  final AssessmentModel? assessment;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.resultDisclaimer,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
                if (assessment != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${assessment!.sourceType.label}: '
                    '${assessment!.sourceType.explanation}',
                    style: context.textStyles.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        icon: Icons.insights_rounded,
        title: AppStrings.resultNotFoundTitle,
        message: AppStrings.resultNotFoundBody,
        action: SecondaryButton(
          expanded: false,
          label: AppStrings.back,
          onPressed: onBack,
        ),
      ),
    );
  }
}

class _NotFoundScaffold extends StatelessWidget {
  const _NotFoundScaffold({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MindBackground(
        child: SafeArea(child: _NotFound(onBack: onBack)),
      ),
    );
  }
}
