import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../models/assessment_model.dart';
import '../../providers/assessment_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../widgets/assessment_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/mind_background.dart';

/// Everything a user should know before starting an assessment:
/// what it explores, how it works, where the questions come from,
/// and its limits.
class AssessmentDetailsScreen extends ConsumerWidget {
  const AssessmentDetailsScreen({super.key, required this.assessmentId});

  final String assessmentId;

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.assessments);
    }
  }

  void _start(BuildContext context) {
    context.push(AppRoutes.instructionsPath(assessmentId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AssessmentModel? assessment =
        ref.watch(assessmentRepositoryProvider).getById(assessmentId);

    return Scaffold(
      body: MindBackground(
        child: SafeArea(
          child: assessment == null
              ? _NotFound(onBack: () => _goBack(context))
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: _DetailsBody(
                        assessment: assessment,
                        onBack: () => _goBack(context),
                      ),
                    ),
                    _StartBar(onStart: () => _start(context)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.assessment, required this.onBack});

  final AssessmentModel assessment;
  final VoidCallback onBack;

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
        Row(
          children: <Widget>[
            CircleIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: AppStrings.back,
              onPressed: onBack,
            ),
            const Spacer(),
            BookmarkButton(assessmentId: assessment.id),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // ---------- Header ----------
        AssessmentIcon(assessment: assessment, size: 72),
        const SizedBox(height: AppSpacing.lg),
        Text(assessment.title, style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          assessment.tagline,
          style: text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            MetaChip(
              icon: Icons.help_outline_rounded,
              label: '${assessment.questionCount} questions',
            ),
            MetaChip(
              icon: Icons.schedule_rounded,
              label: '~${assessment.estimatedMinutes} min',
            ),
            SourceBadge(type: assessment.sourceType),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // ---------- About ----------
        _Section(
          title: AppStrings.aboutAssessment,
          child: Text(
            assessment.description,
            style: text.bodyMedium?.copyWith(color: context.colors.onSurface),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ---------- What it explores ----------
        _Section(
          title: AppStrings.whatItExplores,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final String area in assessment.explores)
                _AreaChip(label: area, colors: assessment.colors),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ---------- How it works ----------
        _Section(
          title: AppStrings.howItWorks,
          child: Column(
            children: <Widget>[
              _InfoRow(
                icon: Icons.touch_app_outlined,
                label: AppStrings.answers,
                value: assessment.answerFormat,
              ),
              if (assessment.timeframe != null)
                _InfoRow(
                  icon: Icons.event_outlined,
                  label: AppStrings.timeframe,
                  value: assessment.timeframe!,
                ),
              if (assessment.audienceNote != null)
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: AppStrings.designedFor,
                  value: assessment.audienceNote!,
                ),
              _InfoRow(
                icon: Icons.insights_rounded,
                label: AppStrings.youWillReceive,
                value: assessment.resultLabel,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ---------- Source ----------
        _Section(
          title: AppStrings.source,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(assessment.sourceName, style: text.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(assessment.sourceType.explanation, style: text.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              Text(assessment.citation, style: text.bodySmall),
              if (assessment.copyrightNotice != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(assessment.copyrightNotice!, style: text.bodySmall),
              ],
              if (assessment.officialUrl != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(AppStrings.officialPage, style: text.labelSmall),
                SelectableText(
                  assessment.officialUrl!,
                  style: text.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ---------- Disclaimer ----------
        GlassCard(
          color: context.colors.primaryContainer.withValues(alpha: 0.6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.info_outline_rounded,
                color: context.colors.onPrimaryContainer,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  AppStrings.detailsDisclaimer,
                  style: text.bodyMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A titled glass card section.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: context.textStyles.titleMedium),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({required this.label, required this.colors});

  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        color: colors.first.withValues(alpha: 0.22),
        border: Border.all(color: colors.first.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: context.textStyles.labelMedium),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: context.colors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: context.textStyles.labelSmall),
                const SizedBox(height: 2),
                Text(value, style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurface,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom bar with the "Start assessment" button.
class _StartBar extends StatelessWidget {
  const _StartBar({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.mind.glassFill,
        border: Border(top: BorderSide(color: context.mind.glassBorder)),
      ),
      child: PrimaryButton(
        label: AppStrings.startAssessment,
        icon: Icons.arrow_forward_rounded,
        onPressed: onStart,
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
        icon: Icons.help_outline_rounded,
        title: AppStrings.notFoundTitle,
        message: AppStrings.notFoundBody,
        action: SecondaryButton(
          expanded: false,
          label: AppStrings.back,
          onPressed: onBack,
        ),
      ),
    );
  }
}
