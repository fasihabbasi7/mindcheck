import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../models/assessment_model.dart';
import '../../models/assessment_result_model.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/result_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/accent_headline.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/mind_background.dart';
import '../../widgets/mind_orb.dart';

/// Shown right after submitting: a short celebration and the way to the
/// personal report.
class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({
    super.key,
    required this.assessmentId,
    required this.resultId,
  });

  final String assessmentId;
  final String resultId;

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _pop = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.3, 1, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _viewResults() {
    context.pushReplacement(
      AppRoutes.resultPath(widget.resultId, fresh: true),
    );
  }

  void _goHome() => context.go(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    ref.watch(resultsProvider);
    final AssessmentResult? result =
        ref.read(resultsProvider.notifier).byId(widget.resultId);
    final AssessmentModel? assessment =
        ref.watch(assessmentRepositoryProvider).getById(widget.assessmentId);

    final String summary = result == null
        ? AppStrings.completeFallback
        : 'You answered all ${result.answers.length} questions of '
            '${assessment?.title ?? 'this assessment'} in '
            '${Helpers.formatDuration(result.durationSeconds)}.';

    return PopScope(
      // Back from here goes Home instead of returning to the questions.
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? popResult) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        body: MindBackground(
          particles: true,
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              child: Column(
                children: <Widget>[
                  const Spacer(),
                  ScaleTransition(
                    scale: _pop,
                    child: const MindOrb(size: 120, icon: Icons.check_rounded),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: <Widget>[
                        AccentHeadline(
                          AppStrings.completeTitle,
                          textAlign: TextAlign.center,
                          style: context.textStyles.displaySmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          summary,
                          textAlign: TextAlign.center,
                          style: context.textStyles.bodyLarge?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        GlassCard(
                          frosted: true,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.favorite_outline_rounded,
                                color: context.colors.primary,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  AppStrings.completeNote,
                                  style: context.textStyles.bodyMedium
                                      ?.copyWith(
                                    color: context.colors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: AppStrings.viewResults,
                    icon: Icons.insights_rounded,
                    onPressed: result == null ? null : _viewResults,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(
                    label: AppStrings.backToHome,
                    onPressed: _goHome,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
