import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';

class SettingsService {
  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> getSettingsData() async {
    final response = await dio.get(
      ApiConstants.settingsUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
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
