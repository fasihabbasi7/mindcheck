import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../app/theme/app_theme.dart';
import '../models/assessment_model.dart';
import '../providers/preferences_provider.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';
import 'custom_button.dart';
import 'glass_card.dart';

/// Opens the details screen for [assessment].
void openAssessment(BuildContext context, AssessmentModel assessment) {
  context.push(AppRoutes.assessmentDetailsPath(assessment.id));
}

/// Rounded gradient square with the assessment's icon.
class AssessmentIcon extends StatelessWidget {
  const AssessmentIcon({super.key, required this.assessment, this.size = 52});

  final AssessmentModel assessment;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: assessment.colors,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: assessment.colors.last.withValues(alpha: 0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Icon(assessment.icon, size: size * 0.48, color: Colors.white),
    );
  }
}

/// Small pill with an icon and a short label, e.g. "50 questions".
class MetaChip extends StatelessWidget {
  const MetaChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: context.colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              color: context.colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Label telling the user what kind of questionnaire this is.
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.type});

  final SourceType type;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final bool isOwn = type == SourceType.selfReflection;

    final IconData icon = switch (type) {
      SourceType.validatedScreener => Icons.verified_outlined,
      SourceType.researchQuestionnaire => Icons.menu_book_outlined,
      SourceType.adaptedQuestionnaire => Icons.auto_stories_outlined,
      SourceType.selfReflection => Icons.edit_note_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOwn ? Colors.transparent : colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: isOwn ? colors.outline : colors.primaryContainer,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 14,
            color: isOwn ? colors.onSurfaceVariant : colors.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: context.textStyles.labelSmall?.copyWith(
              color:
                  isOwn ? colors.onSurfaceVariant : colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bookmark icon that saves or un-saves an assessment.
class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({super.key, required this.assessmentId});

  final String assessmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool saved = ref.watch(bookmarksProvider).contains(assessmentId);
    return IconButton(
      tooltip: saved ? AppStrings.removeBookmark : AppStrings.bookmark,
      isSelected: saved,
      onPressed: () =>
          ref.read(bookmarksProvider.notifier).toggle(assessmentId),
      icon: Icon(
        saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        color: saved ? context.colors.primary : context.colors.onSurfaceVariant,
      ),
    );
  }
}

/// Full-width card used in the Explore list.
class AssessmentCard extends StatelessWidget {
  const AssessmentCard({super.key, required this.assessment});

  final AssessmentModel assessment;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => openAssessment(context, assessment),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AssessmentIcon(assessment: assessment),
              const SizedBox(width: AppSpacing.md + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(assessment.title, style: context.textStyles.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      assessment.tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              BookmarkButton(assessmentId: assessment.id),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
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
        ],
      ),
    );
  }
}

/// Compact card for the horizontal list on Home.
class AssessmentTile extends StatelessWidget {
  const AssessmentTile({super.key, required this.assessment});

  final AssessmentModel assessment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 164,
      child: GlassCard(
        onTap: () => openAssessment(context, assessment),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AssessmentIcon(assessment: assessment, size: 44),
            const SizedBox(height: AppSpacing.md),
            Text(
              assessment.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.titleSmall,
            ),
            const Spacer(),
            Text(
              '${assessment.questionCount} questions · '
              '~${assessment.estimatedMinutes} min',
              style: context.textStyles.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Large frosted card that highlights one assessment on Home.
class FeaturedAssessmentCard extends StatelessWidget {
  const FeaturedAssessmentCard({super.key, required this.assessment});

  final AssessmentModel assessment;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      frosted: true,
      onTap: () => openAssessment(context, assessment),
      padding: const EdgeInsets.all(AppSpacing.xl - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  gradient: LinearGradient(colors: assessment.colors),
                ),
                child: Text(
                  'FEATURED',
                  style: context.textStyles.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              AssessmentIcon(assessment: assessment, size: 48),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(assessment.title, style: context.textStyles.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(assessment.tagline, style: context.textStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
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
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'View assessment',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => openAssessment(context, assessment),
          ),
        ],
      ),
    );
  }
}
