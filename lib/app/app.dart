import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/preferences_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_strings.dart';
import '../widgets/motion/glow_edge.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

/// The root widget of MindCurio.
class MindCurioApp extends ConsumerWidget {
  const MindCurioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final bool reduceEffects = ref.watch(reduceEffectsProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      // "Reduce effects" works like the phone's own "remove animations"
      // setting, which all of MindCurio's effects already respect.
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            disableAnimations: media.disableAnimations || reduceEffects,
          ),
          // One shared clock makes every card edge shimmer in step.
          child: ShimmerClock(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
