import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today's date (midnight, local phone time).
///
/// Updates automatically at midnight and whenever the app comes back to the
/// foreground, so the daily reflection question and its journal entry
/// always belong to the same day, even if the app stays open overnight.
class TodayNotifier extends Notifier<DateTime> {
  Timer? _midnightTimer;
  AppLifecycleListener? _lifecycle;

  @override
  DateTime build() {
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    ref.onDispose(() {
      _midnightTimer?.cancel();
      _lifecycle?.dispose();
    });

    final DateTime now = DateTime.now();
    _scheduleMidnight(now);
    return _dateOnly(now);
  }

  static DateTime _dateOnly(DateTime time) =>
      DateTime(time.year, time.month, time.day);

  void _scheduleMidnight(DateTime now) {
    _midnightTimer?.cancel();
    final DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(
      nextMidnight.difference(now) + const Duration(seconds: 1),
      _refresh,
    );
  }

  void _refresh() {
    final DateTime now = DateTime.now();
    final DateTime today = _dateOnly(now);
    if (today != state) state = today;
    _scheduleMidnight(now);
  }
}

final NotifierProvider<TodayNotifier, DateTime> todayProvider =
    NotifierProvider<TodayNotifier, DateTime>(TodayNotifier.new);
