import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OrderService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>> createOrderData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token");
    final response = await http.post(
      Uri.parse(ApiConstants.ordersUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to log in: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> getOrdersData(
      {int page = 1,
      int perPage = 10,
      String fromDate = '',
      String toDate = '',
      double fromAmount = 0.0,
      double toAmount = 0.0}) async {
    var token = await storage.read(key: "token");

    var url = '${ApiConstants.ordersUrl}?page=$page&per_page=$perPage';
    if (fromDate != '') url += '&from_date=$fromDate';
    if (toDate != '') url += '&to_date=$toDate';
    if (toAmount != 0.0) url += '&from_amount=$fromAmount';
    if (toAmount != 0.0) url += '&to_amount=$toAmount';

    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        ),
        cancelToken: _cancelToken,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}
