import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/user_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class SellerRegisterScreen extends StatefulWidget {
  const SellerRegisterScreen({super.key});

  @override
  State<SellerRegisterScreen> createState() => _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends State<SellerRegisterScreen> {
  final crashlytic = new CrashlyticsService();
  final authService = AuthService();
  final userService = UserService();
  ScrollController _scrollController = ScrollController();
  TextEditingController email = TextEditingController(text: '');
  TextEditingController password = TextEditingController(text: '');
  TextEditingController confirmpassword = TextEditingController(text: '');
  TextEditingController name = TextEditingController(text: '');
  TextEditingController phone = TextEditingController(text: '');
  TextEditingController companyName = TextEditingController(text: '');
  TextEditingController professionalTitle = TextEditingController(text: '');
  TextEditingController location = TextEditingController(text: '');
  String role = '';
  String status = '';
  bool offlineTrader = false;
  bool modifyOrderStatus = false;
  bool canViewAddress = false;
  bool canViewPhone = false;

  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;
  String profileImage = '';

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getUser() async {
    try {
      final response = await userService.getUserData(0);
      if (response!["code"] == 200) {
        setState(() {
          password.text = response["data"]["password"] ?? "";
          confirmpassword.text = response["data"]["password"] ?? "";
          confirmpassword.text = response["data"]["password"] ?? "";
          role = response["data"]["role"] ?? "user";
          name.text = response["data"]["name"] ?? "";
          email.text = response["data"]["email"] ?? "";
          phone.text = response["data"]["phone"] ?? "";
          phone.text = phone.text.replaceAll("959", "");
          status = response["data"]["account_status"] ?? "pending";
          modifyOrderStatus =
              response["data"]["can_modify_order_status"] ?? false;
          canViewAddress = response["data"]["can_view_address"] ?? false;
          canViewPhone = response["data"]["can_view_phone"] ?? false;
        });
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          language["Seller Register"] ?? "Seller Register",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
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
                    color: ColorConstants.fillColor,
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _pickImage(ImageSource.camera);
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
                      _pickImage(ImageSource.camera);
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
                readOnly: true,
                style: FontConstants.body2,
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
                ),
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
                readOnly: true,
                style: FontConstants.body2,
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
                ),
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
                readOnly: true,
                style: FontConstants.body2,
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
                ),
              ),
            ),
          ],
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
            if (pickedFile == null) {
              ToastUtil.showToast(0, language["Take Photo"] ?? "Take Photo");
              return;
            }
            showLoadingDialog(context);
            await uploadFile();
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.facebook_info,
              arguments: {
                "type": "user",
                "email": email.text,
                "password": password.text,
                "role": role,
                "name": name.text,
                "phone": phone.text,
                "profile_image": profileImage,
                "account_status": status,
                "can_modify_order_status": modifyOrderStatus,
                "can_view_address": canViewAddress,
                "can_view_phone": canViewPhone,
                "seller_information": {
                  "company_name": companyName.text,
                  "professional_title": professionalTitle.text,
                  "location": location.text,
                  "offline_trader": offlineTrader,
                },
              },
              (route) => true,
            );
          },
          child: Text(
            language["Next"] ?? "Next",
            style: FontConstants.button1,
          ),
        ),
      ),
    );
  }
}
