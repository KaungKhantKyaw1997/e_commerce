import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddressService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> getAddressData() async {
    var token = await storage.read(key: "token");
    try {
      final response = await dio.get(
        ApiConstants.addressUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
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
