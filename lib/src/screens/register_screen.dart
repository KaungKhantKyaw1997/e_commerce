import 'dart:convert';
import 'dart:io';

import 'package:animated_button_bar/animated_button_bar.dart';
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
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final crashlytic = new CrashlyticsService();
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();
  ScrollController _scrollController = ScrollController();
  AnimatedButtonController _buttonBarController = AnimatedButtonController();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();

  TextEditingController email = TextEditingController(text: '');
  TextEditingController password = TextEditingController(text: '');
  TextEditingController confirmpassword = TextEditingController(text: '');
  TextEditingController name = TextEditingController(text: '');
  TextEditingController phone = TextEditingController(text: '');

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;
  String profileImage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(source) async {
    try {
      XFile? file = await _picker.pickImage(
        source: source,
      );
      pickedFile = file;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile() async {
    try {
      var response = await AuthService.uploadFile(File(pickedFile!.path),
          resolution: "100x100");
      var res = jsonDecode(response.body);
      if (res["code"] == 200) {
        profileImage = res["url"];
      }
    } catch (error) {
      print('Error uploading file: $error');
    }
  }

  register() async {
    try {
      final body = {
        "username": email.text,
        "email": email.text,
        "password": password.text,
        "name": name.text,
        "phone": '959${phone.text}',
        "profile_image": profileImage,
        "role": "user",
        "method": "password",
        "token": "",
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

  void _showImageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      language["Make a Choice"] ?? "Make a Choice",
                      style: FontConstants.subheadline1,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 22,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 48,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: FractionallySizedBox(
                        widthFactor: 1,
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.of(context).pop();
                            _pickImage(ImageSource.gallery);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/gallery.svg",
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).primaryColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  language["Galery"] ?? "Galery",
                                  style: FontConstants.caption2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: FractionallySizedBox(
                        widthFactor: 1,
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.of(context).pop();
                            _pickImage(ImageSource.camera);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/camera.svg",
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).primaryColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  language["Camera"] ?? "Camera",
                                  style: FontConstants.caption2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _emailFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        _confirmPasswordFocusNode.unfocus();
        _nameFocusNode.unfocus();
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
                AnimatedButtonBar(
                  controller: _buttonBarController,
                  radius: 20,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColorLight,
                  elevation: 0.5,
                  borderColor: Colors.white,
                  borderWidth: 0,
                  innerVerticalPadding: 12,
                  children: [
                    ButtonBarEntry(
                      onTap: () {
                        setState(() {
                          _buttonBarController.setIndex(0);
                        });
                      },
                      child: Text(
                        language["User"] ?? "User",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _buttonBarController.index == 0
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    ButtonBarEntry(
                      onTap: () {
                        setState(() {
                          _buttonBarController.setIndex(1);
                        });
                      },
                      child: Text(
                        language["Vendor"] ?? "Vendor",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _buttonBarController.index == 1
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: 24,
                        bottom: 24,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.fillColor,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (_buttonBarController.index == 1) {
                            _pickImage(ImageSource.camera);
                          } else {
                            _showImageBottomSheet(context);
                          }
                        },
                        child: pickedFile == null
                            ? ClipOval(
                                child: Image.asset(
                                  'assets/images/profile.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipOval(
                                child: Image.file(
                                  File(pickedFile!.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          if (_buttonBarController.index == 1) {
                            _pickImage(ImageSource.camera);
                          } else {
                            _showImageBottomSheet(context);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            color: Theme.of(context).primaryColorLight,
                          ),
                          child: SvgPicture.asset(
                            "assets/icons/gallery.svg",
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
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
                      language["Name"] ?? "Name",
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
                    controller: name,
                    focusNode: _nameFocusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return language["Enter Name"] ?? "Enter Name";
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
                    textInputAction: TextInputAction.next,
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
                if (_buttonBarController.index == 0) {
                  showLoadingDialog(context);
                  if (pickedFile != null) {
                    await uploadFile();
                  }
                  register();
                } else {
                  if (pickedFile == null) {
                    ToastUtil.showToast(
                        0, language["Take Photo"] ?? "Take Photo");
                    return;
                  }
                  showLoadingDialog(context);
                  await uploadFile();
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.facebook_info,
                    arguments: {
                      "type": "agent",
                      "username": email.text,
                      "email": email.text,
                      "password": password.text,
                      "name": name.text,
                      "phone": phone.text,
                      "profile_image": profileImage,
                      "role": "agent",
                      "method": "password",
                      "token": "",
                      "seller_information": {
                        "company_name": "",
                        "professional_title": "",
                        "location": "",
                        "offline_trader": false,
                      },
                    },
                    (route) => true,
                  );
                }
              }
            },
            child: Text(
              _buttonBarController.index == 0
                  ? language["Register"] ?? "Register"
                  : language["Next"] ?? "Next",
              style: FontConstants.button1,
            ),
          ),
        ),
      ),
    );
  }
}
