import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
class RatingService
{
   final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>> addSellerReviewsData(Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await http.post(
      Uri.parse(ApiConstants.sellerReviews),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>?> getSellerReviewsData(
      int shopId) async {
    var token = await storage.read(key: "token") ?? '';
    try {
      final response = await dio.get(
        '${ApiConstants.shopsUrl}/${shopId}/reviews',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
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