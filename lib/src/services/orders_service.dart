import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OrderService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> addOrderData(Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.post(
      ApiConstants.ordersUrl,
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

  Future<Map<String, dynamic>?> updateOrderData(
      int id, Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.put(
      '${ApiConstants.ordersUrl}/$id',
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

  Future<Map<String, dynamic>?> getOrdersData(
      {int page = 1,
      int perPage = 10,
      String fromDate = '',
      String toDate = '',
      double fromAmount = 0.0,
      double toAmount = 0.0}) async {
    var token = await storage.read(key: "token") ?? '';
    var url = '${ApiConstants.ordersUrl}?page=$page&per_page=$perPage';
    if (fromDate.isNotEmpty) url += '&from_date=$fromDate';
    if (toDate.isNotEmpty) url += '&to_date=$toDate';
    if (toAmount != 0.0) url += '&from_amount=$fromAmount';
    if (toAmount != 0.0) url += '&to_amount=$toAmount';

    final response = await dio.get(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      cancelToken: _cancelToken,
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> getOrderDetailsData(int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      '${ApiConstants.orderUrl}?order_id=$id',
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      cancelToken: _cancelToken,
    );

    return response.data;
  }

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}
