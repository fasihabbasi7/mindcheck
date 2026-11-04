import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_entry_model.dart';
import 'storage_provider.dart';

/// Private answers to the daily reflection question, newest first.
/// Saved only on this device.
class JournalNotifier extends Notifier<List<JournalEntry>> {
  @override
  List<JournalEntry> build() => ref.read(historyServiceProvider).loadJournal();

  /// Today's entry, if one was written.
  JournalEntry? entryFor(DateTime date) {
    final String id = JournalEntry.idFor(date);
    for (final JournalEntry entry in state) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  /// Creates or updates the entry for [date]. Empty text deletes it.
  Future<void> saveFor(DateTime date, String prompt, String text) async {
    final String cleaned = text.trim();
    final String id = JournalEntry.idFor(date);
    if (cleaned.isEmpty) return delete(id);

    final JournalEntry? existing = entryFor(date);
    final JournalEntry entry = existing?.copyWith(text: cleaned) ??
        JournalEntry(
          id: id,
          prompt: prompt,
          text: cleaned,
          createdAt: date,
          updatedAt: DateTime.now(),
        );
    state = <JournalEntry>[
      entry,
      ...state.where((JournalEntry e) => e.id != id),
    ]..sort((JournalEntry a, JournalEntry b) => b.createdAt.compareTo(a.createdAt));
    await ref.read(historyServiceProvider).saveEntry(entry);
  }

  Future<void> delete(String id) async {
    state = state.where((JournalEntry e) => e.id != id).toList();
    await ref.read(historyServiceProvider).deleteEntry(id);
  }

  Future<void> clearAll() async {
    state = const <JournalEntry>[];
    await ref.read(historyServiceProvider).clearJournal();
  }
}

final NotifierProvider<JournalNotifier, List<JournalEntry>> journalProvider =
    NotifierProvider<JournalNotifier, List<JournalEntry>>(JournalNotifier.new);
