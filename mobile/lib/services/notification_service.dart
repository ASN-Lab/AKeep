import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mobile/services/hive_service.dart';
import 'package:mobile/models/asset.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'akeep_warranty_channel';
  static const List<int> reminderDays = [30, 7, 1];

  static Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      _channelId,
      'Warranty Reminders',
      importance: Importance.high,
    );
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> scheduleWarrantyReminders() async {
    final assets = HiveService.assets.values.map((e) => Asset.fromJson(e as Map<dynamic, dynamic>)).toList();

    for (final asset in assets) {
      final expiry = asset.warrantyExpiry;
      if (expiry == null) continue;

      final expiryDate = tz.TZDateTime.parse(tz.local, expiry);
      for (final days in reminderDays) {
        final scheduled = expiryDate.subtract(Duration(days: days));
        if (scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
          await _plugin.zonedSchedule(
            asset.id.hashCode + days,
            'Warranty expiring soon',
            '${asset.name} warranty expires in $days days',
            scheduled,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                _channelId,
                'Warranty Reminders',
                importance: Importance.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
    }
  }
}
