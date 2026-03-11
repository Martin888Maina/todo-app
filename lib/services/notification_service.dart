import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

// Wraps flutter_local_notifications so the rest of the app doesn't touch it directly
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Request the exact-alarm and notification permissions on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Schedules a notification to fire at the start of the task's due date
  static Future<void> scheduleForTask({
    required int id,
    required String title,
    required DateTime dueDate,
  }) async {
    final scheduledDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      9, // fire at 9 AM on the due date
    );

    // Skip scheduling if the time has already passed
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'todo_due_dates',
        'Task Due Dates',
        channelDescription: 'Reminders for tasks with due dates',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      'Task due today',
      title,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancels a previously scheduled notification — called when a task is deleted or its due date is removed
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
