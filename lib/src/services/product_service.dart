import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info/package_info.dart';

class ProductService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> addProductData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.post(
      ApiConstants.productsUrl,
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

  Future<Map<String, dynamic>?> updateProductData(
      Map<String, dynamic> body, int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.put(
      '${ApiConstants.productsUrl}/$id',
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

  Future<Map<String, dynamic>?> deleteProductData(int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.delete(
      '${ApiConstants.productsUrl}/$id',
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> getProductsData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var version = packageInfo.version;

    var deviceType = Platform.isIOS ? "ios" : "android";

    body["platform"] = deviceType;
    body["version"] = version;

    final response = await dio.post(
      ApiConstants.getProductsUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      data: jsonEncode(body),
      cancelToken: _cancelToken,
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> getProductData(int id) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      '${ApiConstants.productsUrl}/$id',
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

  Future<Map<String, dynamic>?> getDialGlassTypesData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.dialGlassTypesUrl,
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

  Future<Map<String, dynamic>?> getConditionsData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.conditionsUrl,
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

  Future<Map<String, dynamic>?> getWarrantyTypesData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.warrantyTypesUrl,
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

  Future<Map<String, dynamic>?> getOtherAccessoriesTypesData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.otherAccessoriesTypesUrl,
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

  Future<Map<String, dynamic>?> getCaseDiametersData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.caseDiametersUrl,
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

  Future<Map<String, dynamic>?> getCaseWidthsData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.caseWidthsUrl,
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

  Future<Map<String, dynamic>?> getMovementTypesData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.movementTypesUrl,
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

  Future<Map<String, dynamic>?> getStrapMaterialsData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.strapMaterialsUrl,
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

  Future<Map<String, dynamic>?> getCaseMaterialsData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.caseMaterialsUrl,
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

  Future<Map<String, dynamic>?> getStockQuantitiesData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.stockQuantitiesUrl,
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

  Future<Map<String, dynamic>?> getCaseDepthsData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.caseDepthsUrl,
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

  Future<Map<String, dynamic>?> getWaterResistancesData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.waterResistancesUrl,
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

  Future<Map<String, dynamic>?> getMovementCountriesData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.get(
      ApiConstants.movementCountriesUrl,
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
