import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ModelsService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> getModelsData(
      {int page = 1, int perPage = 10, String search = ''}) async {
    var token = await storage.read(key: "token");
    try {
      final response = await dio.get(
        '${ApiConstants.modelsUrl}',
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
