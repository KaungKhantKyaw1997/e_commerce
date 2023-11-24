import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/socket_provider.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  String email = "";
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email") ?? "";
    var switchuser = await storage.read(key: 'switchuser') ?? '';
    if (switchuser.isNotEmpty) {
      users = jsonDecode(switchuser);
    }
    setState(() {});
  }

  login(index, {String method = 'password'}) async {
    showLoadingDialog(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final body = {
        "username": users[index]["email"],
        "password": users[index]["password"],
        "method": method,
        "token": authToken,
      };

      final response = await authService.loginData(body);

      if (response!["code"] == 200) {
        await storage.delete(key: "token");
        await FirebaseMessaging.instance.deleteToken();

        prefs.setString("email", users[index]["email"]);
        prefs.setString("name", response["data"]["name"]);
        prefs.setString("role", response["data"]["role"]);

        prefs.setString("profile_image", response["data"]["profile_image"]);
        await storage.write(key: "token", value: response["data"]["token"]);

        BottomProvider bottomProvider =
            Provider.of<BottomProvider>(context, listen: false);
        bottomProvider.selectIndex(0);

        bool termsandconditions = prefs.getBool("termsandconditions") ?? false;

        Navigator.pop(context);
        if (response["data"]["role"] == 'admin') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.history,
            (route) => false,
          );
        } else if (response["data"]["role"] == 'agent') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
            (route) => false,
          );
        } else if (!termsandconditions && response["data"]["role"] == 'user') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.termsandconditions,
            arguments: {
              "from": "login",
            },
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
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
        scrolledUnderElevation: 0,
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
                  return Slidable(
                    key: const ValueKey(0),
                    endActionPane: ActionPane(
                      motion: const BehindMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext context) {
                            if (users[index]["email"] != email) {
                              setState(() {
                                users.removeAt(index);
                                storage.write(
                                    key: 'switchuser',
                                    value: jsonEncode(users));
                              });
                            }
                          },
                          backgroundColor: ColorConstants.redColor,
                          foregroundColor: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(index == 0 ? 10 : 0),
                            bottomRight: Radius.circular(
                                index == users.length - 1 ? 10 : 0),
                          ),
                          icon: Icons.delete,
                          label: language["Delete"] ?? "Delete",
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        if (users[index]["email"] != email) {
                          if (users[index]["method"] == "google") {
                            User? user = await AuthService.signInWithGoogle(
                                context: context);
                            if (user != null) {
                              login(index, method: users[index]["method"]);
                            }
                          } else if (users[index]["method"] == "apple") {
                            User? user = await AuthService.signInWithGoogle(
                                context: context);
                            if (user != null) {
                              login(index, method: users[index]["method"]);
                            }
                          } else if (users[index]["method"] == "facebook") {
                            User? user = await AuthService.signInWithFacebook(
                                context: context);
                            if (user != null) {
                              login(index, method: users[index]["method"]);
                            }
                          } else {
                            login(index);
                          }
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                              16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(index == 0 ? 10 : 0),
                                topRight: Radius.circular(index == 0 ? 10 : 0),
                                bottomLeft: Radius.circular(
                                    index == users.length - 1 ? 10 : 0),
                                bottomRight: Radius.circular(
                                    index == users.length - 1 ? 10 : 0),
                              ),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration:
                                      users[index]["profile_image"].isEmpty
                                          ? BoxDecoration(
                                              color: ColorConstants.fillColor,
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/profile.png"),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            )
                                          : BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    '${users[index]["profile_image"].startsWith("/images") ? ApiConstants.baseUrl : ""}${users[index]["profile_image"]}'),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                    ),
                                    child: Text(
                                      users[index]["email"],
                                      overflow: TextOverflow.ellipsis,
                                      style: FontConstants.subheadline1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          index < users.length - 1
                              ? Container(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                  ),
                                  child: const Divider(
                                    height: 0,
                                    thickness: 0.2,
                                    color: Colors.grey,
                                  ),
                                )
                              : Container(),
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
