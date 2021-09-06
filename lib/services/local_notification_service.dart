import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late NotificationDetails _notificationDetails;
  final onNotification = BehaviorSubject<String?>();

  LocalNotificationService() {
    initialize();
  }

  Future<void> _configureTimezone() async {
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
  }

  Future<void> initialize() async {
    AndroidInitializationSettings _androidSettings = AndroidInitializationSettings("ic_launcher");
    IOSInitializationSettings _iosSettings = IOSInitializationSettings();
    final InitializationSettings _initSettings = InitializationSettings(
      android: _androidSettings,
      iOS: _iosSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(_initSettings, onSelectNotification: (payload) async {
      onNotification.add(payload);
    });
    // Configure Timezone
    await _configureTimezone();
    // Configure channel
    _notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'CHANNEL_ID',
        'CHANNEL_NAME',
        'CHANNEL_DESCRIPTION',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  Future<void> scheduleDaily() async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Good Morning',
      'What do you have on your mind today ?',
      _daily(Time(11, 56)),
      _notificationDetails,
      payload: 'Todo_reminder',
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _daily(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduleDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour);
    return scheduleDate.isBefore(now) ? scheduleDate.add(Duration(days: 1)) : scheduleDate;
  }

  Future<void> scheduleYearly(int id, String title, String body, String payload, DateTime date) async {
    _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _yearly(date),
      _notificationDetails,
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _yearly(DateTime date) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduleDate = tz.TZDateTime(tz.local, date.year, date.month, date.day, 0);
    return scheduleDate.isBefore(now) ? tz.TZDateTime(tz.local, date.year + 1, date.month, date.day) : scheduleDate;
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
