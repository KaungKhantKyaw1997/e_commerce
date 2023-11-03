import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:e_commerce/src/providers/noti_provider.dart';
import 'package:e_commerce/src/providers/role_provider.dart';
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
  late IO.Socket socket;

  final crashlytic = new CrashlyticsService();
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

  Future<Map<String, dynamic>?> addFCMData(Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.post(
      ApiConstants.fcmUrl,
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

  initSocket(String token) {
    socket = IO.io(ApiConstants.socketServerURL, <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
    });
    socket.onConnect((_) {
      socket.emit('join', {'token': token});
      print('Connection established');
      socket.on("chat", (data) {
        print(data);
      });
    });
    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));
  }

  getSettings(context) async {
    try {
      var deviceType = Platform.isIOS ? "ios" : "android";
      final settingsService = SettingsService();
      final response = await settingsService.getSettingsData();
      if (response!["code"] == 200) {
        if (response["data"]["platform_required_signin"] == deviceType) {
          Navigator.pushNamed(
            context,
            Routes.login,
            arguments: {
              'first_page': true,
            },
          );
        } else {
          Navigator.pushNamed(context, Routes.home);
        }
      }
    } catch (e, s) {
      crashlytic.myGlobalErrorHandler(e, s);
    }
  }

  logout(BuildContext context) async {
    clearData();
    RoleProvider roleProvider =
        Provider.of<RoleProvider>(context, listen: false);
    roleProvider.setRole('');

    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    cartProvider.addCount(0);

    NotiProvider notiProvider =
        Provider.of<NotiProvider>(context, listen: false);
    notiProvider.addCount(0);

    BottomProvider bottomProvider =
        Provider.of<BottomProvider>(context, listen: false);
    bottomProvider.selectIndex(0);

    getSettings(context);
  }

  clearData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String _email = prefs.getString("email") ?? "";
    bool termsandconditions = prefs.getBool("termsandconditions") ?? false;
    String searchhistoriesJson = prefs.getString("searchhistories") ?? "";

    prefs.clear();
    prefs.setString("email", _email);
    prefs.setBool("termsandconditions", termsandconditions);
    prefs.setString("searchhistories", searchhistoriesJson);

    if (socket != null) {
      socket.disconnect();
      socket.dispose();
    }

    await storage.delete(key: "token");
    await FirebaseMessaging.instance.deleteToken();
  }

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}
