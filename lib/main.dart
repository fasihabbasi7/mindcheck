import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'providers/storage_provider.dart';
import 'services/history_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  // Needed because we use plugins (SharedPreferences) before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Draw behind the status bar and navigation bar for a full-screen look.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Load saved settings (theme, onboarding status) before the first frame.
  final StorageService storage = await StorageService.create();

  // Open the on-device database for results and journal entries.
  final HistoryService history = await HistoryService.open();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        historyServiceProvider.overrideWithValue(history),
      ],
      child: const MindCheckApp(),
    ),
  );
}
