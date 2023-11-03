import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> sendMessageData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.post(
      ApiConstants.sendMessageUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> getChatSessionsData(
      {int page = 1, int perPage = 10}) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      '${ApiConstants.chatSessionsUrl}?page=$page&per_page=$perPage',
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

  Future<Map<String, dynamic>?> getChatMessagesData(int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      '${ApiConstants.chatSessionsUrl}/$id/chat-messages',
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

  Future<Map<String, dynamic>?> updateMessageStatusData(
      Map<String, dynamic> body, int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.put(
      '${ApiConstants.messagesUrl}/$id/status',
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> deleteMessageData(int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.delete(
      '${ApiConstants.messagesUrl}/$id',
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> getTotalUnreadCountsData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.totalUnreadCountsUrl,
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

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}
