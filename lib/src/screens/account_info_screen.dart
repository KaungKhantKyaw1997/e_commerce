import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/seller_registration_fee_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:e_commerce/src/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final crashlytic = new CrashlyticsService();
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();
  final sellerRegistrationFeeService = SellerRegistrationFeeService();
  ScrollController _scrollController = ScrollController();
  FocusNode _bankCodeFocusNode = FocusNode();
  FocusNode _bankAccountFocusNode = FocusNode();
  FocusNode _walletTypeFocusNode = FocusNode();
  FocusNode _walletAccountFocusNode = FocusNode();
  TextEditingController bankCode = TextEditingController(text: '');
  TextEditingController bankAccount = TextEditingController(text: '');
  TextEditingController walletType = TextEditingController(text: '');
  TextEditingController walletAccount = TextEditingController(text: '');

  final ImagePicker _picker = ImagePicker();
  XFile? bankAccountPickedFile;
  String bankAccountImage = '';
  XFile? monthlyTransactionPickedFile;
  String monthlyTransactionImage = '';
  List sellerRegistrationFees = [];
  List<String> sellerRegistrationFeesDesc = [];
  int sellerRegistrationFeeId = 0;
  String sellerRegistrationFeeDesc = '';
  var data = {};
  var sellerInformation = {};

  @override
  void initState() {
    super.initState();
    getSellerRegistrationFees();
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

  getSellerRegistrationFees() async {
    try {
      final response = await sellerRegistrationFeeService
          .getSellerRegistrationFeesData(perPage: 999999);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          sellerRegistrationFees = response["data"];

          for (var data in response["data"]) {
            if (data["description"] != null) {
              sellerRegistrationFeesDesc.add(data["description"]);
            }
          }
          sellerRegistrationFeeId = sellerRegistrationFees[0]["fee_id"];
          sellerRegistrationFeeDesc = sellerRegistrationFees[0]["description"];
          setState(() {});
        }
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

  Future<void> _pickImage(source, type) async {
    try {
      XFile? file = await _picker.pickImage(
        source: source,
      );
      if (type == "bankaccount") {
        bankAccountPickedFile = file;
      } else if (type == "monthlytransaction") {
        monthlyTransactionPickedFile = file;
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
        if (type == "bankaccount") {
          bankAccountImage = res["url"];
        } else if (type == "monthlytransaction") {
          monthlyTransactionImage = res["url"];
        }
      }
    } catch (error) {
      print('Error uploading file: $error');
    }
  }

  register() async {
    try {
      final body = {
        "username": data["email"],
        "email": data["email"],
        "password": data["password"],
        "name": data["name"],
        "phone": '959${data["phone"]}',
        "profile_image": data["profile_image"],
        "role": data["role"],
        "method": data["method"],
        "token": data["token"],
        "seller_information": {
          "company_name": "",
          "professional_title": "",
          "location": "",
          "offline_trader": false,
          "facebook_profile_image": sellerInformation["facebook_profile_image"],
          "shop_or_page_name": sellerInformation["shop_or_page_name"],
          "facebook_page_image": sellerInformation["facebook_page_image"],
          "bussiness_phone": '959${sellerInformation["bussiness_phone"]}',
          "address": sellerInformation["address"],
          "nrc": sellerInformation["nrc"],
          "nrc_front_image": sellerInformation["nrc_front_image"],
          "nrc_back_image": sellerInformation["nrc_back_image"],
          "bank_code": bankCode.text,
          "bank_account": bankAccount.text,
          "bank_account_image": bankAccountImage,
          "wallet_type": walletType.text,
          "wallet_account": walletAccount.text,
          "fee_id": sellerRegistrationFeeId,
          "monthly_transaction_screenshot": monthlyTransactionImage,
        }
      };

      final response = await authService.registerData(body);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
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
        _bankCodeFocusNode.unfocus();
        _bankAccountFocusNode.unfocus();
        _walletTypeFocusNode.unfocus();
        _walletAccountFocusNode.unfocus();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 24,
                              left: 16,
                              right: 4,
                              bottom: 4,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                language["Bank"] ?? "Bank",
                                style: FontConstants.caption1,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 4,
                              bottom: 16,
                            ),
                            child: TextFormField(
                              controller: bankCode,
                              focusNode: _bankCodeFocusNode,
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
                                  return language["Enter Bank"] ?? "Enter Bank";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 24,
                              left: 4,
                              right: 16,
                              bottom: 4,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                language["Bank Account Number"] ??
                                    "Bank Account Number",
                                style: FontConstants.caption1,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 4,
                              right: 16,
                              bottom: 16,
                            ),
                            child: TextFormField(
                              controller: bankAccount,
                              focusNode: _bankAccountFocusNode,
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
                                          "Enter Bank Account Number"] ??
                                      "Enter Bank Account Number";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    _pickImage(ImageSource.gallery, "bankaccount");
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
                    child: bankAccountPickedFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(bankAccountPickedFile!.path),
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
                                  "assets/icons/bank.svg",
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
                                  language["Upload Bank Account Photo"] ??
                                      "Upload Bank Account Photo",
                                  style: FontConstants.subheadline2,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 4,
                              bottom: 4,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                language["Wallet"] ?? "Wallet",
                                style: FontConstants.caption1,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 4,
                              bottom: 16,
                            ),
                            child: TextFormField(
                              controller: walletType,
                              focusNode: _walletTypeFocusNode,
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
                                  return language["Enter Wallet"] ??
                                      "Enter Wallet";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                              right: 16,
                              bottom: 4,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                language["Wallet Account Number"] ??
                                    "Wallet Account Number",
                                style: FontConstants.caption1,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 4,
                              right: 16,
                              bottom: 16,
                            ),
                            child: TextFormField(
                              controller: walletAccount,
                              focusNode: _walletAccountFocusNode,
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
                                          "Enter Wallet Account Number"] ??
                                      "Enter Wallet Account Number";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
                      language["Fee"] ?? "Fee",
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
                  child: CustomDropDown(
                    value: sellerRegistrationFeeDesc,
                    fillColor: ColorConstants.fillColor,
                    onChanged: (newValue) {
                      setState(() {
                        sellerRegistrationFeeDesc =
                            newValue ?? sellerRegistrationFeesDesc[0];
                      });
                      for (var data in sellerRegistrationFees) {
                        if (data["description"] == sellerRegistrationFeeDesc) {
                          sellerRegistrationFeeId = data["fee_id"];
                        }
                      }
                    },
                    items: sellerRegistrationFeesDesc,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _pickImage(ImageSource.gallery, "monthlytransaction");
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
                    child: monthlyTransactionPickedFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(monthlyTransactionPickedFile!.path),
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
                                  "assets/icons/percent.svg",
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
                                  language[
                                          "Upload Monthly Fees Transaction Screenshot"] ??
                                      "Upload Monthly Fees Transaction Screenshot",
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
                if (bankAccountPickedFile == null) {
                  ToastUtil.showToast(
                      0,
                      language["Choose Bank Account Photo"] ??
                          "Choose Bank Account Photo");
                  return;
                }
                if (monthlyTransactionPickedFile == null) {
                  ToastUtil.showToast(
                      0,
                      language["Choose Monthly Fees Transaction Screenshot"] ??
                          "Choose Monthly Fees Transaction Screenshot");
                  return;
                }
                showLoadingDialog(context);
                await uploadFile(bankAccountPickedFile, 'bankaccount');
                await uploadFile(
                    monthlyTransactionPickedFile, 'monthlytransaction');
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
