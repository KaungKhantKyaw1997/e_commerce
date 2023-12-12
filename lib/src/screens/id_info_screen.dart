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

class IDInfoScreen extends StatefulWidget {
  const IDInfoScreen({super.key});

  @override
  State<IDInfoScreen> createState() => _IDInfoScreenState();
}

class _IDInfoScreenState extends State<IDInfoScreen> {
  final crashlytic = new CrashlyticsService();
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();
  ScrollController _scrollController = ScrollController();
  FocusNode _nrcFocusNode = FocusNode();
  TextEditingController nrc = TextEditingController(text: '');

  final ImagePicker _picker = ImagePicker();
  XFile? nrcFrontPickedFile;
  String nrcFrontImage = '';
  XFile? nrcBackPickedFile;
  String nrcBackImage = '';
  var data = {};
  var sellerInformation = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        data = arguments["data"];
        sellerInformation = arguments["seller_information"];
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
      if (type == "frontnrc") {
        nrcFrontPickedFile = file;
      } else if (type == "backnrc") {
        nrcBackPickedFile = file;
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile(pickedFile, type) async {
    try {
      var response = await AuthService.uploadFile(File(pickedFile!.path),
          resolution: "100x100");
      var res = jsonDecode(response.body);
      if (res["code"] == 200) {
        if (type == "frontnrc") {
          nrcFrontImage = res["url"];
        } else if (type == "backnrc") {
          nrcBackImage = res["url"];
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
        _nrcFocusNode.unfocus();
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
                    top: 24,
                    left: 16,
                    right: 16,
                    bottom: 4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      language["NRC"] ?? "NRC",
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
                    controller: nrc,
                    focusNode: _nrcFocusNode,
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
                        return language["Enter NRC"] ?? "Enter NRC";
                      }
                      return null;
                    },
                  ),
                ),
                Container(
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
                  child: GestureDetector(
                    onTap: () {
                      _pickImage(ImageSource.gallery, "frontnrc");
                    },
                    child: nrcFrontPickedFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(nrcFrontPickedFile!.path),
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
                                  "assets/icons/front_nrc.svg",
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
                                  language["Upload Front NRC"] ??
                                      "Upload Front NRC",
                                  style: FontConstants.subheadline2,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                Container(
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
                  child: GestureDetector(
                    onTap: () {
                      _pickImage(ImageSource.gallery, "backnrc");
                    },
                    child: nrcBackPickedFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(nrcBackPickedFile!.path),
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
                                  "assets/icons/back_nrc.svg",
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
                                  language["Upload Back NRC"] ??
                                      "Upload Back NRC",
                                  style: FontConstants.subheadline2,
                                ),
                              ],
                            ),
                          ),
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
                if (nrcFrontPickedFile == null) {
                  ToastUtil.showToast(
                      0,
                      language["Choose Front NRC Image"] ??
                          "Choose Front NRC Image");
                  return;
                }
                if (nrcBackPickedFile == null) {
                  ToastUtil.showToast(
                      0,
                      language["Choose Back NRC Image"] ??
                          "Choose Back NRC Image");
                  return;
                }
                showLoadingDialog(context);
                await uploadFile(nrcFrontPickedFile, 'frontnrc');
                await uploadFile(nrcBackPickedFile, 'backnrc');
                Navigator.pop(context);
                sellerInformation["nrc"] = nrc.text;
                sellerInformation["nrc_front_image"] = nrcFrontImage;
                sellerInformation["nrc_back_image"] = nrcBackImage;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.account_info,
                  arguments: {
                    "data": data,
                    "seller_information": sellerInformation
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
