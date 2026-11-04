import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../models/assessment_model.dart';
import '../../models/answer_model.dart';
import '../../models/assessment_result_model.dart';
import '../../models/journal_entry_model.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/question_provider.dart';
import '../../providers/result_provider.dart';
import '../../providers/today_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/accent_headline.dart';
import '../../widgets/assessment_card.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_stat_card.dart';
import '../../widgets/hero_brain.dart';
import '../../widgets/journal_editor_sheet.dart';
import '../../widgets/mind_background.dart';
import '../../widgets/motion/scroll_parallax.dart';
import '../../widgets/progress_indicator.dart';
import '../../widgets/search_field.dart';

/// Home tab: greeting, search, the brain hero with stat cards, a featured
/// assessment, all assessments, today's reflection and recent results.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openSearch(BuildContext context, WidgetRef ref) {
    ref.read(exploreSearchFocusProvider.notifier).request();
    context.go(AppRoutes.assessments);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = DateTime.now();
    // Changes at midnight, so the daily picks below refresh by themselves.
    final DateTime today = ref.watch(todayProvider);
    final String name = ref.watch(userNameProvider);
    final List<AssessmentModel> assessments = ref.watch(allAssessmentsProvider);
    final List<AssessmentResult> results = ref.watch(resultsProvider);
    ref.watch(savedSessionsProvider);
    final AssessmentSession? unfinished =
        ref.read(savedSessionsProvider.notifier).latest;
    final AssessmentModel featured = Helpers.dailyPick(assessments, today);
    final String prompt =
        Helpers.dailyPick(AppStrings.reflectionPrompts, today);

    final String greeting = name.isEmpty
        ? '${Helpers.greetingFor(now)} 👋 ${AppStrings.homeQuestion}'
        : 'Hello, **$name** 👋 ${AppStrings.homeQuestion}';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MindBackground(
        particles: true,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.navBarClearance,
            ),
            children: <Widget>[
              _Padded(
                child: Row(
                  children: <Widget>[
                    const BrandLogo(width: 124),
                    const Spacer(),
                    CircleIconButton(
                      icon: Icons.settings_outlined,
                      tooltip: AppStrings.tabSettings,
                      onPressed: () => context.go(AppRoutes.settings),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Padded(
                child: AccentHeadline(
                  greeting,
                  style: context.textStyles.displaySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Padded(
                child: MindSearchField(
                  readOnly: true,
                  hint: AppStrings.searchHint,
                  onTap: () => _openSearch(context, ref),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Padded(child: _HeroSection(
                  assessmentCount: assessments.length,
                  completedCount: results.length,
                ),),
              const SizedBox(height: AppSpacing.xl),
              if (unfinished != null) ...<Widget>[
                _Padded(
                  child: _ContinueCard(
                    session: unfinished,
                    assessment: assessments.firstWhere(
                      (AssessmentModel a) => a.id == unfinished.assessmentId,
                      orElse: () => featured,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              _Padded(child: FeaturedAssessmentCard(assessment: featured)),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                title: AppStrings.exploreSection,
                actionLabel: AppStrings.seeAll,
                onAction: () => context.go(AppRoutes.assessments),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 168,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                  ),
                  // Room for the card shadows.
                  clipBehavior: Clip.none,
                  itemCount: assessments.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (BuildContext context, int index) =>
                      AssessmentTile(assessment: assessments[index]),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Padded(child: _ReflectionCard(prompt: prompt, today: today)),
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(
                title: AppStrings.recentResults,
                actionLabel: AppStrings.tabHistory,
                onAction: () => context.go(AppRoutes.history),
              ),
              const SizedBox(height: AppSpacing.md),
              _Padded(
                child: results.isEmpty
                    ? const _NoRecentResults()
                    : _RecentResults(
                        results: results.take(3).toList(),
                        assessments: assessments,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Adds the standard horizontal screen padding.
class _Padded extends StatelessWidget {
  const _Padded({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: child,
    );
  }
}

/// "Title ........ See all" row above a section.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.screen, right: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(title, style: context.textStyles.headlineSmall),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

/// The latest completed assessments; tap one to open its report.
class _RecentResults extends StatelessWidget {
  const _RecentResults({required this.results, required this.assessments});

  final List<AssessmentResult> results;
  final List<AssessmentModel> assessments;

  AssessmentModel? _assessmentFor(String id) {
    for (final AssessmentModel a in assessments) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < results.length; i++) ...<Widget>[
          GlassCard(
            onTap: () =>
                context.push(AppRoutes.resultPath(results[i].id)),
            child: Row(
              children: <Widget>[
                if (_assessmentFor(results[i].assessmentId) != null)
                  AssessmentIcon(
                    assessment: _assessmentFor(results[i].assessmentId)!,
                    size: 44,
                  ),
                const SizedBox(width: AppSpacing.md + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _assessmentFor(results[i].assessmentId)?.title ?? '',
                        style: context.textStyles.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        results[i].headline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Helpers.formatDate(results[i].completedAt),
                        style: context.textStyles.labelSmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
          if (i < results.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

/// Shown under "Recent results" until the user completes an assessment.
class _NoRecentResults extends StatelessWidget {
  const _NoRecentResults();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.insights_rounded,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.noRecentTitle,
                  style: context.textStyles.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.noRecentBody,
                  style: context.textStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The brain with two frosted stat cards linked to it by thin lines,
/// as in the design reference.
class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.assessmentCount,
    required this.completedCount,
  });

  final int assessmentCount;
  final int completedCount;

  static const double _height = 330;
  static const double _cardWidth = 150;

  /// Approximate height of a GlassStatCard, used to start the lines.
  static const double _cardHeight = 108;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final double brainWidth = math.min(w * 0.94, 330);

        // Line from the top of the left card up and across to the brain.
        final List<Offset> leftLine = <Offset>[
          const Offset(_cardWidth / 2, _height - _cardHeight),
          const Offset(_cardWidth / 2, _height * 0.42),
          Offset(w * 0.42, _height * 0.42),
        ];
        // Line from the bottom of the right card down and across to the brain.
        final List<Offset> rightLine = <Offset>[
          Offset(w - _cardWidth / 2, _cardHeight),
          Offset(w - _cardWidth / 2, _height * 0.66),
          Offset(w * 0.66, _height * 0.66),
        ];

        return SizedBox(
          height: _height,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                top: 30,
                left: (w - brainWidth) / 2,
                // Drifts down more slowly than the page when scrolling,
                // so the brain seems to float behind the cards.
                child: ScrollParallax(
                  child: HeroBrain(width: brainWidth),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ConnectorPainter(
                      lines: <List<Offset>>[leftLine, rightLine],
                      lineColor: context.isDarkMode
                          ? Colors.white.withValues(alpha: 0.45)
                          : Colors.white.withValues(alpha: 0.9),
                      dotColor: context.colors.primary,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GlassStatCard(
                  width: _cardWidth,
                  title: AppStrings.statAssessmentsTitle,
                  icon: Icons.grid_view_rounded,
                  caption: AppStrings.statAssessmentsCaption,
                  value: '$assessmentCount',
                  unit: 'tests',
                  onTap: () => context.go(AppRoutes.assessments),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: GlassStatCard(
                  width: _cardWidth,
                  title: AppStrings.statCompletedTitle,
                  icon: Icons.task_alt_rounded,
                  caption: AppStrings.statCompletedCaption,
                  value: '$completedCount',
                  onTap: () => context.go(AppRoutes.history),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Draws thin rounded-corner lines ending in a glowing dot.
class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.lines,
    required this.lineColor,
    required this.dotColor,
  });

  final List<List<Offset>> lines;
  final Color lineColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = lineColor;

    for (final List<Offset> points in lines) {
      canvas.drawPath(_roundedPath(points, 14), stroke);

      final Offset end = points.last;
      canvas.drawCircle(
        end,
        11,
        Paint()
          ..color = dotColor.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(end, 6, Paint()..color = Colors.white);
      canvas.drawCircle(end, 3, Paint()..color = dotColor);
    }
  }

  /// A path through [points] with softened corners.
  Path _roundedPath(List<Offset> points, double radius) {
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length - 1; i++) {
      final Offset prev = points[i - 1];
      final Offset corner = points[i];
      final Offset next = points[i + 1];
      final double r = math.min(
        radius,
        math.min((corner - prev).distance, (next - corner).distance) / 2,
      );
      final Offset before =
          corner - (corner - prev) / (corner - prev).distance * r;
      final Offset after =
          corner + (next - corner) / (next - corner).distance * r;
      path
        ..lineTo(before.dx, before.dy)
        ..quadraticBezierTo(corner.dx, corner.dy, after.dx, after.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) =>
      oldDelegate.lines != lines ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.dotColor != dotColor;
}

/// Frosted card with today's reflection question. Tap it to write a
/// private answer in the journal.
class _ReflectionCard extends ConsumerWidget {
  const _ReflectionCard({required this.prompt, required this.today});

  final String prompt;

  /// Today's date, from todayProvider, so prompt and entry always match.
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(journalProvider);
    final JournalEntry? entry =
        ref.read(journalProvider.notifier).entryFor(today);

    return GlassCard(
      frosted: true,
      padding: const EdgeInsets.all(AppSpacing.lg + 2),
      onTap: () => showJournalEditor(context, prompt: prompt, date: today),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _IconBubble(icon: Icons.auto_awesome_rounded, size: 44),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.todaysReflection.toUpperCase(),
                  style: context.textStyles.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: context.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry?.prompt ?? prompt,
                  style: context.textStyles.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (entry != null)
                  Text(
                    entry.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                Row(
                  children: <Widget>[
                    Icon(
                      entry == null ? Icons.edit_outlined : Icons.check_rounded,
                      size: 16,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry == null
                          ? AppStrings.writeReflection
                          : AppStrings.editReflection,
                      style: context.textStyles.labelMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when an assessment was started but not finished.
class _ContinueCard extends ConsumerWidget {
  const _ContinueCard({required this.session, required this.assessment});

  final AssessmentSession session;
  final AssessmentModel assessment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      frosted: true,
      onTap: () => context.push(AppRoutes.instructionsPath(assessment.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AssessmentIcon(assessment: assessment, size: 44),
              const SizedBox(width: AppSpacing.md + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppStrings.unfinishedLabel.toUpperCase(),
                      style: context.textStyles.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        color: context.colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      assessment.title,
                      style: context.textStyles.titleMedium,
                    ),
                  ],
                ),
              ),
              Text(
                '${session.answeredCount}/${session.totalQuestions}',
                style: context.textStyles.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          MindProgressBar(value: session.progress),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: AppStrings.continueWhereLeft,
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              ref.read(assessmentSessionProvider.notifier).resume(session);
              context.push(AppRoutes.questionsPath(assessment.id));
            },
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFB9ACF7), Color(0xFF7565D8)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.48, color: Colors.white),
    );
  }
}
