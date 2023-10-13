import 'dart:convert';
import 'dart:io';

import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:e_commerce/src/providers/noti_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> loginData(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.loginUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> registerData(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.registerUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  static Future<http.Response> uploadFile(File file) async {
    var uri = Uri.parse(ApiConstants.imageUploadUrl);
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

  Future<Map<String, dynamic>> changePasswordData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token");
    final response = await http.post(
      Uri.parse(ApiConstants.changepasswordUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyTokenData(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.verifyTokenUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> addFCMData(Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await http.post(
      Uri.parse(ApiConstants.fcmUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != '') 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  logout(BuildContext context) {
    clearData();
    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    cartProvider.addCount(0);

    NotiProvider notiProvider =
        Provider.of<NotiProvider>(context, listen: false);
    notiProvider.addCount(0);

    BottomProvider bottomProvider =
        Provider.of<BottomProvider>(context, listen: false);
    bottomProvider.selectIndex(0);

    Navigator.pushNamed(context, Routes.home);
  }

  clearData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await FirebaseMessaging.instance.deleteToken();
    await storage.delete(key: "token");
  }
}
