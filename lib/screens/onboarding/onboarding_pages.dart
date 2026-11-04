import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../widgets/accent_headline.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/hero_brain.dart';
import '../../widgets/mind_orb.dart';

/// Layout shared by all three onboarding pages:
/// illustration on top, headline and text underneath.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.illustration,
    required this.title,
    required this.body,
    this.extra,
    this.illustrationHeight = 300,
  });

  final Widget illustration;
  final String title;
  final String body;

  /// Optional content under the text (used for the privacy points).
  final Widget? extra;

  /// Fixed height for the illustration. `null` lets it size itself.
  final double? illustrationHeight;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: illustrationHeight,
            width: double.infinity,
            child: illustration,
          ),
          const SizedBox(height: AppSpacing.lg),
          AccentHeadline(title),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          if (extra != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            extra!,
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Page 1: the brain surrounded by the things MindCheck helps you explore.
class IntroIllustration extends StatelessWidget {
  const IntroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: <Widget>[
        Center(child: HeroBrain(width: 300)),
        Align(
          alignment: Alignment(-1, -0.9),
          child: OrbitChip(icon: Icons.fingerprint_rounded, label: 'Personality'),
        ),
        Align(
          alignment: Alignment(1, -0.1),
          child: OrbitChip(icon: Icons.favorite_outline_rounded, label: 'Emotions'),
        ),
        Align(
          alignment: Alignment(-0.85, 1),
          child: OrbitChip(icon: Icons.repeat_rounded, label: 'Habits'),
        ),
      ],
    );
  }
}

/// Page 2: a cloud of all the assessments.
class AssessmentsIllustration extends StatelessWidget {
  const AssessmentsIllustration({super.key});

  // Short labels so all of them fit on one page.
  static const List<(IconData, String)> _items = <(IconData, String)>[
    (Icons.hub_outlined, 'Big Five'),
    (Icons.groups_outlined, 'Intro / Extro'),
    (Icons.self_improvement_rounded, 'Self-Esteem'),
    (Icons.air_rounded, 'Anxiety'),
    (Icons.bolt_rounded, 'ADHD'),
    (Icons.extension_outlined, 'Autism'),
    (Icons.person_search_outlined, 'Narcissism'),
    (Icons.volunteer_activism_outlined, 'Self-Compassion'),
    (Icons.wb_sunny_outlined, 'Optimism'),
    (Icons.battery_alert_rounded, 'Burnout'),
    (Icons.cloud_outlined, 'Low Mood'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const MindOrb(size: 70, icon: Icons.grid_view_rounded),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final (IconData icon, String label) in _items)
              OrbitChip(icon: icon, label: label),
          ],
        ),
      ],
    );
  }
}

/// Page 3: a lock orb for privacy.
class PrivacyIllustration extends StatelessWidget {
  const PrivacyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: MindOrb(size: 100, icon: Icons.lock_outline_rounded),
    );
  }
}

/// The privacy and limitation points, plus the "I understand" checkbox.
class PrivacyPoints extends StatelessWidget {
  const PrivacyPoints({
    super.key,
    required this.accepted,
    required this.onChanged,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const GlassCard(
          child: Column(
            children: <Widget>[
              _Point(
                icon: Icons.phone_android_rounded,
                text: AppStrings.privacyPointDevice,
              ),
              _Point(
                icon: Icons.cloud_off_rounded,
                text: AppStrings.privacyPointAccount,
              ),
              _Point(
                icon: Icons.info_outline_rounded,
                text: AppStrings.privacyPointDiagnosis,
              ),
              _Point(
                icon: Icons.support_agent_rounded,
                text: AppStrings.privacyPointProfessional,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          onTap: () => onChanged(!accepted),
          child: Row(
            children: <Widget>[
              Checkbox(
                value: accepted,
                onChanged: (bool? value) => onChanged(value ?? false),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  AppStrings.disclaimerAgree,
                  style: context.textStyles.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text, this.isLast = false});

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
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 18, color: context.colors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Optional first-name field on the first onboarding page.
class NameField extends StatelessWidget {
  const NameField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppStrings.nameQuestion, style: context.textStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 30,
          onSubmitted: (_) => onSubmitted(),
          decoration: const InputDecoration(
            hintText: AppStrings.nameHint,
            helperText: AppStrings.nameHelper,
            counterText: '',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
      ],
    );
  }
}
