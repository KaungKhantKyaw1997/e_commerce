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
      {int page = 1, int perPage = 10, String search = ''}) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      '${ApiConstants.chatSessionsUrl}?page=$page&per_page=$perPage&search=$search',
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

  Future<Map<String, dynamic>?> getChatSessionData(
      {int chatId = 0, int receiverId = 0}) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      '${ApiConstants.chatSessionsUrl}/$chatId?receiver_id=$receiverId',
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

  Future<Map<String, dynamic>?> getChatMessagesData(
      {int chatId = 0,
      int receiverId = 0,
      int page = 1,
      int perPage = 10,
      String status = ''}) async {
    var token = await storage.read(key: "token") ?? '';
    var url =
        '${ApiConstants.chatSessionsUrl}/$chatId/chat-messages?page=$page&per_page=$perPage&receiver_id=$receiverId';
    url = status.isNotEmpty ? url += '&status=$status' : url;
    final response = await dio.get(
      url,
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

  Future<Map<String, dynamic>?> getChatMessageData({int messageId = 0}) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      '${ApiConstants.chatMessagesUrl}/$messageId',
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

  updateMessageStatusData(Map<String, dynamic> body, int id) async {
    var token = await storage.read(key: "token") ?? '';
    dio.put(
      '${ApiConstants.messagesUrl}/$id/status',
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      data: jsonEncode(body),
    );
  }

  Future<Map<String, dynamic>?> deleteMessageData(int messageId) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.delete(
      '${ApiConstants.messagesUrl}/$messageId',
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> deleteSessionData(int chatId) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.delete(
      '${ApiConstants.chatSessionsUrl}/$chatId',
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

  Future<Map<String, dynamic>?> getLastActiveAtData(int userId) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      '${ApiConstants.usersUrl}/$userId/last-active-at',
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
