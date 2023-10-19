import 'dart:convert';
import 'package:e_commerce/routes.dart';
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
  @override
  void initState() {
    super.initState();
    loadLanguageData();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('role') ?? "";
    if (role == 'admin' || role == 'agent') {
      Navigator.pushNamed(context, Routes.history);
    } else {
      Navigator.pushNamed(context, Routes.home);
    }
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
