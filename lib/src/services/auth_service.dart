import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:e_commerce/src/providers/chat_histories_provider.dart';
import 'package:e_commerce/src/providers/chat_scroll_provider.dart';
import 'package:e_commerce/src/providers/chats_provider.dart';
import 'package:e_commerce/src/providers/message_provider.dart';
import 'package:e_commerce/src/providers/noti_provider.dart';
import 'package:e_commerce/src/providers/role_provider.dart';
import 'package:e_commerce/src/providers/socket_provider.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/settings_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AuthService {
  final crashlytic = new CrashlyticsService();
  final chatService = ChatService();
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> loginData(Map<String, dynamic> body) async {
    final response = await dio.post(
      ApiConstants.loginUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  addFCMData(Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    dio.post(
      ApiConstants.fcmUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      data: jsonEncode(body),
    );
  }

  Future<Map<String, dynamic>?> registerData(Map<String, dynamic> body) async {
    final response = await dio.post(
      ApiConstants.registerUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> forgotPasswordData(
      Map<String, dynamic> body) async {
    final response = await dio.post(
      ApiConstants.forgotPasswordUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  static Future<http.Response> uploadFile(File file,
      {String resolution = ""}) async {
    var uri = Uri.parse(
        '${ApiConstants.imageUploadUrl}${resolution.isNotEmpty ? '?resolution=${resolution}' : ''}');
    var request = http.MultipartRequest('POST', uri);

    var fileStream = http.ByteStream(file.openRead());
    var length = await file.length();
    var multipartFile = http.MultipartFile('file', fileStream, length,
        filename: file.path.split("/").last);
    request.files.add(multipartFile);

    var response = await request.send();
    if (response.statusCode == 200) {
      return http.Response.fromStream(response);
    } else {
      throw Exception('Error uploading file: ${response.statusCode}');
    }
  }

  imageToBase64(File image) async {
    List<int> imageBytes = await image.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<Map<String, dynamic>?> changePasswordData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.post(
      ApiConstants.changepasswordUrl,
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

  Future<Map<String, dynamic>?> verifyTokenData(
      Map<String, dynamic> body) async {
    final response = await dio.post(
      ApiConstants.verifyTokenUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> deleteAccountData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.delete(
      ApiConstants.deleteAccountUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data;
  }

  void initSocket(String token, context) {
    SocketProvider socketProvider =
        Provider.of<SocketProvider>(context, listen: false);

    socketProvider.socket!.clearListeners();
    socketProvider.socket!.connect();
    socketProvider.socket!.onConnect((_) {
      socketProvider.socket!.emit('join', {'token': token});
      print('Connection established');

      socketProvider.socket!.on("new-message", (data) {
        getChatMessage(data["message_id"], context);
        updateMessageStatus(data["message_id"], context);
        getChatSession(data["chat_id"], context);
      });

      socketProvider.socket!.on("update-message-status", (data) {
        ChatsProvider chatProvider =
            Provider.of<ChatsProvider>(context, listen: false);
        var chats = chatProvider.chats;
        for (var chat in chats) {
          if (chat["message_id"] == data["message_id"]) {
            chat["status"] = data["status"];
          }
        }
        chatProvider.setChats(chats);
        getChatSession(data["chat_id"], context);
      });
    });

    socketProvider.socket!
        .onDisconnect((_) => print('Connection Disconnection'));
    socketProvider.socket!.onConnectError((err) => print(err));
    socketProvider.socket!.onError((err) => print(err));
  }

  getChatSession(chatId, context) async {
    ChatHistoriesProvider chatHistoriesProvider =
        Provider.of<ChatHistoriesProvider>(context, listen: false);
    try {
      final response = await chatService.getChatSessionData(chatId: chatId);
      if (response!["code"] == 200) {
        List chatHistories = chatHistoriesProvider.chatHistories;
        bool chatExist = false;
        int index = 0;
        for (var chatHistory in chatHistories) {
          if (chatHistory["chat_id"] == chatId) {
            chatExist = true;
            break;
          }
          index++;
        }
        if (!chatExist) {
          chatHistories.insert(0, (response["data"]));
        } else {
          chatHistories[index] = response["data"];
        }
        chatHistoriesProvider.setChatHistories(chatHistories);
      }
    } catch (e, s) {
      crashlytic.myGlobalErrorHandler(e, s);
    }
  }

  getChatMessage(messageId, context) async {
    ChatScrollProvider chatScrollProvider =
        Provider.of<ChatScrollProvider>(context, listen: false);
    ChatsProvider chatProvider =
        Provider.of<ChatsProvider>(context, listen: false);
    try {
      final response =
          await chatService.getChatMessageData(messageId: messageId);
      if (response!["code"] == 200) {
        List chats = chatProvider.chats;
        bool messageExist = false;
        var chatId = 0;
        for (var chat in chats) {
          chatId = chat["chat_id"];
          if (chat["message_id"] == messageId) {
            messageExist = true;
            break;
          }
        }
        if (!messageExist && chatId == response["data"]["chat_id"]) {
          chats.insert(0, (response["data"]));
          chatProvider.setChats(chats);
          if (routeName == '/chat') {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              chatScrollProvider.chatScrollController.animateTo(
                chatScrollProvider
                    .chatScrollController.position.minScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          }
        }
      }
    } catch (e, s) {
      crashlytic.myGlobalErrorHandler(e, s);
    }
  }

  updateMessageStatus(id, context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('role') ?? "";
    MessageProvider messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    if (role == 'agent' || role == 'user') {
      int count = messageProvider.count - 1;
      messageProvider.addCount(count);
      final body = {
        "status": "read",
      };
      chatService.updateMessageStatusData(body, id);
    }
  }

  getSettings(context) async {
    try {
      var deviceType = Platform.isIOS ? "ios" : "android";
      final settingsService = SettingsService();
      final response = await settingsService.getSettingsData();
      if (response!["code"] == 200) {
        if (response["data"]["platform_required_signin"] == deviceType) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            arguments: {
              'first_page': true,
            },
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
            (route) => false,
          );
        }
      }
    } catch (e, s) {
      crashlytic.myGlobalErrorHandler(e, s);
    }
  }

  logout(context) async {
    clearData(context);
    RoleProvider roleProvider =
        Provider.of<RoleProvider>(context, listen: false);
    roleProvider.setRole('');

    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    cartProvider.addCount(0);

    NotiProvider notiProvider =
        Provider.of<NotiProvider>(context, listen: false);
    notiProvider.addCount(0);

    MessageProvider messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    messageProvider.addCount(0);

    BottomProvider bottomProvider =
        Provider.of<BottomProvider>(context, listen: false);
    bottomProvider.selectIndex(0);

    getSettings(context);
  }

  clearData(context) async {
    SocketProvider socketProvider =
        Provider.of<SocketProvider>(context, listen: false);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String _email = prefs.getString("email") ?? "";
    bool termsandconditions = prefs.getBool("termsandconditions") ?? false;
    String searchhistoriesJson = prefs.getString("searchhistories") ?? "";

    prefs.clear();
    prefs.setString("email", _email);
    prefs.setBool("termsandconditions", termsandconditions);
    prefs.setString("searchhistories", searchhistoriesJson);

    await socketProvider.socket!.disconnect();

    await storage.delete(key: "token");
    await FirebaseMessaging.instance.deleteToken();
  }

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}
