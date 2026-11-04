import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/answer_model.dart';
import '../utils/constants.dart';

/// Saves small settings on the device with SharedPreferences: theme, name,
/// preferences, bookmarks and unfinished assessments.
///
/// Completed results and journal entries are larger, so they live in Hive
/// (see HistoryService).
class StorageService {
  StorageService._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  /// Call once in `main()` before the app starts.
  static Future<StorageService> create() async {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{
          StorageKeys.onboardingComplete,
          StorageKeys.themeMode,
          StorageKeys.userName,
          StorageKeys.autoAdvance,
          StorageKeys.bookmarks,
          StorageKeys.savedSessions,
        },
      ),
    );
    return StorageService._(prefs);
  }

  // ---------- Onboarding ----------

  bool get isOnboardingComplete =>
      _prefs.getBool(StorageKeys.onboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(StorageKeys.onboardingComplete, value);

  // ---------- Theme ----------

  ThemeMode get themeMode {
    final String? saved = _prefs.getString(StorageKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (ThemeMode mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(StorageKeys.themeMode, mode.name);

  // ---------- Profile ----------

  /// Optional first name for the greeting. Empty when not set.
  String get userName => _prefs.getString(StorageKeys.userName) ?? '';

  Future<void> setUserName(String name) => name.isEmpty
      ? _prefs.remove(StorageKeys.userName)
      : _prefs.setString(StorageKeys.userName, name);

  // ---------- Assessments ----------

  /// Move to the next question automatically after choosing an answer.
  /// Off by default, so users can change their mind before pressing Next.
  bool get autoAdvance => _prefs.getBool(StorageKeys.autoAdvance) ?? false;

  Future<void> setAutoAdvance(bool value) =>
      _prefs.setBool(StorageKeys.autoAdvance, value);

  // ---------- Bookmarks ----------

  Set<String> get bookmarks =>
      (_prefs.getStringList(StorageKeys.bookmarks) ?? <String>[]).toSet();

  Future<void> setBookmarks(Set<String> ids) =>
      _prefs.setStringList(StorageKeys.bookmarks, ids.toList());

  // ---------- Unfinished assessments ----------

  /// Unfinished assessments, by assessment id.
  Map<String, AssessmentSession> get savedSessions {
    final String? raw = _prefs.getString(StorageKeys.savedSessions);
    if (raw == null) return <String, AssessmentSession>{};
    try {
      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (String id, dynamic json) => MapEntry<String, AssessmentSession>(
          id,
          AssessmentSession.fromJson(json as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      return <String, AssessmentSession>{};
    }
  }

  Future<void> _writeSessions(Map<String, AssessmentSession> sessions) {
    if (sessions.isEmpty) return _prefs.remove(StorageKeys.savedSessions);
    return _prefs.setString(
      StorageKeys.savedSessions,
      jsonEncode(
        sessions.map(
          (String id, AssessmentSession s) =>
              MapEntry<String, dynamic>(id, s.toJson()),
        ),
      ),
    );
  }

  Future<void> saveSession(AssessmentSession session) {
    final Map<String, AssessmentSession> all = savedSessions;
    all[session.assessmentId] = session;
    return _writeSessions(all);
  }

  Future<void> removeSession(String assessmentId) {
    final Map<String, AssessmentSession> all = savedSessions;
    all.remove(assessmentId);
    return _writeSessions(all);
  }

  // ---------- Delete everything ----------

  /// Removes personal data (name, bookmarks, unfinished assessments).
  /// Theme, onboarding and auto-next preferences are kept.
  Future<void> clearPersonalData() async {
    await _prefs.remove(StorageKeys.userName);
    await _prefs.remove(StorageKeys.bookmarks);
    await _prefs.remove(StorageKeys.savedSessions);
  }
}
