import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../utils/constants.dart';
import 'glass_card.dart';

/// Frosted card showing the question number, the prompt and the question.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.number,
    required this.prompt,
    required this.text,
    this.section,
  });

  final int number;

  /// Short shared line, e.g. "How much do you agree?".
  final String prompt;
  final String text;

  /// Optional part label shown above the question number.
  final String? section;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      frosted: true,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (section != null) ...<Widget>[
            Text(
              section!,
              style: context.textStyles.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            'QUESTION $number',
            style: context.textStyles.labelSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(prompt, style: context.textStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Text(
            text,
            style: context.textStyles.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
