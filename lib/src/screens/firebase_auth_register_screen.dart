import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FirebaseAuthRegisterScreen extends StatefulWidget {
  const FirebaseAuthRegisterScreen({super.key});

  @override
  State<FirebaseAuthRegisterScreen> createState() =>
      _FirebaseAuthRegisterScreenState();
}

class _FirebaseAuthRegisterScreenState
    extends State<FirebaseAuthRegisterScreen> {
  final crashlytic = new CrashlyticsService();
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();
  ScrollController _scrollController = ScrollController();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();

  TextEditingController password = TextEditingController(text: '');
  TextEditingController confirmpassword = TextEditingController(text: '');
  TextEditingController phone = TextEditingController(text: '');

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String method = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        method = arguments["method"] ?? "";
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  register() async {
    try {
      final body = {
        "username": "",
        "email": "",
        "password": password.text,
        "name": "",
        "phone": "959${phone.text}",
        "profile_image": "",
        "role": "user",
        "method": method,
        "token": authToken,
      };

      final response = await authService.registerData(body);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.login,
        );
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _passwordFocusNode.unfocus();
        _confirmPasswordFocusNode.unfocus();
        _phoneFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            language["Register"] ?? "Register",
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
                    bottom: 16,
                  ),
                  child: TextFormField(
                    controller: password,
                    focusNode: _passwordFocusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    obscureText: obscurePassword,
                    style: FontConstants.body1,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ColorConstants.fillColor,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return language["Enter Password"] ?? "Enter Password";
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
                      language["Confirm Password"] ?? "Confirm Password",
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
                    controller: confirmpassword,
                    focusNode: _confirmPasswordFocusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    obscureText: obscureConfirmPassword,
                    style: FontConstants.body1,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ColorConstants.fillColor,
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
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                        icon: SvgPicture.asset(
                          obscureConfirmPassword
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return language["Enter Confirm Password"] ??
                            "Enter Confirm  Password";
                      } else if (value != password.text) {
                        return language["Passwords don't match"] ??
                            "Passwords don't match";
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
                      language["Phone Number"] ?? "Phone Number",
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
                    controller: phone,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    style: FontConstants.body1,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      prefixText: '+959',
                      prefixStyle: FontConstants.body2,
                      filled: true,
                      fillColor: ColorConstants.fillColor,
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
                        return language["Enter Phone Number"] ??
                            "Enter Phone Number";
                      }
                      final RegExp phoneRegExp =
                          RegExp(r"^[+]{0,1}[0-9]{7,9}$");

                      if (!phoneRegExp.hasMatch(value)) {
                        return language["Invalid Phone Number"] ??
                            "Invalid Phone Number";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 24,
          ),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                showLoadingDialog(context);
                register();
              }
            },
            child: Text(
              language["Register"] ?? "Register",
              style: FontConstants.button1,
            ),
          ),
        ),
      ),
    );
  }
}
