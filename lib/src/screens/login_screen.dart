import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/palette.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
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
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final crashlytic = new CrashlyticsService();
  ScrollController _scrollController = ScrollController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String _fcmToken = '';
  final authService = AuthService();
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  TextEditingController email = TextEditingController(text: '');
  TextEditingController password = TextEditingController(text: '');
  bool obscurePassword = true;
  bool firstPage = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        firstPage = arguments["first_page"] ?? false;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String value) {
    if (value.isNotEmpty) {
      showLoadingDialog(context);
      login();
    }
  }

  login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final body = {
        "username": email.text,
        "password": password.text,
      };

      final response = await authService.loginData(body);

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

        var switchuser = await storage.read(key: 'switchuser') ?? '';

        if (switchuser.isEmpty) {
          storage.write(
            key: 'switchuser',
            value: jsonEncode([
              {
                "profile_image": response["data"]["profile_image"],
                "email": email.text,
                "password": password.text,
              }
            ]),
          );
        } else {
          var users = jsonDecode(switchuser);
          bool contain = false;
          for (var user in users) {
            if (user["email"] == email.text) {
              contain = true;
              break;
            }
          }
          if (!contain) {
            users.add({
              "profile_image": response["data"]["profile_image"],
              "email": email.text,
              "password": password.text,
            });
            storage.write(key: 'switchuser', value: jsonEncode(users));
          }
        }

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
        } else if ((termsandconditions && _email == email.text) ||
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _emailFocusNode.unfocus();
        _passwordFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            language["Log In"] ?? "Log In",
            style: FontConstants.title1,
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 24,
                  ),
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/login.png'),
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "Watch Vault",
                        textAlign: TextAlign.center,
                        style: FontConstants.title2,
                      ),
                      Text(
                        " by Diggie",
                        textAlign: TextAlign.center,
                        style: FontConstants.subheadline2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      language["Email"] ?? "Email",
                      style: FontConstants.caption1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: TextFormField(
                    controller: email,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    style: FontConstants.body1,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ColorConstants.fillcolor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return language["Enter Email"] ?? "Enter Email";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      language["Password"] ?? "Password",
                      style: FontConstants.caption1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 24,
                  ),
                  child: TextFormField(
                    controller: password,
                    focusNode: _passwordFocusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    obscureText: obscurePassword,
                    style: FontConstants.body1,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ColorConstants.fillcolor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: SvgPicture.asset(
                          obscurePassword
                              ? "assets/icons/eye-close.svg"
                              : "assets/icons/eye.svg",
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    onFieldSubmitted: _handleSubmitted,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return language["Enter Password"] ?? "Enter Password";
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        showLoadingDialog(context);
                        login();
                      }
                    },
                    child: Text(
                      language["Log In"] ?? "Log In",
                      style: FontConstants.button1,
                    ),
                  ),
                ),
                !firstPage
                    ? Container(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 24,
                        ),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              width: 0.5,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              Routes.register,
                            );
                          },
                          child: Text(
                            language["Register"] ?? "Register",
                            style: FontConstants.button2,
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 24,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.forgot_password,
                        (route) => true,
                      );
                    },
                    child: Center(
                      child: Text(
                        '${language["Forgot Password"]}?' ?? "Forgot Password?",
                        style: FontConstants.caption5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
