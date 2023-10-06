import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductsService {
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getProductsData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token");
    final response = await http.post(
      Uri.parse(ApiConstants.productsUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }
}
