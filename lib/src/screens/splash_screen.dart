import 'dart:convert';
import 'dart:io';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/setting_service.dart';
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
  final authService = AuthService();
  final settingService = SettingService();

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
      final response = await settingService.getSettingsData();
      if (response!["code"] == 200) {
        if (deviceType == 'ios') {
          authService.showVersionDialog(response["data"]["ios_version"],
              response["data"]["version_update_message"], context);
        } else {
          authService.showVersionDialog(response["data"]["android_version"],
              response["data"]["version_update_message"], context);
        }

        if (response["data"]["platform_required_signin"] == deviceType) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            arguments: {
              'first_page': true,
            },
            (route) => false,
          );
        } else {
          getData();
        }
      }
    } catch (e, s) {
      crashlytic.myGlobalErrorHandler(e, s);
    }
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('role') ?? "";
    if (role == 'admin') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.history,
        (route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.home,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                  ),
                  shape: BoxShape.circle,
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
        ),
      ),
    );
  }
}
