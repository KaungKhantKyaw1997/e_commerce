import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> getNotificationsData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.post(
      ApiConstants.getNotificationsUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      data: jsonEncode(body),
      cancelToken: _cancelToken,
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> unreadNotificationsData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.unreadNotificationsUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      cancelToken: _cancelToken,
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> updateNotificationsData(
      Map<String, dynamic> body, int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.put(
      '${ApiConstants.notificationsUrl}/$id',
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      data: jsonEncode(body),
      cancelToken: _cancelToken,
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> notifyAllData(Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.post(
      '${ApiConstants.fcmUrl}/notify-all',
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      data: jsonEncode(body),
      cancelToken: _cancelToken,
    );

    return response.data;
  }

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}
