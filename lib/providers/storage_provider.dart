import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/history_service.dart';
import '../services/storage_service.dart';

/// Gives every part of the app access to the same [StorageService].
///
/// The real instance is created in `main()` and injected with
/// `overrideWithValue`, because SharedPreferences must load asynchronously
/// before the first screen is shown.
final Provider<StorageService> storageServiceProvider =
    Provider<StorageService>((Ref ref) {
  throw UnimplementedError(
    'storageServiceProvider must be overridden in main() with a real '
    'StorageService.',
  );
});

/// Saved results and journal entries (Hive). Also created in `main()`.
final Provider<HistoryService> historyServiceProvider =
    Provider<HistoryService>((Ref ref) {
  throw UnimplementedError(
    'historyServiceProvider must be overridden in main() with a real '
    'HistoryService.',
  );
});
