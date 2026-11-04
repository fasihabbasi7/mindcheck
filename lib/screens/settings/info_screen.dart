import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/mind_background.dart';

/// Which information page to show.
enum InfoPage { privacy, about }

/// Simple reading page for the privacy information and the
/// About / disclaimer text.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.page});

  final InfoPage page;

  @override
  Widget build(BuildContext context) {
    final bool privacy = page == InfoPage.privacy;
    final List<(IconData, String, String)> sections =
        privacy ? _privacySections : _aboutSections;

    return Scaffold(
      body: MindBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xl,
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
              Text(
                privacy ? AppStrings.privacyTitle : AppStrings.aboutTitle,
                style: context.textStyles.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                privacy ? AppStrings.privacyIntro : AppStrings.aboutIntro,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final (IconData icon, String title, String body)
                  in sections) ...<Widget>[
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg + 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(icon, color: context.colors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(title, style: context.textStyles.titleSmall),
                            const SizedBox(height: 4),
                            Text(
                              body,
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: context.colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (!privacy)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    '${AppStrings.appName} ${AppStrings.version.toLowerCase()} '
                    '${AppInfo.version}',
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<(IconData, String, String)> _privacySections =
      <(IconData, String, String)>[
    (
      Icons.phone_android_rounded,
      'Everything stays on your device',
      'Your answers, results, journal entries, name and bookmarks are stored '
          'only on this phone. MindCheck has no servers and no analytics.',
    ),
    (
      Icons.cloud_off_rounded,
      'No account, no internet',
      'You never need to sign up or log in, and the app works fully offline. '
          'No personal data is sent anywhere.',
    ),
    (
      Icons.ios_share_rounded,
      'You decide what is shared',
      'A report only leaves the app when you choose "Share as PDF". The PDF '
          'is created on your phone and goes only where you send or save it.',
    ),
    (
      Icons.delete_outline_rounded,
      'Delete at any time',
      'In Settings you can delete single results or journal entries, your '
          'whole history, or all of your data at once. Deleted data cannot '
          'be recovered.',
    ),
    (
      Icons.info_outline_rounded,
      'Uninstalling',
      'Uninstalling MindCheck removes all of its data from this phone. Your '
          'phone\'s own backup settings may keep copies of app data; you can '
          'manage this in your system settings.',
    ),
  ];

  static const List<(IconData, String, String)> _aboutSections =
      <(IconData, String, String)>[
    (
      Icons.self_improvement_rounded,
      'What MindCheck is',
      'MindCheck is an educational self-reflection app. Its questionnaires '
          'help you think about your personality, habits and emotions, and '
          'its reports describe your own answers at one moment in time.',
    ),
    (
      Icons.medical_information_outlined,
      'Not a medical or diagnostic tool',
      'MindCheck cannot diagnose any condition, including autism, ADHD, '
          'anxiety disorders or personality disorders. Results are not a '
          'substitute for advice from a qualified professional.',
    ),
    (
      Icons.verified_outlined,
      'Where the questions come from',
      'Some assessments use published questionnaires (IPIP, Rosenberg, '
          'GAD-7 and the ASRS v1.1 screener), credited on each assessment. '
          'Others use questions written for MindCheck and are clearly '
          'labelled as not scientifically validated.',
    ),
    (
      Icons.support_agent_rounded,
      'If you are struggling',
      'If you feel overwhelmed, unsafe or in crisis, please contact a doctor, '
          'a mental health professional or your local emergency number '
          'straight away.',
    ),
  ];
}
