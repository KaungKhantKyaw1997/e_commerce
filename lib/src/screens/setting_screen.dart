import 'dart:ui';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final authService = AuthService();
  String lang = '';
  String profileImage = '';
  String profileName = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lang = prefs.getString('language') ?? "eng";
      profileImage = prefs.getString('profile_image') ?? "";
      profileName = prefs.getString('name') ?? "";
    });
  }

  showExitDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            language["Sign Out"] ?? "Sign Out",
            style: FontConstants.body1,
          ),
          content: Text(
            language["Are you sure you want to sign out?"] ??
                "Are you sure you want to sign out?",
            style: FontConstants.caption2,
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: Text(
                language["Cancel"] ?? "Cancel",
                style: FontConstants.button2,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColor),
              ),
              child: Text(
                language["Ok"] ?? "Ok",
                style: FontConstants.button1,
              ),
              onPressed: () async {
                authService.signout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          language["Setting"] ?? "Setting",
          style: FontConstants.title1,
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.only(
                    bottom: 24,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigator.pushNamed(context, Routes.profile);
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  right: 16,
                                  top: 8,
                                  bottom: 8,
                                ),
                                width: 60,
                                height: 60,
                                decoration: profileImage == ''
                                    ? BoxDecoration(
                                        color: ColorConstants.fillcolor,
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/profile.png"),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      )
                                    : BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '${ApiConstants.baseUrl}${profileImage.toString()}'),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
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
                                          text: profileName,
                                          style: FontConstants.caption2,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 0,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            language["General Info"] ?? "General Info",
                            style: FontConstants.smallText1,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.language);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 16,
                                  top: 16,
                                  bottom: 16,
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/global.svg",
                                  width: 24,
                                  height: 24,
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
                                          text: language["Language"] ??
                                              "Language",
                                          style: FontConstants.caption2,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 5,
                                  top: 16,
                                  bottom: 16,
                                ),
                                child: Text(
                                  lang == "eng" ? "English" : "မြန်မာ",
                                  style: FontConstants.caption1,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                        ),
                        child: const Divider(
                          height: 0,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          showExitDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              language["Sign Out"] ?? "Sign Out",
                              style: FontConstants.caption2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
