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
import 'package:e_commerce/src/providers/socket_provider.dart';
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

  login(index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final body = {
        "username": users[index]["email"],
        "password": users[index]["password"],
      };

      final response = await authService.loginData(body);

      Navigator.pop(context);
      if (response!["code"] == 200) {
        authService.clearData(context);
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

        bool termsandconditions = prefs.getBool("termsandconditions") ?? false;

        if (response["data"]["role"] == 'admin') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.history,
            (route) => false,
          );
        } else if ((termsandconditions && _email == users[index]["email"]) ||
            response["data"]["role"] == 'agent') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.termsandconditions,
            arguments: {
              "from": "login",
            },
            (route) => false,
          );
        }

        SocketProvider socketProvider =
            Provider.of<SocketProvider>(context, listen: false);
        await socketProvider.socket!.disconnect();
        authService.initSocket(response["data"]["token"], context);

        _firebaseMessaging.getToken().then((token) {
          _fcmToken = token ?? '';
          fcm();
        }).catchError((error) {
          _fcmToken = '';
          fcm();
        });
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
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

  fcm() {
    var deviceType = Platform.isIOS ? "ios" : "android";
    final body = {
      "token": _fcmToken,
      "device_type": deviceType,
    };

    authService.addFCMData(body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          language["Switch User"] ?? "Switch User",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
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
                      login(index);
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
