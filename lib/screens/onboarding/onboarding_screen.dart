import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../providers/storage_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/mind_background.dart';
import 'onboarding_pages.dart';

/// Three-page introduction: what MindCheck is, the assessments, and
/// privacy + limitations. The user must accept the disclaimer on the last
/// page before continuing. "Skip" jumps to that last page rather than
/// bypassing it.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _pageCount = 3;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  // Pre-filled when the introduction is replayed from Settings, so an
  // existing name is not wiped out.
  late final TextEditingController _nameController =
      TextEditingController(text: ref.read(userNameProvider));
  bool _acceptedDisclaimer = false;

  bool get _isLastPage => _currentPage == _pageCount - 1;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }


  void _goToPage(int page) {
    FocusScope.of(context).unfocus();
    _pageController.animateToPage(
      page,
      duration: AppDurations.slow,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    await ref.read(userNameProvider.notifier).setName(_nameController.text);
    await ref.read(storageServiceProvider).setOnboardingComplete(true);
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MindBackground(
        particles: true,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _TopBar(
                showSkip: !_isLastPage,
                onSkip: () => _goToPage(_pageCount - 1),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) =>
                      setState(() => _currentPage = page),
                  children: <Widget>[
                    OnboardingPage(
                      illustration: const IntroIllustration(),
                      title: AppStrings.onboarding1Title,
                      body: AppStrings.onboarding1Body,
                      extra: NameField(
                        controller: _nameController,
                        onSubmitted: () => _goToPage(1),
                      ),
                    ),
                    const OnboardingPage(
                      illustration: AssessmentsIllustration(),
                      illustrationHeight: null,
                      title: AppStrings.onboarding2Title,
                      body: AppStrings.onboarding2Body,
                    ),
                    OnboardingPage(
                      illustration: const PrivacyIllustration(),
                      illustrationHeight: 170,
                      title: AppStrings.onboarding3Title,
                      body: AppStrings.onboarding3Body,
                      extra: PrivacyPoints(
                        accepted: _acceptedDisclaimer,
                        onChanged: (bool value) =>
                            setState(() => _acceptedDisclaimer = value),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.md,
                  AppSpacing.screen,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: <Widget>[
                    _PageDots(count: _pageCount, current: _currentPage),
                    const Spacer(),
                    PrimaryButton(
                      expanded: false,
                      label: _isLastPage ? AppStrings.getStarted : AppStrings.next,
                      icon: Icons.arrow_forward_rounded,
                      // On the last page the button stays disabled until
                      // the disclaimer is accepted.
                      onPressed: _isLastPage
                          ? (_acceptedDisclaimer ? _finish : null)
                          : () => _goToPage(_currentPage + 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showSkip, required this.onSkip});

  final bool showSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.sm,
        0,
      ),
      child: SizedBox(
        height: 48,
        child: Row(
          children: <Widget>[
            const BrandLogo(width: 118),
            const Spacer(),
            AnimatedOpacity(
              opacity: showSkip ? 1 : 0,
              duration: AppDurations.fast,
              child: IgnorePointer(
                ignoring: !showSkip,
                child: TextButton(
                  onPressed: onSkip,
                  child: const Text(AppStrings.skip),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${current + 1} of $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppDurations.medium,
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 6),
              width: i == current ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == current
                    ? context.colors.primary
                    : context.colors.primary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
        ],
      ),
    );
  }
}
