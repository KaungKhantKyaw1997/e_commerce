import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
class InsuranceRulesService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

Future<Map<String, dynamic>> addInsuranceRules(Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await http.post(
      Uri.parse(ApiConstants.insuranceRulesUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

Future<Map<String, dynamic>> deleteInsuranceRules(int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await http.delete(
      Uri.parse('${ApiConstants.insuranceRulesUrl}/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }


  Future<Map<String, dynamic>?> getInsuranceRulesData({double amount = 0.0}) async {
    var token = await storage.read(key: "token") ?? '';
    try {
      final response = await dio.get(
        '${ApiConstants.insuranceRulesUrl}?amount=$amount',
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

   Future<Map<String, dynamic>?> getInsuranceRulesDataList(
      {int page = 1, int perPage = 10, String search = ''}) async {
    var token = await storage.read(key: "token") ?? '';
    try {
      final response = await dio.get(
        '${ApiConstants.insuranceRulesUrl}?page=$page&per_page=$perPage&search=$search',
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
   Future<Map<String, dynamic>> updateInsuranceRulesData(
      Map<String, dynamic> body, int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await http.put(
      Uri.parse("${ApiConstants.insuranceRulesUrl}/$id"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}
