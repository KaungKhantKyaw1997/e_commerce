import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> getNotificationsData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token");
    try {
      final response = await dio.post(
        ApiConstants.getNotificationsUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        ),
        data: body,
        cancelToken: _cancelToken,
      );

      return response.data;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> unreadNotificationsData() async {
    var token = await storage.read(key: "token");
    try {
      final response = await dio.get(
        ApiConstants.unreadNotificationsUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        ),
        cancelToken: _cancelToken,
      );

      return response.data;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateNotificationsData(
      Map<String, dynamic> body, int id) async {
    var token = await storage.read(key: "token");
    try {
      final response = await dio.put(
        '${ApiConstants.notificationsUrl}/$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        ),
        data: body,
        cancelToken: _cancelToken,
      );

      return response.data;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}
