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

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to log in: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> signupData(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.signupUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to log in: ${response.statusCode}');
    }
  }

  static Future<http.Response> uploadFile(File file) async {
    var uri = Uri.parse(ApiConstants.imageUploadUrl);
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      return http.Response.fromStream(response);
    } else {
      throw Exception('Error uploading file: ${response.statusCode}');
    }
  }

  signout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await storage.delete(key: "token");
    Navigator.pushNamed(context, Routes.signin);
  }
}
