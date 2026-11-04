/// Small helper functions that do not belong to any one screen.
class Helpers {
  Helpers._();

  /// Returns "Good morning", "Good afternoon" or "Good evening".
  static String greetingFor(DateTime time) {
    final int hour = time.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// e.g. "4 Nov 2026".
  static String formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// e.g. "4 Nov 2026, 14:05".
  static String formatDateTime(DateTime date) {
    final String hh = date.hour.toString().padLeft(2, '0');
    final String mm = date.minute.toString().padLeft(2, '0');
    return '${formatDate(date)}, $hh:$mm';
  }

  /// e.g. "under a minute", "1 minute", "6 minutes".
  static String formatDuration(int seconds) {
    if (seconds < 60) return 'under a minute';
    final int minutes = (seconds / 60).round();
    return minutes == 1 ? '1 minute' : '$minutes minutes';
  }

  /// Picks one item per calendar day, so the choice stays the same all day
  /// and changes tomorrow.
  static T dailyPick<T>(List<T> items, DateTime date) {
    final int dayNumber =
        DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
            Duration.millisecondsPerDay;
    return items[dayNumber % items.length];
  }
}
