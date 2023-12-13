import 'dart:convert';
import 'dart:io';

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

class FacebookInfoScreen extends StatefulWidget {
  const FacebookInfoScreen({super.key});

  @override
  State<FacebookInfoScreen> createState() => _FacebookInfoScreenState();
}

class _FacebookInfoScreenState extends State<FacebookInfoScreen> {
  final crashlytic = new CrashlyticsService();
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();
  ScrollController _scrollController = ScrollController();
  FocusNode _shopOrPageNameFocusNode = FocusNode();
  FocusNode _businessPhoneFocusNode = FocusNode();
  FocusNode _addressFocusNode = FocusNode();
  TextEditingController shopOrPageName = TextEditingController(text: '');
  TextEditingController businessPhone = TextEditingController(text: '');
  TextEditingController address = TextEditingController(text: '');

  final ImagePicker _picker = ImagePicker();
  XFile? facebookProfilePickedFile;
  String facebookProfileImage = '';
  XFile? facebookPagePickedFile;
  String facebookPageImage = '';

  var data = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        data = arguments;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(source, type) async {
    try {
      XFile? file = await _picker.pickImage(
        source: source,
      );
      if (type == "facebookprofile") {
        facebookProfilePickedFile = file;
      } else if (type == "facebookpage") {
        facebookPagePickedFile = file;
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile(pickedFile, type) async {
    try {
      var response = await AuthService.uploadFile(File(pickedFile!.path),
          resolution: type == "facebookprofile" ? "100x100" : "");
      var res = jsonDecode(response.body);
      if (res["code"] == 200) {
        if (type == "facebookprofile") {
          facebookProfileImage = res["url"];
        } else if (type == "facebookpage") {
          facebookPageImage = res["url"];
        }
      }
    } catch (error) {
      print('Error uploading file: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _shopOrPageNameFocusNode.unfocus();
        _businessPhoneFocusNode.unfocus();
        _addressFocusNode.unfocus();
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
                          _pickImage(ImageSource.gallery, "facebookprofile");
                        },
                        child: facebookProfilePickedFile == null
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
                                  File(facebookProfilePickedFile!.path),
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
                          _pickImage(ImageSource.gallery, "facebookprofile");
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
                      language["Your Shop Name or Facebook Page Name"] ??
                          "Your Shop Name or Facebook Page Name",
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
                    controller: shopOrPageName,
                    focusNode: _shopOrPageNameFocusNode,
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
                        return language[
                                "Enter Your Shop Name or Facebook Page Name"] ??
                            "Enter Your Shop Name or Facebook Page Name";
                      }
                      return null;
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _pickImage(ImageSource.gallery, "facebookpage");
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConstants.fillColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: double.infinity,
                    child: facebookPagePickedFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(facebookPagePickedFile!.path),
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 48,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/facebook_bw.svg",
                                  width: 48,
                                  height: 48,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.grey,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  language["Upload Facebook Page Screenshot"] ??
                                      "Upload Facebook Page Screenshot",
                                  style: FontConstants.subheadline2,
                                ),
                              ],
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
                      language["Business Phone Number"] ??
                          "Business Phone Number",
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
                    controller: businessPhone,
                    focusNode: _businessPhoneFocusNode,
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
                        return language["Enter Business Phone Number"] ??
                            "Enter Business Phone Number";
                      }
                      final RegExp phoneRegExp =
                          RegExp(r"^[+]{0,1}[0-9]{7,9}$");

                      if (!phoneRegExp.hasMatch(value)) {
                        return language["Invalid Business Phone Number"] ??
                            "Invalid Business Phone Number";
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
                      language["Address"] ?? "Address",
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
                    controller: address,
                    focusNode: _addressFocusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    style: FontConstants.body1,
                    cursorColor: Colors.black,
                    maxLines: 2,
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
                        return language["Enter Address"] ?? "Enter Address";
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
                if (facebookProfilePickedFile == null) {
                  ToastUtil.showToast(
                      0,
                      language["Choose Facebook Profile"] ??
                          "Choose Facebook Profile");
                  return;
                }
                if (facebookPagePickedFile == null) {
                  ToastUtil.showToast(
                      0,
                      language["Choose Facebook Page Screenshot"] ??
                          "Choose Facebook Page Screenshot");
                  return;
                }
                showLoadingDialog(context);
                await uploadFile(facebookProfilePickedFile, 'facebookprofile');
                await uploadFile(facebookPagePickedFile, 'facebookpage');
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.id_info,
                  arguments: {
                    "data": data,
                    "seller_information": {
                      "facebook_profile_image": facebookProfileImage,
                      "facebook_page_image": facebookPageImage,
                      "shop_or_page_name": shopOrPageName.text,
                      "bussiness_phone": businessPhone.text,
                      "address": address.text,
                    }
                  },
                  (route) => true,
                );
              }
            },
            child: Text(
              language["Next"] ?? "Next",
              style: FontConstants.button1,
            ),
          ),
        ),
      ),
    );
  }
}
