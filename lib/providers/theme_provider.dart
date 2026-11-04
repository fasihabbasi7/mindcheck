import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_provider.dart';

/// Holds the current [ThemeMode] (system, light or dark) and saves changes.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Start with whatever the user picked last time.
    return ref.read(storageServiceProvider).themeMode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(storageServiceProvider).setThemeMode(mode);
  }
}

final NotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
