import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../models/answer_model.dart';
import '../../models/assessment_result_model.dart';
import '../../models/assessment_model.dart';
import '../../models/question_model.dart';
import '../../models/report_model.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/question_provider.dart';
import '../../providers/result_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../widgets/answer_option.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/mind_background.dart';
import '../../widgets/progress_indicator.dart';
import '../../widgets/question_card.dart';
import '../../widgets/safety_support_card.dart';

/// The one question screen used by every assessment.
///
/// It shows one question at a time, saves each answer immediately,
/// keeps answers when moving back and forth, and asks for confirmation
/// before leaving an unfinished assessment.
class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({super.key, required this.assessmentId});

  final String assessmentId;

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  /// Direction of the last move, used for the slide animation.
  bool _movingForward = true;
  Timer? _autoAdvance;

  /// Set once answers are submitted, so clearing the session does not
  /// start a new one while this screen animates away.
  bool _submitted = false;

  @override
  void dispose() {
    _autoAdvance?.cancel();
    super.dispose();
  }

  AssessmentSessionNotifier get _session =>
      ref.read(assessmentSessionProvider.notifier);

  // ---------- Actions ----------

  void _select(QuestionSet set, AssessmentSession session, int value) {
    final QuestionModel question = set.questions[session.currentIndex];
    final bool firstTimeAnswered = !session.answers.containsKey(question.id);
    _session.answer(question.id, value);
    // A light tick, like a physical switch, confirms the choice.
    HapticFeedback.selectionClick();

    // Never move on automatically from a safety answer: the support card
    // under the question needs to be seen.
    final bool needsSupport = question.safety && value > set.minValue;

    // Only when the user has turned "Auto" on: move on after a short pause,
    // and only the first time a question is answered. Changing an earlier
    // answer always keeps you on that question.
    final bool autoAdvance = ref.read(autoAdvanceProvider);
    final bool isLast = session.currentIndex == set.length - 1;
    _autoAdvance?.cancel();
    if (autoAdvance && firstTimeAnswered && !isLast && !needsSupport) {
      final int index = session.currentIndex;
      _autoAdvance = Timer(const Duration(milliseconds: 600), () {
        final AssessmentSession? now = ref.read(assessmentSessionProvider);
        if (mounted && now != null && now.currentIndex == index) {
          _goNext();
        }
      });
    }
  }

  void _goNext() {
    _autoAdvance?.cancel();
    setState(() => _movingForward = true);
    _session.next();
  }

  void _goPrevious() {
    _autoAdvance?.cancel();
    setState(() => _movingForward = false);
    _session.previous();
  }

  void _jumpTo(int index) {
    final AssessmentSession? session = ref.read(assessmentSessionProvider);
    if (session == null) return;
    setState(() => _movingForward = index >= session.currentIndex);
    _session.goTo(index);
  }

  void _toggleAutoAdvance() {
    _autoAdvance?.cancel();
    final bool turningOn = !ref.read(autoAdvanceProvider);
    ref.read(autoAdvanceProvider.notifier).set(turningOn);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            turningOn ? AppStrings.autoNextOn : AppStrings.autoNextOff,
          ),
        ),
      );
  }

  /// Asks what to do with the answers so far.
  /// Returns null when the user decides to keep going.
  Future<_LeaveChoice?> _askLeave() async {
    final AssessmentSession? session = ref.read(assessmentSessionProvider);
    if (session == null || session.answeredCount == 0) {
      return _LeaveChoice.discard;
    }

    return showDialog<_LeaveChoice>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(AppStrings.leaveTitle),
        content: Text(
          'You have answered ${session.answeredCount} of '
          '${session.totalQuestions} questions. ${AppStrings.leaveBody}',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.keepGoing),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_LeaveChoice.discard),
            child: const Text(AppStrings.discardAnswers),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_LeaveChoice.save),
            child: const Text(AppStrings.saveAndExit),
          ),
        ],
      ),
    );
  }

  Future<void> _leave() async {
    final _LeaveChoice? choice = await _askLeave();
    if (choice == null || !mounted) return;
    _autoAdvance?.cancel();
    setState(() => _submitted = true); // stop the screen restarting a session
    if (choice == _LeaveChoice.save) {
      _session.suspend();
    } else {
      _session.clear();
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _openReview(QuestionSet set) async {
    final bool? submit = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      builder: (BuildContext sheetContext) => _ReviewSheet(
        set: set,
        onJump: (int index) {
          Navigator.of(sheetContext).pop(false);
          _jumpTo(index);
        },
      ),
    );
    if (submit == true && mounted) await _submit(set);
  }

  /// Scores the answers, stores the result and opens the completion screen.
  Future<void> _submit(QuestionSet set) async {
    final AssessmentSession? session = ref.read(assessmentSessionProvider);
    if (session == null) return;
    // A slightly firmer tap marks the moment of finishing.
    HapticFeedback.mediumImpact();
    try {
      final ReportConfig report =
          await ref.read(reportConfigProvider(widget.assessmentId).future);
      final AssessmentResult result = ref.read(scoringServiceProvider).score(
            set: set,
            report: report,
            answers: session.answers,
            startedAt: session.startedAt,
          );
      await ref.read(resultsProvider.notifier).add(result);
      if (!mounted) return;
      setState(() => _submitted = true);
      _session.clear();
      context.pushReplacement(
        AppRoutes.completePath(widget.assessmentId, result.id),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.scoringError)),
      );
    }
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    final AsyncValue<QuestionSet> questions =
        ref.watch(questionSetProvider(widget.assessmentId));
    final AssessmentSession? session = ref.watch(assessmentSessionProvider);
    final AssessmentModel? assessment =
        ref.watch(assessmentRepositoryProvider).getById(widget.assessmentId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        body: MindBackground(
          child: SafeArea(
            child: questions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stack) => Center(
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: AppStrings.loadErrorTitle,
                  message: AppStrings.loadErrorBody,
                  action: SecondaryButton(
                    expanded: false,
                    label: AppStrings.back,
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              data: (QuestionSet set) {
                // Opened without going through the instructions screen
                // (e.g. after a hot restart): start a fresh session.
                if (session == null ||
                    session.assessmentId != widget.assessmentId) {
                  if (_submitted) return const SizedBox.shrink();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    final AssessmentSession? saved =
                        ref.read(savedSessionsProvider)[widget.assessmentId];
                    if (saved != null && saved.totalQuestions == set.length) {
                      _session.resume(saved);
                    } else {
                      _session.start(widget.assessmentId, set.length);
                    }
                  });
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildQuestion(set, session, assessment);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(
    QuestionSet set,
    AssessmentSession session,
    AssessmentModel? assessment,
  ) {
    final int index = session.currentIndex.clamp(0, set.length - 1);
    final QuestionModel question = set.questions[index];
    final int? selected = session.answers[question.id];
    final bool isFirst = index == 0;
    final bool isLast = index == set.length - 1;
    final bool hasShading = question.shadedFromValue != null;

    return Column(
      children: <Widget>[
        // ---------- Top bar ----------
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            0,
          ),
          child: Row(
            children: <Widget>[
              CircleIconButton(
                icon: Icons.close_rounded,
                tooltip: AppStrings.leave,
                onPressed: _leave,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  assessment?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleMedium,
                ),
              ),
              _AutoNextToggle(
                enabled: ref.watch(autoAdvanceProvider),
                onPressed: _toggleAutoAdvance,
              ),
              const SizedBox(width: AppSpacing.sm),
              _CounterPill(current: index + 1, total: set.length),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            children: <Widget>[
              MindProgressBar(value: session.progress),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Text(
                    '${session.answeredCount} of ${set.length} answered',
                    style: context.textStyles.labelSmall,
                  ),
                  const Spacer(),
                  Text(
                    '${(session.progress * 100).round()}%',
                    style: context.textStyles.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ---------- Question + answers ----------
        Expanded(
          child: AnimatedSwitcher(
            duration: AppDurations.medium,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final bool incoming = child.key == ValueKey<String>(question.id);
              final double direction =
                  (_movingForward ? 1 : -1) * (incoming ? 1 : -1);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.12 * direction, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: ListView(
              key: ValueKey<String>(question.id),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.lg,
              ),
              children: <Widget>[
                QuestionCard(
                  number: index + 1,
                  prompt: set.prompt,
                  text: question.text,
                  section: question.section,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final ScaleOption option
                    in set.optionsFor(question)) ...<Widget>[
                  AnswerOption(
                    label: option.label,
                    selected: selected == option.value,
                    shaded: hasShading &&
                        option.value >= question.shadedFromValue!,
                    onTap: () => _select(set, session, option.value),
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
                ],
                if (question.safety &&
                    selected != null &&
                    selected > set.minValue) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  const SafetySupportCard(),
                ],
                if (hasShading)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      AppStrings.shadingNote,
                      style: context.textStyles.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ---------- Navigation ----------
        Container(
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
          child: Row(
            children: <Widget>[
              Expanded(
                child: SecondaryButton(
                  label: AppStrings.previous,
                  icon: Icons.arrow_back_rounded,
                  onPressed: isFirst ? null : _goPrevious,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  label: isLast ? AppStrings.review : AppStrings.next,
                  icon: isLast
                      ? Icons.fact_check_outlined
                      : Icons.arrow_forward_rounded,
                  // Next needs an answer; Review is always available so
                  // the user can see which questions are still open.
                  onPressed: isLast
                      ? () => _openReview(set)
                      : (selected == null ? null : _goNext),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small pill that turns automatic moving to the next question on or off.
class _AutoNextToggle extends StatelessWidget {
  const _AutoNextToggle({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final Color foreground =
        enabled ? colors.onPrimary : colors.onSurfaceVariant;

    return Tooltip(
      message: enabled ? AppStrings.autoNextTooltipOn : AppStrings.autoNextTooltipOff,
      child: Semantics(
        button: true,
        toggled: enabled,
        label: AppStrings.autoNextLabel,
        excludeSemantics: true,
        child: Material(
          color: enabled ? colors.primary : context.mind.glassFill,
          shape: StadiumBorder(
            side: BorderSide(
              color: enabled ? colors.primary : context.mind.glassBorder,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40, minWidth: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      size: 18,
                      color: foreground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.autoNextShort,
                      style: context.textStyles.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
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

enum _LeaveChoice { save, discard }

class _CounterPill extends StatelessWidget {
  const _CounterPill({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$current / $total',
        style: context.textStyles.labelMedium?.copyWith(
          color: context.colors.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Summary shown before submitting: how many questions are answered,
/// which are still open (tap to jump there), and the Submit button.
class _ReviewSheet extends ConsumerWidget {
  const _ReviewSheet({required this.set, required this.onJump});

  final QuestionSet set;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AssessmentSession? session = ref.watch(assessmentSessionProvider);
    if (session == null) return const SizedBox.shrink();

    final List<int> unanswered = <int>[
      for (int i = 0; i < set.length; i++)
        if (!session.answers.containsKey(set.questions[i].id)) i,
    ];
    final bool complete = unanswered.isEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              complete ? AppStrings.reviewReady : AppStrings.reviewAlmost,
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You have answered ${session.answeredCount} of ${set.length} '
              'questions.',
              style: context.textStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            MindProgressBar(value: session.progress),
            if (!complete) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.reviewUnanswered,
                style: context.textStyles.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      for (final int i in unanswered)
                        ActionChip(
                          label: Text('Question ${i + 1}'),
                          onPressed: () => onJump(i),
                        ),
                    ],
                  ),
                ),
              ),
            ] else ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.reviewChangeHint,
                style: context.textStyles.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: AppStrings.submit,
              icon: Icons.check_rounded,
              onPressed: complete
                  ? () => Navigator.of(context).pop(true)
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: AppStrings.keepReviewing,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
