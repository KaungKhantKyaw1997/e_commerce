import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/settings_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerce/global.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final crashlytic = new CrashlyticsService();
  final settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    loadLanguageData();
    getSettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadLanguageData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var lang = prefs.getString("language") ?? "eng";
    if (lang == 'eng') {
      selectedLangIndex = 0;
    } else {
      selectedLangIndex = 1;
    }

    try {
      final response =
          await rootBundle.loadString('assets/languages/$lang.json');
      final dynamic data = json.decode(response);
      if (data is Map<String, dynamic>) {
        setState(() {
          language = data.cast<String, String>();
        });
      }
    } catch (e) {
      print('Error loading language data: $e');
    }
  }

  getSettings() async {
    try {
      var deviceType = Platform.isIOS ? "ios" : "android";
      final response = await settingsService.getSettingsData();
      if (response!["code"] == 200) {
        if (response["data"]["platform_required_signin"] == deviceType) {
          Navigator.pushNamed(
            context,
            Routes.login,
            arguments: {
              'first_page': true,
            },
          );
        } else {
          getData();
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
      if (e is DioException &&
          e.error is SocketException &&
          !isConnectionTimeout) {
        isConnectionTimeout = true;
        Navigator.pushNamed(
          context,
          Routes.connection_timeout,
        );
        return;
      }
      crashlytic.myGlobalErrorHandler(e, s);
      if (e is DioException && e.response != null && e.response!.data != null) {
        if (e.response!.data["message"] == "invalid token" ||
            e.response!.data["message"] ==
                "invalid authorization header format") {
          Navigator.pushNamed(
            context,
            Routes.unauthorized,
          );
        } else {
          ToastUtil.showToast(
              e.response!.data['code'], e.response!.data['message']);
        }
      }
    }
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('role') ?? "";
    if (role == 'admin') {
      Navigator.pushNamed(context, Routes.history);
    } else {
      Navigator.pushNamed(context, Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 32,
            ),
            child: SpinKitThreeBounce(
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
