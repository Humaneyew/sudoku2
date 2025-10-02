import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Handles scheduling of local notifications that remind players to solve
/// Sudoku puzzles.
class NotificationScheduler {
  NotificationScheduler._();

  static final NotificationScheduler _instance = NotificationScheduler._();

  /// Provides access to the singleton instance.
  factory NotificationScheduler() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _messages = <String>[
    'Устал? А мозг нет.  Дай ему задачку 🧩',
    '🎓Головоломки! Тренируй память!',
    'Сможешь решить задачу быстрее, чем вчера?',
  ];

  static const _scheduleCount = 180;
  static const _notificationIdBase = 5000;

  /// Initializes the notification plugin and schedules reminders.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (!Platform.isAndroid) {
      _initialized = true;
      return;
    }

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _plugin.initialize(initializationSettings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    await _configureLocalTimeZone();
    await _scheduleCycle();

    _initialized = true;
  }

  Future<void> _configureLocalTimeZone() async {
    tzdata.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timeZoneName);
      tz.setLocalLocation(location);
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> _scheduleCycle() async {
    const androidDetails = AndroidNotificationDetails(
      'sudoku_reminders',
      'Sudoku reminders',
      channelDescription: 'Напоминания вернуться к задачкам Судоку.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    // Cancel previously scheduled reminders in our ID range to avoid duplicates.
    for (var i = 0; i < _scheduleCount; i++) {
      await _plugin.cancel(_notificationIdBase + i);
    }

    final firstTrigger = _firstNotificationDate();
    final now = tz.TZDateTime.now(tz.local);

    for (var i = 0; i < _scheduleCount; i++) {
      final scheduledDate = _notificationDateForIndex(firstTrigger, i);
      if (scheduledDate.isBefore(now)) {
        continue;
      }

      await _plugin.zonedSchedule(
        _notificationIdBase + i,
        'Sudoku',
        _messages[i % _messages.length],
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'scheduled_notification_$i',
      );
    }
  }

  tz.TZDateTime _firstNotificationDate() {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 15);
    if (candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  tz.TZDateTime _notificationDateForIndex(
    tz.TZDateTime first,
    int index,
  ) {
    final targetDate = first.add(Duration(days: index * 2));
    final hour = index.isEven ? 15 : 18;
    return tz.TZDateTime(
      tz.local,
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
    );
  }
}
