import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:look_up_coupons/services/database_service.dart';

class NotificationService {
  NotificationService({
    required this.databaseService,
  });

  final DatabaseService databaseService;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    tzdata.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    const channel = AndroidNotificationChannel(
      'daily_deals',
      'Daily Deals',
      description: 'Daily summary of new or expiring deals.',
      importance: Importance.defaultImportance,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  Future<void> scheduleDailySummary() async {
    if (!_initialized) return;

    final summary = await _buildSummary();
    final scheduledTime = _nextInstanceOfHour(9);

    // Schedule a daily 9 AM reminder. This is refreshed on app launch.
    await _plugin.zonedSchedule(
      1001,
      'Look Up Coupons',
      summary,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_deals',
          'Daily Deals',
          channelDescription: 'Daily summary of new or expiring deals.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfHour(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<String> _buildSummary() async {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 3));

    final deals = await databaseService.getDeals();
    final expiringSoon = deals
        .where((deal) => deal.expiresAt.isAfter(now))
        .where((deal) => deal.expiresAt.isBefore(soon))
        .length;

    final newlyAdded = deals
        .where((deal) => deal.createdAt.isAfter(now.subtract(const Duration(days: 1))))
        .length;

    if (expiringSoon == 0 && newlyAdded == 0) {
      return 'Check today\'s nearby deals and coupons.';
    }

    return 'New deals: $newlyAdded | Expiring soon: $expiringSoon';
  }
}
