import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/assessment_result_model.dart';
import '../models/journal_entry_model.dart';

/// Stores completed results and journal entries on the device with Hive.
///
/// Each item is stored as a JSON string, so no Hive adapters or code
/// generation are needed. Nothing here ever leaves the device.
class HistoryService {
  HistoryService._(this._results, this._journal);

  static const String _resultsBox = 'results';
  static const String _journalBox = 'journal';

  final Box<String> _results;
  final Box<String> _journal;

  /// Call once in `main()` before the app starts.
  static Future<HistoryService> open() async {
    await Hive.initFlutter();
    final Box<String> results = await Hive.openBox<String>(_resultsBox);
    final Box<String> journal = await Hive.openBox<String>(_journalBox);
    return HistoryService._(results, journal);
  }

  // ---------- Results ----------

  /// All saved results, newest first. Unreadable entries are skipped.
  List<AssessmentResult> loadResults() {
    final List<AssessmentResult> list = <AssessmentResult>[];
    for (final String raw in _results.values) {
      try {
        list.add(
          AssessmentResult.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (error) {
        debugPrint('Skipping unreadable result: $error');
      }
    }
    list.sort(
      (AssessmentResult a, AssessmentResult b) =>
          b.completedAt.compareTo(a.completedAt),
    );
    return list;
  }

  Future<void> saveResult(AssessmentResult result) =>
      _results.put(result.id, jsonEncode(result.toJson()));

  Future<void> deleteResult(String id) => _results.delete(id);

  Future<void> clearResults() => _results.clear();

  // ---------- Journal ----------

  /// All journal entries, newest first.
  List<JournalEntry> loadJournal() {
    final List<JournalEntry> list = <JournalEntry>[];
    for (final String raw in _journal.values) {
      try {
        list.add(JournalEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (error) {
        debugPrint('Skipping unreadable journal entry: $error');
      }
    }
    list.sort(
      (JournalEntry a, JournalEntry b) => b.createdAt.compareTo(a.createdAt),
    );
    return list;
  }

  Future<void> saveEntry(JournalEntry entry) =>
      _journal.put(entry.id, jsonEncode(entry.toJson()));

  Future<void> deleteEntry(String id) => _journal.delete(id);

  Future<void> clearJournal() => _journal.clear();
}
