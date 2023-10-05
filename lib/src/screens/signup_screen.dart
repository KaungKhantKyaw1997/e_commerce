import 'dart:convert';
import 'dart:io';

import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();
  ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;
  String profileImage = '';
  TextEditingController username = TextEditingController(text: '');
  TextEditingController password = TextEditingController(text: '');
  TextEditingController confirmpassword = TextEditingController(text: '');

  TextEditingController name = TextEditingController(text: '');
  TextEditingController email = TextEditingController(text: '');
  TextEditingController phone = TextEditingController(text: '');
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage(source) async {
    try {
      pickedFile = await _picker.pickImage(
        source: source,
      );
      profileImage = pickedFile!.name;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile() async {
    showLoadingDialog(context);
    try {
      var response = await AuthService.uploadFile(File(pickedFile!.path));
      var res = jsonDecode(response.body);
      if (res["code"] == 200) {
        signup();
      } else {
        ToastUtil.showToast(res["code"], res["message"]);
        Navigator.pop(context);
      }
    } catch (error) {
      print('Error uploading file: $error');
      Navigator.pop(context);
    }
  }

  signup() async {
    try {
      final body = {
        "name": name.text,
        "password": password.text,
        "username": username.text,
        "email": email.text,
        "phone": '959${phone.text}',
        "profile_image": '/images/$profileImage',
      };

      final response = await authService.signupData(body);
      if (response["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pushNamed(context, Routes.signin);
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          language["Sign Up"] ?? "Sign Up",
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: 24,
                      bottom: 24,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConstants.fillcolor,
                      shape: BoxShape.circle,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _pickImage(ImageSource.gallery);
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
                        _pickImage(ImageSource.gallery);
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
                          "assets/icons/camera.svg",
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).primaryColor,
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
                  top: 8,
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
                  bottom: 16,
                ),
                child: TextFormField(
                  controller: password,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
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
                  keyboardType: TextInputType.emailAddress,
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
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  style: FontConstants.body1,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    prefixText: '+959',
                    prefixStyle: FontConstants.body2,
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
                      return language["Enter Phone Number"] ??
                          "Enter Phone Number";
                    }
                    final RegExp phoneRegExp = RegExp(r"^[+]{0,1}[0-9]{7,9}$");

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
              uploadFile();
            }
          },
          child: Text(
            language["Sign Up"] ?? "Sign Up",
            style: FontConstants.button1,
          ),
        ),
      ),
    );
  }
}
