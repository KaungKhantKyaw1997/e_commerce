import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BankAccountsService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> getBankAccountsData(
      {int page = 1,
      int perPage = 10,
      String search = '',
      String accountType = ''}) async {
    var token = await storage.read(key: "token") ?? '';
    var url =
        '${ApiConstants.bankAccountsUrl}?page=$page&per_page=$perPage&search=$search';
    url = accountType.isNotEmpty ? '${url}&account_type=$accountType' : url;
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

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}
