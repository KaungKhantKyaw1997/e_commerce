// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationUtils {
//   static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
//     var initializationSettingsIOS = IOSInitializationSettings(
//       requestSoundPermission: false,
//       requestBadgePermission: true,
//       requestAlertPermission: false,
//     );
//     var initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: onSelectNotification);
//   }

//   static Future onSelectNotification(String? payload) async {
//     // Handle notification tap here
//   }

//   static Future<void> showNotification(String title, String body, int id) async {
//     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'your_channel_id',
//       'your_channel_name',
//       'your_channel_description',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: true,
//     );
//     var iOSPlatformChannelSpecifics = IOSNotificationDetails(
//         presentAlert: true, presentBadge: true, presentSound: true);
//     var platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

//     await flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: 'New Payload', // optional, payload for onTap
//     );
//   }

//   static Future<void> cancelNotification(int notificationId) async {
//     await flutterLocalNotificationsPlugin.cancel(notificationId);
//   }

//   static Future<void> cancelAllNotifications() async {
//     await flutterLocalNotificationsPlugin.cancelAll();
//   }

//   static Future<void> scheduleNotification(
//       String title, String body, int id, DateTime scheduledTime)
