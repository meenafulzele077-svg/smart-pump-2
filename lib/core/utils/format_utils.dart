import 'package:intl/intl.dart';

/// Reusable formatters for dates, durations & units shown across the app.
class FormatUtils {
  FormatUtils._();

  static final DateFormat _dayMonth = DateFormat('d MMM');
  static final DateFormat _dayMonthYear = DateFormat('d MMM yyyy');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _fullDateTime = DateFormat('d MMM, h:mm a');

  static String dayMonth(DateTime d) => _dayMonth.format(d);
  static String dayMonthYear(DateTime d) => _dayMonthYear.format(d);
  static String time(DateTime d) => _time.format(d);
  static String fullDateTime(DateTime d) => _fullDateTime.format(d);

  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  static String relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return dayMonth(dateTime);
  }

  static String litres(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k L';
    }
    return '${value.toStringAsFixed(0)} L';
  }

  static String kwh(double value) => '${value.toStringAsFixed(1)} kWh';
}
