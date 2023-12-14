import 'dart:convert';
import 'dart:io';

import 'package:animated_button_bar/animated_button_bar.dart';
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
  AnimatedButtonController _buttonBarController = AnimatedButtonController();
  FocusNode _nrcFocusNode = FocusNode();
  TextEditingController nrc = TextEditingController(text: '');

  final ImagePicker _picker = ImagePicker();
  XFile? nrcFrontPickedFile;
  String nrcFrontImage = '';
  XFile? nrcBackPickedFile;
  String nrcBackImage = '';
  XFile? passportPickedFile;
  String passportImage = '';
  XFile? drivingLicencePickedFile;
  String drivingLicenceImage = '';
  XFile? signaturePickedFile;
  String signatureImage = '';
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
      } else if (type == "passport") {
        passportPickedFile = file;
      } else if (type == "drivinglicence") {
        drivingLicencePickedFile = file;
      } else if (type == "signature") {
        signaturePickedFile = file;
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile(pickedFile, type) async {
    try {
      var response = await AuthService.uploadFile(File(pickedFile!.path));
      var res = jsonDecode(response.body);
      if (res["code"] == 200) {
        if (type == "frontnrc") {
          nrcFrontImage = res["url"];
        } else if (type == "backnrc") {
          nrcBackImage = res["url"];
        } else if (type == "passport") {
          passportImage = res["url"];
        } else if (type == "drivinglicence") {
          drivingLicenceImage = res["url"];
        } else if (type == "signature") {
          signatureImage = res["url"];
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
                AnimatedButtonBar(
                  controller: _buttonBarController,
                  radius: 20,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
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
                        nrc.text = "";
                        nrcFrontPickedFile = null;
                        nrcFrontImage = '';
                        nrcBackPickedFile = null;
                        nrcBackImage = '';
                        passportPickedFile = null;
                        passportImage = '';
                        drivingLicencePickedFile = null;
                        drivingLicenceImage = '';

                        setState(() {
                          _buttonBarController.setIndex(0);
                        });
                      },
                      child: Text(
                        language["NRC"] ?? "NRC",
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
                        nrc.text = "";
                        nrcFrontPickedFile = null;
                        nrcFrontImage = '';
                        nrcBackPickedFile = null;
                        nrcBackImage = '';
                        passportPickedFile = null;
                        passportImage = '';
                        drivingLicencePickedFile = null;
                        drivingLicenceImage = '';

                        setState(() {
                          _buttonBarController.setIndex(1);
                        });
                      },
                      child: Text(
                        language["Passport"] ?? "Passport",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _buttonBarController.index == 1
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    ButtonBarEntry(
                      onTap: () {
                        nrc.text = "";
                        nrcFrontPickedFile = null;
                        nrcFrontImage = '';
                        nrcBackPickedFile = null;
                        nrcBackImage = '';
                        passportPickedFile = null;
                        passportImage = '';
                        drivingLicencePickedFile = null;
                        drivingLicenceImage = '';

                        setState(() {
                          _buttonBarController.setIndex(2);
                        });
                      },
                      child: Text(
                        language["Driving Licence"] ?? "Driving Licence",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _buttonBarController.index == 2
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_buttonBarController.index == 0)
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
                if (_buttonBarController.index == 0)
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
                      textInputAction: TextInputAction.done,
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
                if (_buttonBarController.index == 0)
                  GestureDetector(
                    onTap: () {
                      _pickImage(ImageSource.gallery, "frontnrc");
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
                                    "assets/icons/front_id.svg",
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      language["Upload Front NRC"] ??
                                          "Upload Front NRC",
                                      textAlign: TextAlign.center,
                                      style: FontConstants.subheadline2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                if (_buttonBarController.index == 0)
                  GestureDetector(
                    onTap: () {
                      _pickImage(ImageSource.gallery, "backnrc");
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
                                    "assets/icons/back_id.svg",
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      language["Upload Back NRC"] ??
                                          "Upload Back NRC",
                                      textAlign: TextAlign.center,
                                      style: FontConstants.subheadline2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                if (_buttonBarController.index == 1)
                  GestureDetector(
                    onTap: () {
                      _pickImage(ImageSource.gallery, "passport");
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 24,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.fillColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: double.infinity,
                      child: passportPickedFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(passportPickedFile!.path),
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
                                    "assets/icons/front_id.svg",
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      language["Upload Passport"] ??
                                          "Upload Passport",
                                      textAlign: TextAlign.center,
                                      style: FontConstants.subheadline2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                if (_buttonBarController.index == 2)
                  GestureDetector(
                    onTap: () {
                      _pickImage(ImageSource.gallery, "drivinglicence");
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 24,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.fillColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: double.infinity,
                      child: drivingLicencePickedFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(drivingLicencePickedFile!.path),
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
                                    "assets/icons/front_id.svg",
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      language["Upload Driving Licence"] ??
                                          "Upload Driving Licence",
                                      textAlign: TextAlign.center,
                                      style: FontConstants.subheadline2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    _pickImage(ImageSource.gallery, "signature");
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 24,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConstants.fillColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: double.infinity,
                    child: signaturePickedFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(signaturePickedFile!.path),
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
                                  "assets/icons/signature.svg",
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    language["Upload Signature"] ??
                                        "Upload Signature",
                                    textAlign: TextAlign.center,
                                    style: FontConstants.subheadline2,
                                  ),
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
                if (_buttonBarController.index == 0 &&
                    nrcFrontPickedFile == null) {
                  ToastUtil.showToast(
                      0, language["Choose Front NRC"] ?? "Choose Front NRC");
                  return;
                }
                if (_buttonBarController.index == 0 &&
                    nrcBackPickedFile == null) {
                  ToastUtil.showToast(
                      0, language["Choose Back NRC"] ?? "Choose Back NRC");
                  return;
                }
                if (_buttonBarController.index == 1 &&
                    passportPickedFile == null) {
                  ToastUtil.showToast(
                      0, language["Choose Passport"] ?? "Choose Passport");
                  return;
                }
                if (_buttonBarController.index == 2 &&
                    drivingLicencePickedFile == null) {
                  ToastUtil.showToast(
                      0,
                      language["Choose Driving Licence"] ??
                          "Choose Driving Licence");
                  return;
                }
                if (signaturePickedFile == null) {
                  ToastUtil.showToast(
                      0, language["Choose Signature"] ?? "Choose Signature");
                  return;
                }
                showLoadingDialog(context);
                if (_buttonBarController.index == 0) {
                  await uploadFile(nrcFrontPickedFile, 'frontnrc');
                  await uploadFile(nrcBackPickedFile, 'backnrc');
                } else if (_buttonBarController.index == 1) {
                  await uploadFile(passportPickedFile, 'passport');
                } else if (_buttonBarController.index == 2) {
                  await uploadFile(drivingLicencePickedFile, 'drivinglicence');
                }
                await uploadFile(signaturePickedFile, 'signature');

                Navigator.pop(context);
                sellerInformation["nrc"] =
                    _buttonBarController.index == 0 ? nrc.text : "";
                sellerInformation["nrc_front_image"] =
                    _buttonBarController.index == 0 ? nrcFrontImage : "";
                sellerInformation["nrc_back_image"] =
                    _buttonBarController.index == 0 ? nrcBackImage : "";
                sellerInformation["passport_image"] =
                    _buttonBarController.index == 1 ? passportImage : "";
                sellerInformation["driving_licence_image"] =
                    _buttonBarController.index == 2 ? drivingLicenceImage : "";
                sellerInformation["signature_image"] = signatureImage;

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
