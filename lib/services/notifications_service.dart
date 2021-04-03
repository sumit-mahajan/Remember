import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/subjects.dart';

class NotificationPlugin {
  //
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final BehaviorSubject<ReceivedNotification>
      didReceivedLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();
  var initializationSettings;

  NotificationPlugin._() {
    init();
  }

  init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecifics();
  }

  initializePlatformSpecifics() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('new_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(
            id: id, title: title, body: body, payload: payload);
        didReceivedLocalNotificationSubject.add(receivedNotification);
      },
    );

    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
          alert: false,
          badge: true,
          sound: true,
        );
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      onNotificationClick(payload);
    });
  }

//  Future<void> showNotification() async {
//    var androidChannelSpecifics = AndroidNotificationDetails(
//      'CHANNEL_ID',
//      'CHANNEL_NAME',
//      "CHANNEL_DESCRIPTION",
//      importance: Importance.Max,
//      priority: Priority.High,
//      playSound: true,
//      timeoutAfter: 2000,
//      styleInformation: DefaultStyleInformation(true, true),
//    );
//    var iosChannelSpecifics = IOSNotificationDetails();
//    var platformChannelSpecifics =
//        NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);
//    await flutterLocalNotificationsPlugin.show(
//      0,
//      'Test Title',
//      'Test Body', //null
//      platformChannelSpecifics,
//      payload: 'New Payload',
//    );
//  }

  Future<void> showDailyAtTime() async {
    var time = Time(8, 0, 0);
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 4',
      'CHANNEL_NAME 4',
      "CHANNEL_DESCRIPTION 4",
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      'Good Morning, what\'s on your mind today ?',
      'Add today\'s tasks', //null
      time,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }

  Future<void> scheduleNotification(
      int id, DateTime eDate, String eName, bool f) async {
    // if (f) {
    //   if (DateTime(DateTime.now().year, eDate.month, eDate.day).isAfter(DateTime.now())) {
    //     eDate = DateTime(DateTime.now().year, eDate.month, eDate.day);
    //   } else {
    //     eDate = DateTime(DateTime.now().year + 1, eDate.month, eDate.day);
    //   }
    // }
    var scheduleNotificationDateTime = eDate;
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 1',
      'CHANNEL_NAME 1',
      "CHANNEL_DESCRIPTION 1",
      importance: Importance.Max,
      priority: Priority.High,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      androidChannelSpecifics,
      iosChannelSpecifics,
    );
    if (!f) {
      id = (eDate.day * 100 + eDate.month) * 10000 + eDate.year;
    }
    print(id);
    await flutterLocalNotificationsPlugin.schedule(
      id,
      f ? 'It\'s $eName\'s Birthday' : '$eName',
      f ? 'Send $eName Birthday wishes' : 'You have event(s) today',
      scheduleNotificationDateTime,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }

  Future<int> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p.length;
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}

NotificationPlugin notificationPlugin = NotificationPlugin._();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}
