import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> setup() async {
    const androidInitializationSetting =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const iosInitializationSetting = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInitializationSetting,
      iOS: iosInitializationSetting,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  static Future<void> display(String title, String body) async {
    var random = Random();
    final id = random.nextInt(pow(2, 31).toInt() - 1);

    var androidNotificationDetail = AndroidNotificationDetails(
      'watch vault',
      'watch vault channel',
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(body, htmlFormatBigText: true),
    );

    var iosNotificatonDetail = DarwinNotificationDetails();

    var notificationDetails = NotificationDetails(
      iOS: iosNotificatonDetail,
      android: androidNotificationDetail,
    );

    flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
