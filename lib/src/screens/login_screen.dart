import 'dart:io';

import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/services/auth_service.dart';
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
  ScrollController _scrollController = ScrollController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String _fcmToken = '';
  final authService = AuthService();
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  FocusNode _userFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  TextEditingController username = TextEditingController(text: '');
  TextEditingController password = TextEditingController(text: '');
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String value) {
    if (value.isNotEmpty) {
      getFCMToken();
    }
  }

  getFCMToken() {
    showLoadingDialog(context);
    _firebaseMessaging.getToken().then((token) {
      _fcmToken = token ?? '';
      login();
    }).catchError((error) {
      _fcmToken = '';
      login();
    });
  }

  login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final body = {
        "username": username.text,
        "password": password.text,
      };

      final response = await authService.loginData(body);

      if (response["code"] == 200) {
        prefs.setString("name", response["data"]["name"]);
        prefs.setString("role", response["data"]["role"]);
        prefs.setString("profile_image", response["data"]["profile_image"]);
        await storage.write(key: "token", value: response["data"]["token"]);

        BottomProvider bottomProvider =
            Provider.of<BottomProvider>(context, listen: false);
        bottomProvider.selectIndex(0);

        fcm(response["data"]["role"] ?? "");
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
    }
  }

  fcm(role) async {
    var deviceType = Platform.isIOS ? "ios" : "android";
    final body = {
      "token": _fcmToken,
      "device_type": deviceType,
    };

    await authService.addFCMData(body);
    Navigator.pop(context);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool termsandcondition = prefs.getBool("termsandcondition") ?? false;

    if (role == 'admin') {
      Navigator.pushNamed(
        context,
        Routes.history,
      );
    } else if (termsandcondition) {
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _userFocusNode.unfocus();
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
            color: Theme.of(context).primaryColor,
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
                      language["User Name"] ?? "User Name",
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
                    controller: username,
                    focusNode: _userFocusNode,
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
                        return language["Enter User Name"] ?? "Enter User Name";
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
                            Theme.of(context).primaryColor,
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
                    bottom: 16,
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        getFCMToken();
                      }
                    },
                    child: Text(
                      language["Log In"] ?? "Log In",
                      style: FontConstants.button1,
                    ),
                  ),
                ),
                Container(
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
                        color: Theme.of(context).primaryColor,
                        width: 0.5,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.register);
                    },
                    child: Text(
                      language["Register"] ?? "Register",
                      style: FontConstants.button2,
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
