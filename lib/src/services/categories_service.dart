import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CategoriesService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>> addCategoryData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await http.post(
      Uri.parse(ApiConstants.categoriesUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != '') 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateCategoryData(
      int id, Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await http.put(
      Uri.parse("${ApiConstants.categoriesUrl}/$id"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != '') 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteCategoryData(int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await http.delete(
      Uri.parse('${ApiConstants.categoriesUrl}/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != '') 'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>?> getCategoriesData(
      {int page = 1, int perPage = 10, String search = ''}) async {
    var token = await storage.read(key: "token") ?? '';
    try {
      final response = await dio.get(
        '${ApiConstants.categoriesUrl}?page=$page&per_page=$perPage&search=$search',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            if (token != '') 'Authorization': 'Bearer $token',
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

  Future<Map<String, dynamic>?> getCategoryData(int id) async {
    var token = await storage.read(key: "token") ?? '';
    try {
      final response = await dio.get(
        '${ApiConstants.categoriesUrl}?brand_id=$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            if (token != '') 'Authorization': 'Bearer $token',
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

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}
