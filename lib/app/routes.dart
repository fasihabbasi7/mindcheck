import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/assessment_details/assessment_details_screen.dart';
import '../screens/assessments/assessments_screen.dart';
import '../screens/completion/completion_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/instructions/instructions_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/questions/question_screen.dart';
import '../screens/results/detailed_results_screen.dart';
import '../screens/results/results_overview_screen.dart';
import '../screens/settings/info_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'page_transitions.dart';

/// All route paths in one place, so we never mistype a path string.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Tabs (inside the bottom navigation shell)
  static const String home = '/home';
  static const String assessments = '/assessments';
  static const String history = '/history';
  static const String settings = '/settings';

  // Full-screen pages shown above the tabs
  static const String assessmentDetails = '/assessment/:id';
  static String assessmentDetailsPath(String id) => '/assessment/$id';
  static String instructionsPath(String id) => '/assessment/$id/instructions';
  static String questionsPath(String id) => '/assessment/$id/questions';
  static String completePath(String id, String resultId) =>
      '/assessment/$id/complete?result=${Uri.encodeComponent(resultId)}';

  static const String result = '/result/:resultId';

  static const String privacyInfo = '/info/privacy';
  static const String aboutInfo = '/info/about';

  /// [fresh] = opened straight after finishing; "Done" then goes Home.
  static String resultPath(String resultId, {bool fresh = false}) =>
      '/result/${Uri.encodeComponent(resultId)}${fresh ? '?fresh=1' : ''}';
  static String resultDetailsPath(String resultId) =>
      '/result/${Uri.encodeComponent(resultId)}/details';
}

/// The app's router. Screens navigate with `context.go(AppRoutes.home)`
/// or `context.push(...)`.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fadePage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.assessmentDetails,
        builder: (BuildContext context, GoRouterState state) =>
            AssessmentDetailsScreen(
          assessmentId: state.pathParameters['id'] ?? '',
        ),
        routes: <RouteBase>[
          GoRoute(
            path: 'instructions',
            builder: (BuildContext context, GoRouterState state) =>
                InstructionsScreen(
              assessmentId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: 'questions',
            builder: (BuildContext context, GoRouterState state) =>
                QuestionScreen(
              assessmentId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: 'complete',
            pageBuilder: (BuildContext context, GoRouterState state) =>
                _fadePage(
              state,
              CompletionScreen(
                assessmentId: state.pathParameters['id'] ?? '',
                resultId: state.uri.queryParameters['result'] ?? '',
              ),
            ),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.result,
        pageBuilder: (BuildContext context, GoRouterState state) => _fadePage(
          state,
          ResultsOverviewScreen(
            resultId: state.pathParameters['resultId'] ?? '',
            fresh: state.uri.queryParameters['fresh'] == '1',
          ),
        ),
        routes: <RouteBase>[
          GoRoute(
            path: 'details',
            builder: (BuildContext context, GoRouterState state) =>
                DetailedResultsScreen(
              resultId: state.pathParameters['resultId'] ?? '',
            ),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.privacyInfo,
        builder: (BuildContext context, GoRouterState state) =>
            const InfoScreen(page: InfoPage.privacy),
      ),
      GoRoute(
        path: AppRoutes.aboutInfo,
        builder: (BuildContext context, GoRouterState state) =>
            const InfoScreen(page: InfoPage.about),
      ),

      // The four main tabs. StatefulShellRoute keeps each tab's state
      // (scroll position etc.) when switching between tabs.
      StatefulShellRoute.indexedStack(
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) =>
            _fadePage(state, MainShell(navigationShell: navigationShell)),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.assessments,
                builder: (BuildContext context, GoRouterState state) =>
                    const AssessmentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.history,
                builder: (BuildContext context, GoRouterState state) =>
                    const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settings,
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

/// A gentle fade transition used when moving between major sections.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return MindPageTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    },
  );
}
