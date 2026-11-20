import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_provider.dart';

/// Whether the question screen moves on by itself after an answer is
/// chosen. Off by default; changed with the "Auto" toggle on the question
/// screen or in Settings, and remembered on the device.
class AutoAdvanceNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(storageServiceProvider).autoAdvance;

  Future<void> set(bool value) async {
    state = value;
    await ref.read(storageServiceProvider).setAutoAdvance(value);
  }

  Future<void> toggle() => set(!state);
}

final NotifierProvider<AutoAdvanceNotifier, bool> autoAdvanceProvider =
    NotifierProvider<AutoAdvanceNotifier, bool>(AutoAdvanceNotifier.new);

/// "Reduce effects" in Settings: turns off 3D, motion and glow effects.
/// The app passes it on as Flutter's "disable animations" setting, so every
/// animated widget that respects reduce motion also respects this switch.
class ReduceEffectsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(storageServiceProvider).reduceEffects;

  Future<void> set(bool value) async {
    state = value;
    await ref.read(storageServiceProvider).setReduceEffects(value);
  }
}

final NotifierProvider<ReduceEffectsNotifier, bool> reduceEffectsProvider =
    NotifierProvider<ReduceEffectsNotifier, bool>(ReduceEffectsNotifier.new);

/// Assessment ids the user has bookmarked.
class BookmarksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.read(storageServiceProvider).bookmarks;

  bool isBookmarked(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    final Set<String> next = <String>{...state};
    if (!next.remove(id)) next.add(id);
    state = next;
    await ref.read(storageServiceProvider).setBookmarks(next);
  }

  Future<void> clearAll() async {
    state = <String>{};
    await ref.read(storageServiceProvider).setBookmarks(<String>{});
  }
}

final NotifierProvider<BookmarksNotifier, Set<String>> bookmarksProvider =
    NotifierProvider<BookmarksNotifier, Set<String>>(BookmarksNotifier.new);
