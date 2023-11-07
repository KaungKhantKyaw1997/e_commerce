import 'dart:math';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/chat_histories_provider.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> setup(BuildContext context) async {
    final crashlytic = new CrashlyticsService();
    final chatService = ChatService();

    const androidInitializationSetting =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const iosInitializationSetting = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInitializationSetting,
      iOS: iosInitializationSetting,
    );

    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload!.isNotEmpty) {
          int chatId = int.parse(details.payload.toString());
          try {
            final response =
                await chatService.getChatSessionData(chatId: chatId);
            if (response!["code"] == 200) {}
          } catch (e, s) {
            crashlytic.myGlobalErrorHandler(e, s);
          }
        } else {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          String role = prefs.getString('role') ?? "";

          BottomProvider bottomProvider =
              Provider.of<BottomProvider>(context, listen: false);
          bottomProvider.selectIndex(role == 'admin' ? 1 : 3);
          navigatorKey.currentState!.pushNamed(Routes.noti);
        }
      },
    );
  }

  static Future<void> display(String title, String body, String chatId) async {
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
      payload: chatId,
    );
  }
}
