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
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:store_redirect/store_redirect.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final storage = FlutterSecureStorage();
  String lang = '';
  String profileImage = '';
  String profileName = '';
  String version = '';
  String packageName = '';
  String role = '';

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
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    packageName = packageInfo.packageName;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lang = prefs.getString('language') ?? "eng";
      profileImage = prefs.getString('profile_image') ?? "";
      profileName = prefs.getString('name') ?? "";
      role = prefs.getString('role') ?? "";
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
            language["Log Out"] ?? "Log Out",
            style: FontConstants.body1,
          ),
          content: Text(
            language["Are you sure you want to log out?"] ??
                "Are you sure you want to log out?",
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
                authService.logout(context);
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
        elevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            language["Settings"] ?? "Settings",
            style: FontConstants.title2,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
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
                          if (role.isNotEmpty) {
                            Navigator.pushNamed(
                              context,
                              Routes.profile,
                              arguments: {
                                'from': 'setting',
                              },
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              role.isNotEmpty
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                        right: 16,
                                        top: 16,
                                        bottom: 16,
                                      ),
                                      width: 40,
                                      height: 40,
                                      decoration: profileImage.isEmpty
                                          ? BoxDecoration(
                                              color: ColorConstants.fillcolor,
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
                                                    '${ApiConstants.baseUrl}${profileImage.toString()}'),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.only(
                                        right: 16,
                                        top: 16,
                                        bottom: 16,
                                      ),
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: ColorConstants.fillcolor,
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/profile.png"),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                              profileName.isNotEmpty
                                  ? Expanded(
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
                                                style:
                                                    FontConstants.subheadline1,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 0.5,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, Routes.login);
                                        },
                                        child: Text(
                                          language["Register or Log In"] ??
                                              "Register or Log In",
                                          style: FontConstants.button2,
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
                            language["General"] ?? "General",
                            style: FontConstants.smallText1,
                          ),
                        ),
                      ),
                      role == 'admin'
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.users_setup,
                                );
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
                                        "assets/icons/user.svg",
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
                                                text:
                                                    language["User"] ?? "User",
                                                style: FontConstants.caption2,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      role == 'admin'
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.shops_setup,
                                );
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
                                        "assets/icons/shop.svg",
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
                                                text:
                                                    language["Shop"] ?? "Shop",
                                                style: FontConstants.caption2,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      role == 'admin'
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.categories_setup,
                                );
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
                                        "assets/icons/category.svg",
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
                                                text: language["Category"] ??
                                                    "Category",
                                                style: FontConstants.caption2,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      role == 'admin'
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.brands_setup,
                                );
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
                                        "assets/icons/brand.svg",
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
                                                text: language["Brand"] ??
                                                    "Brand",
                                                style: FontConstants.caption2,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      role == 'admin'
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.products_setup,
                                );
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
                                        "assets/icons/product.svg",
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
                                                text: language["Product"] ??
                                                    "Product",
                                                style: FontConstants.caption2,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.language,
                          );
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
                              ),
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
                      role.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  language["Security"] ?? "Security",
                                  style: FontConstants.smallText1,
                                ),
                              ),
                            )
                          : Container(),
                      role.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.change_password,
                                );
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
                                        "assets/icons/lock.svg",
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
                                                text: language[
                                                        "Change Password"] ??
                                                    "Change Password",
                                                style: FontConstants.caption2,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
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
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            language["Help & Support"] ?? "Help & Support",
                            style: FontConstants.smallText1,
                          ),
                        ),
                      ),
                      role.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.termsandconditions,
                                );
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
                                        "assets/icons/shield.svg",
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
                                                text: language[
                                                        "Terms & Conditions"] ??
                                                    "Terms & Conditions",
                                                style: FontConstants.caption2,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      GestureDetector(
                        onTap: () {
                          StoreRedirect.redirect(
                            androidAppId: packageName,
                            iOSAppId: "6469529196",
                          );
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
                                  "assets/icons/version.svg",
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
                                          text: language["App Version"] ??
                                              "App Version",
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
                                  'v$version',
                                  style: FontConstants.caption1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                role.isNotEmpty
                    ? Container(
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
                            showExitDialog();
                          },
                          child: Text(
                            language["Log Out"] ?? "Log Out",
                            style: FontConstants.button1,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
