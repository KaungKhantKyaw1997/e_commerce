import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductsService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>> addProductData(Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await http.post(
      Uri.parse(ApiConstants.productsUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != '') 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateProductData(
      int id, Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await http.put(
      Uri.parse("${ApiConstants.productsUrl}/$id"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != '') 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteProductData(int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await http.delete(
      Uri.parse('${ApiConstants.productsUrl}/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != '') 'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>?> getProductsData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    try {
      final response = await dio.post(
        ApiConstants.getProductsUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            if (token != '') 'Authorization': 'Bearer $token',
          },
        ),
        data: jsonEncode(body),
        cancelToken: _cancelToken,
      );

      return response.data;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProductData(int id) async {
    var token = await storage.read(key: "token") ?? '';
    try {
      final response = await dio.get(
        '${ApiConstants.productsUrl}?product_id=$id',
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
