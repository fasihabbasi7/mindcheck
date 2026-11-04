import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../utils/constants.dart';
import 'mind_orb.dart';
import 'motion/reveal.dart';

/// Friendly message shown when a list has nothing in it yet
/// (for example, no completed assessments in History).
///
/// Uses the same glowing orb as onboarding, so empty screens feel part of
/// the app rather than an error, and fades gently into view.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Optional button shown under the message.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Reveal(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MindOrb(size: 104, icon: icon),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium,
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
