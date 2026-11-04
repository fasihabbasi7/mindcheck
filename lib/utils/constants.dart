/// Spacing, sizes and durations used across the app.
/// Keeping them in one place keeps the layout consistent.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal padding for every screen.
  static const double screen = 22;

  /// Space to leave at the bottom of scrolling tab screens so the
  /// floating bottom navigation bar never covers content.
  static const double navBarClearance = 120;
}

class AppRadius {
  AppRadius._();

  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 100;
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration splash = Duration(milliseconds: 2200);
}

/// Keys used to save values with SharedPreferences.
class StorageKeys {
  StorageKeys._();

  static const String onboardingComplete = 'onboarding_complete';
  static const String themeMode = 'theme_mode';
  static const String userName = 'user_name';
  static const String autoAdvance = 'auto_advance';
  static const String bookmarks = 'bookmarks';
  static const String savedSessions = 'saved_sessions';
}

class AppInfo {
  AppInfo._();

  /// Keep in sync with `version:` in pubspec.yaml.
  static const String version = '1.0.0';
}
