import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();
  FocusNode _currentPasswordFocusNode = FocusNode();
  FocusNode _newPasswordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();
  ScrollController _scrollController = ScrollController();
  TextEditingController currentpassword = TextEditingController(text: '');
  TextEditingController newpassword = TextEditingController(text: '');
  TextEditingController confirmpassword = TextEditingController(text: '');
  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  changepassword() async {
    showLoadingDialog(context);
    try {
      final body = {
        "old_password": currentpassword.text,
        "new_password": newpassword.text,
      };

      final response = await authService.changePasswordData(body);
      Navigator.pop(context);
      if (response["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _currentPasswordFocusNode.unfocus();
        _newPasswordFocusNode.unfocus();
        _confirmPasswordFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            language["Change Password"] ?? "Change Password",
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
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language["Current Password"] ?? "Current Password",
                        style: FontConstants.caption1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: TextFormField(
                      controller: currentpassword,
                      focusNode: _currentPasswordFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      obscureText: obscureCurrentPassword,
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
                              obscureCurrentPassword = !obscureCurrentPassword;
                            });
                          },
                          icon: SvgPicture.asset(
                            obscureCurrentPassword
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return language["Enter Current Password"] ??
                              "Enter Current Password";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language["New Password"] ?? "New Password",
                        style: FontConstants.caption1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: TextFormField(
                      controller: newpassword,
                      focusNode: _newPasswordFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      obscureText: obscureNewPassword,
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
                              obscureNewPassword = !obscureNewPassword;
                            });
                          },
                          icon: SvgPicture.asset(
                            obscureNewPassword
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return language["Enter New Password"] ??
                              "Enter New Password";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
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
                  TextFormField(
                    controller: confirmpassword,
                    focusNode: _confirmPasswordFocusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    obscureText: obscureConfirmPassword,
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
                            Theme.of(context).primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return language["Enter Confirm Password"] ??
                            "Enter Confirm  Password";
                      } else if (value != newpassword.text) {
                        return language["Passwords don't match"] ??
                            "Passwords don't match";
                      }
                      return null;
                    },
                  ),
                ],
              ),
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
                changepassword();
              }
            },
            child: Text(
              language["Change Password"] ?? "Change Password",
              style: FontConstants.button1,
            ),
          ),
        ),
      ),
    );
  }
}
