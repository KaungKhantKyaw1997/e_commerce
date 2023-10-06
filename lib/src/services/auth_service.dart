import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> signinData(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.signinUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> signupData(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.signupUrl),
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

  signout(BuildContext context) {
    clearData();
    Navigator.pushNamed(context, Routes.signin);
  }

  clearData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await storage.delete(key: "token");
  }
}
