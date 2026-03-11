import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

// Utility functions for formatting dates throughout the app
class DateHelpers {
  DateHelpers._();

  // Returns a relative string like "3 days ago" or "just now"
  static String relative(DateTime date) {
    return timeago.format(date);
  }

  // Full date for display in detail views, e.g. "Mar 15, 2026"
  static String full(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  // Short date for task tiles, e.g. "Mar 15"
  static String short(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static bool isOverdue(DateTime? dueDate, bool isCompleted) {
    if (dueDate == null || isCompleted) return false;
    final today = DateTime.now();
    return dueDate.isBefore(DateTime(today.year, today.month, today.day));
  }
}
