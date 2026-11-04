import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../providers/storage_provider.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/mind_background.dart';

/// Brand intro shown on launch: the MindCheck logo animates in with a soft
/// glow, then the tagline. Afterwards it opens onboarding (first launch)
/// or the home screen (returning users).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  late final Animation<double> _scale = Tween<double>(begin: 0.85, end: 1)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  // The tagline appears a little after the logo.
  late final Animation<double> _taglineFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.5, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(AppDurations.splash);
    if (!mounted) return;

    final bool onboarded =
        ref.read(storageServiceProvider).isOnboardingComplete;
    context.go(onboarded ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MindBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Soft glow behind the logo.
                        Container(
                          width: 320,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: <Color>[
                                context.mind.glow,
                                context.mind.glow.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                        const BrandLogo(width: 250),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FadeTransition(
                  opacity: _taglineFade,
                  child: Text(
                    AppStrings.tagline,
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodyMedium,
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
