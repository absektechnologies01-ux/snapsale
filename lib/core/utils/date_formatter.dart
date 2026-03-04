import 'package:intl/intl.dart';

class DateFormatter {
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final _dateOnly = DateFormat('dd MMM yyyy');
  static final _timeOnly = DateFormat('hh:mm a');
  static final _dayShort = DateFormat('EEE');
  static final _monthYear = DateFormat('MMM yyyy');

  static String formatDateTime(DateTime dt) => _dateTime.format(dt);
  static String formatDate(DateTime dt) => _dateOnly.format(dt);
  static String formatTime(DateTime dt) => _timeOnly.format(dt);
  static String formatDayShort(DateTime dt) => _dayShort.format(dt);
  static String formatMonthYear(DateTime dt) => _monthYear.format(dt);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameWeek(DateTime a, DateTime b) {
    final startOfWeek = b.subtract(Duration(days: b.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return a.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        a.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
