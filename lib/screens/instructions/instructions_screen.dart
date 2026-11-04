import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../models/answer_model.dart';
import '../../models/assessment_model.dart';
import '../../models/question_model.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/question_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/assessment_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/mind_background.dart';
import '../../widgets/progress_indicator.dart';

/// "Before you begin": how to answer, how long it takes, and a reminder
/// that there are no right or wrong answers.
class InstructionsScreen extends ConsumerWidget {
  const InstructionsScreen({super.key, required this.assessmentId});

  final String assessmentId;

  void _begin(BuildContext context, WidgetRef ref, QuestionSet set) {
    ref
        .read(assessmentSessionProvider.notifier)
        .start(assessmentId, set.length);
    // Replace this screen so "back" from the questions returns to details.
    context.pushReplacement(AppRoutes.questionsPath(assessmentId));
  }

  void _resume(BuildContext context, WidgetRef ref, AssessmentSession saved) {
    ref.read(assessmentSessionProvider.notifier).resume(saved);
    context.pushReplacement(AppRoutes.questionsPath(assessmentId));
  }

  /// "Start over" deletes saved answers, so ask first.
  Future<void> _confirmRestart(
    BuildContext context,
    WidgetRef ref,
    QuestionSet set,
  ) async {
    final bool? restart = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(AppStrings.restartTitle),
        content: const Text(AppStrings.restartBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.startOver),
          ),
        ],
      ),
    );
    if (restart == true && context.mounted) _begin(context, ref, set);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AssessmentModel? assessment =
        ref.watch(assessmentRepositoryProvider).getById(assessmentId);
    final AsyncValue<QuestionSet> questions =
        ref.watch(questionSetProvider(assessmentId));
    final AssessmentSession? saved =
        ref.watch(savedSessionsProvider)[assessmentId];

    return Scaffold(
      body: MindBackground(
        child: SafeArea(
          child: assessment == null
              ? const _Message(
                  icon: Icons.help_outline_rounded,
                  title: AppStrings.notFoundTitle,
                  message: AppStrings.notFoundBody,
                )
              : questions.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object error, StackTrace stack) => const _Message(
                    icon: Icons.error_outline_rounded,
                    title: AppStrings.loadErrorTitle,
                    message: AppStrings.loadErrorBody,
                  ),
                  data: (QuestionSet set) => Column(
                    children: <Widget>[
                      Expanded(
                        child: _InstructionsBody(
                          assessment: assessment,
                          set: set,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          AppSpacing.sm,
                          AppSpacing.screen,
                          AppSpacing.md,
                        ),
                        child: saved != null &&
                                saved.totalQuestions == set.length
                            ? _ResumeBox(
                                saved: saved,
                                onResume: () => _resume(context, ref, saved),
                                onRestart: () =>
                                    _confirmRestart(context, ref, set),
                              )
                            : PrimaryButton(
                                label: AppStrings.begin,
                                icon: Icons.arrow_forward_rounded,
                                onPressed: () => _begin(context, ref, set),
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _InstructionsBody extends StatelessWidget {
  const _InstructionsBody({required this.assessment, required this.set});

  final AssessmentModel assessment;
  final QuestionSet set;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.textStyles;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.lg,
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
        Row(
          children: <Widget>[
            AssessmentIcon(assessment: assessment, size: 56),
            const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppStrings.beforeYouBegin.toUpperCase(),
                    style: text.labelSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(assessment.title, style: text.headlineSmall),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        GlassCard(
          frosted: true,
          padding: const EdgeInsets.all(AppSpacing.xl - 2),
          child: Text(
            set.instructions,
            style: text.bodyLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg + 2),
          child: Column(
            children: <Widget>[
              _Tip(
                icon: Icons.format_list_numbered_rounded,
                text: '${set.length} questions · about '
                    '${assessment.estimatedMinutes} minutes',
              ),
              if (assessment.timeframe != null)
                _Tip(
                  icon: Icons.event_outlined,
                  text: 'Think about: ${assessment.timeframe!.toLowerCase()}',
                ),
              _Tip(
                icon: Icons.touch_app_outlined,
                text: 'Answers range from "${set.scale.first.label}" '
                    'to "${set.scale.last.label}"',
              ),
              const _Tip(
                icon: Icons.bolt_outlined,
                text: AppStrings.tipFirstInstinct,
              ),
              const _Tip(
                icon: Icons.undo_rounded,
                text: AppStrings.tipGoBack,
              ),
              const _Tip(
                icon: Icons.lock_outline_rounded,
                text: AppStrings.tipPrivate,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shown instead of "Begin" when there is saved progress.
class _ResumeBox extends StatelessWidget {
  const _ResumeBox({
    required this.saved,
    required this.onResume,
    required this.onRestart,
  });

  final AssessmentSession saved;
  final VoidCallback onResume;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'You answered ${saved.answeredCount} of ${saved.totalQuestions} '
          'questions on ${Helpers.formatDate(saved.updatedAt ?? saved.startedAt)}.',
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        MindProgressBar(value: saved.progress),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: AppStrings.continueWhereLeft,
          icon: Icons.play_arrow_rounded,
          onPressed: onResume,
        ),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(label: AppStrings.startOver, onPressed: onRestart),
      ],
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.text, this.isLast = false});

  final IconData icon;
  final String text;
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

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        icon: icon,
        title: title,
        message: message,
        action: SecondaryButton(
          expanded: false,
          label: AppStrings.back,
          onPressed: () => context.pop(),
        ),
      ),
    );
  }
}
