import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/role_provider.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwitchUserScreen extends StatefulWidget {
  const SwitchUserScreen({super.key});

  @override
  State<SwitchUserScreen> createState() => _SwitchUserScreenState();
}

class _SwitchUserScreenState extends State<SwitchUserScreen> {
  final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  final storage = FlutterSecureStorage();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String _fcmToken = '';
  final authService = AuthService();
  var users = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getData() async {
    var switchuser = await storage.read(key: 'switchuser') ?? '';
    if (switchuser.isNotEmpty) {
      users = jsonDecode(switchuser);
    }
    setState(() {});
  }

  getFCMToken(index) {
    _firebaseMessaging.getToken().then((token) {
      _fcmToken = token ?? '';
      login(index);
    }).catchError((error) {
      _fcmToken = '';
      login(index);
    });
  }

  login(index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final body = {
        "username": users[index]["email"],
        "password": users[index]["password"],
      };

      final response = await authService.loginData(body);

      if (response!["code"] == 200) {
        String _email = prefs.getString("email") ?? "";
        prefs.setString("email", _email);
        prefs.setString("name", response["data"]["name"]);
        prefs.setString("role", response["data"]["role"]);

        RoleProvider roleProvider =
            Provider.of<RoleProvider>(context, listen: false);
        roleProvider.setRole(response["data"]["role"]);

        prefs.setString("profile_image", response["data"]["profile_image"]);
        await storage.write(key: "token", value: response["data"]["token"]);

        BottomProvider bottomProvider =
            Provider.of<BottomProvider>(context, listen: false);
        bottomProvider.selectIndex(0);

        fcm(response["data"]["role"] ?? "", _email, index);
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
      }
    } catch (e, s) {
      Navigator.pop(context);
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

  fcm(role, _email, index) async {
    var deviceType = Platform.isIOS ? "ios" : "android";
    final body = {
      "token": _fcmToken,
      "device_type": deviceType,
    };

    await authService.addFCMData(body);
    Navigator.pop(context);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool termsandconditions = prefs.getBool("termsandconditions") ?? false;

    Navigator.pop(context);
    if (role == 'admin') {
      Navigator.pushNamed(
        context,
        Routes.history,
      );
    } else if ((termsandconditions && _email == users[index]["email"]) ||
        role == 'agent') {
      Navigator.pushNamed(
        context,
        Routes.home,
      );
    } else {
      Navigator.pushNamed(
        context,
        Routes.termsandconditions,
        arguments: {
          "from": "login",
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          width: double.infinity,
          child: Column(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      showLoadingDialog(context);
                      await storage.delete(key: "token");
                      await FirebaseMessaging.instance.deleteToken();
                      getFCMToken(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(
                        bottom: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(
                              16,
                            ),
                            width: 40,
                            height: 40,
                            decoration: users[index]["profile_image"].isEmpty
                                ? BoxDecoration(
                                    color: ColorConstants.fillcolor,
                                    image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/profile.png"),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  )
                                : BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          '${ApiConstants.baseUrl}${users[index]["profile_image"].toString()}'),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 16,
                                top: 16,
                                bottom: 16,
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: users[index]["email"],
                                      style: FontConstants.subheadline1,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
