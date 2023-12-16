import 'dart:io';

import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/seller_registration_fee_service.dart';
import 'package:e_commerce/src/services/user_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class SellerRegisterApprovalScreen extends StatefulWidget {
  const SellerRegisterApprovalScreen({super.key});

  @override
  State<SellerRegisterApprovalScreen> createState() =>
      _SellerRegisterApprovalScreenState();
}

class _SellerRegisterApprovalScreenState
    extends State<SellerRegisterApprovalScreen> {
  final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  final userService = UserService();
  final sellerRegistrationFeeService = SellerRegistrationFeeService();
  NumberFormat formatter = NumberFormat('###,###.00', 'en_US');
  AnimatedButtonController _buttonBarController = AnimatedButtonController();
  TextEditingController email = TextEditingController(text: '');
  TextEditingController password = TextEditingController(text: '');
  TextEditingController confirmpassword = TextEditingController(text: '');
  TextEditingController name = TextEditingController(text: '');
  TextEditingController phone = TextEditingController(text: '');
  TextEditingController companyName = TextEditingController(text: '');
  TextEditingController professionalTitle = TextEditingController(text: '');
  TextEditingController location = TextEditingController(text: '');
  TextEditingController shopOrPageName = TextEditingController(text: '');
  TextEditingController businessPhone = TextEditingController(text: '');
  TextEditingController address = TextEditingController(text: '');
  TextEditingController nrc = TextEditingController(text: '');
  TextEditingController bankCode = TextEditingController(text: '');
  TextEditingController bankAccount = TextEditingController(text: '');
  TextEditingController walletType = TextEditingController(text: '');
  TextEditingController walletAccount = TextEditingController(text: '');
  TextEditingController role = TextEditingController(text: '');
  TextEditingController status = TextEditingController(text: '');
  TextEditingController sellerRegistrationFeeDesc =
      TextEditingController(text: '');
  bool offlineTrader = false;
  bool modifyOrderStatus = false;
  bool canViewAddress = false;
  bool canViewPhone = false;

  String profileImage = '';
  String facebookProfileImage = '';
  String facebookPageImage = '';
  String nrcFrontImage = '';
  String nrcBackImage = '';
  String passportImage = '';
  String drivingLicenceImage = '';
  String signatureImage = '';
  String bankAccountImage = '';
  String monthlyTransactionImage = '';
  List sellerRegistrationFees = [];
  int sellerRegistrationFeeId = 0;
  double amount = 0.0;

  int id = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await getSellerRegistrationFees();
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        id = arguments["id"] ?? 0;
        if (id != 0) {
          getUser();
        }
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

  getUser() async {
    try {
      final response = await userService.getUserData(id);
      if (response!["code"] == 200) {
        setState(() {
          password.text = response["data"]["password"] ?? "";
          confirmpassword.text = response["data"]["password"] ?? "";
          role.text = response["data"]["role"] ?? "user";
          name.text = response["data"]["name"] ?? "";
          email.text = response["data"]["email"] ?? "";
          phone.text = response["data"]["phone"] ?? "";
          phone.text = phone.text.replaceAll("959", "");
          profileImage = response["data"]["profile_image"] ?? "";
          companyName.text =
              response["data"]["seller_information"]["company_name"] ?? "";
          professionalTitle.text = response["data"]["seller_information"]
                  ["professional_title"] ??
              "";
          location.text =
              response["data"]["seller_information"]["location"] ?? "";
          offlineTrader =
              response["data"]["seller_information"]["offline_trader"] ?? false;
          status.text = response["data"]["account_status"] ?? "pending";
          modifyOrderStatus =
              response["data"]["can_modify_order_status"] ?? false;
          canViewAddress = response["data"]["can_view_address"] ?? false;
          canViewPhone = response["data"]["can_view_phone"] ?? false;

          facebookProfileImage = response["data"]["seller_information"]
                  ["facebook_profile_image"] ??
              "";
          facebookPageImage = response["data"]["seller_information"]
                  ["facebook_page_image"] ??
              "";
          shopOrPageName.text =
              response["data"]["seller_information"]["shop_or_page_name"] ?? "";
          businessPhone.text =
              response["data"]["seller_information"]["bussiness_phone"] ?? "";
          businessPhone.text = businessPhone.text.replaceAll("959", "");
          address.text =
              response["data"]["seller_information"]["address"] ?? "";

          nrc.text = response["data"]["seller_information"]["nrc"] ?? "";
          nrcFrontImage =
              response["data"]["seller_information"]["nrc_front_image"] ?? "";
          nrcBackImage =
              response["data"]["seller_information"]["nrc_back_image"] ?? "";
          passportImage =
              response["data"]["seller_information"]["passport_image"] ?? "";
          drivingLicenceImage = response["data"]["seller_information"]
                  ["driving_licence_image"] ??
              "";
          signatureImage =
              response["data"]["seller_information"]["signature_image"] ?? "";

          bankCode.text =
              response["data"]["seller_information"]["bank_code"] ?? "";
          bankAccount.text =
              response["data"]["seller_information"]["bank_account"] ?? "";
          bankAccountImage = response["data"]["seller_information"]
                  ["bank_account_image"] ??
              "";
          walletType.text =
              response["data"]["seller_information"]["wallet_type"] ?? "";
          walletAccount.text =
              response["data"]["seller_information"]["wallet_account"] ?? "";
          walletAccount.text = walletAccount.text.replaceAll("959", "");
          sellerRegistrationFeeId =
              response["data"]["seller_information"]["fee_id"] ?? 0;
          for (var data in sellerRegistrationFees) {
            if (data["fee_id"] == sellerRegistrationFeeId) {
              sellerRegistrationFeeDesc.text = data["description"];
              amount = data["amount"];
              break;
            }
          }
          monthlyTransactionImage = response["data"]["seller_information"]
                  ["monthly_transaction_screenshot"] ??
              "";
          int index = nrc.text.isNotEmpty
              ? 0
              : passportImage.isNotEmpty
                  ? 1
                  : 2;
          _buttonBarController.setIndex(index);
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

  updateUser() async {
    try {
      final body = {
        "email": email.text,
        "password": password.text,
        "role": "agent",
        "name": name.text,
        "phone": '959${phone.text}',
        "profile_image": profileImage,
        "account_status": "active",
        "can_modify_order_status": modifyOrderStatus,
        "can_view_address": canViewAddress,
        "can_view_phone": canViewPhone,
        "request_to_agent": false,
        "seller_information": {
          "company_name": companyName.text,
          "professional_title": professionalTitle.text,
          "location": location.text,
          "offline_trader": offlineTrader,
          "facebook_profile_image": facebookProfileImage,
          "shop_or_page_name": shopOrPageName.text,
          "facebook_page_image": facebookPageImage,
          "bussiness_phone": '959${businessPhone.text}',
          "address": address.text,
          "nrc": nrc.text,
          "nrc_front_image": nrcFrontImage,
          "nrc_back_image": nrcBackImage,
          "passport_image": passportImage,
          "driving_licence_image": drivingLicenceImage,
          "signature_image": signatureImage,
          "bank_code": bankCode.text,
          "bank_account": bankAccount.text,
          "bank_account_image": bankAccountImage,
          "wallet_type": walletType.text,
          "wallet_account": '959${walletAccount.text}',
          "fee_id": sellerRegistrationFeeId,
          "monthly_transaction_screenshot": monthlyTransactionImage,
        }
      };

      final response = await userService.updateUserData(body, id);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.seller_registers_approval,
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
                  child: profileImage.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.image_preview,
                              arguments: {
                                "image_url":
                                    '${profileImage.startsWith("/images") ? ApiConstants.baseUrl : ""}$profileImage'
                              },
                            );
                          },
                          child: ClipOval(
                            child: Image.network(
                              '${profileImage.startsWith("/images") ? ApiConstants.baseUrl : ""}$profileImage',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : ClipOval(
                          child: Image.asset(
                            'assets/images/profile.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
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
                bottom: 16,
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
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 4,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  language["Role"] ?? "Role",
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
                controller: role,
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
                  language["Account Status"] ?? "Account Status",
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
                controller: status,
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
                  child: facebookProfileImage.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.image_preview,
                              arguments: {
                                "image_url":
                                    '${ApiConstants.baseUrl}${facebookProfileImage}'
                              },
                            );
                          },
                          child: ClipOval(
                            child: Image.network(
                              '${ApiConstants.baseUrl}$facebookProfileImage',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : ClipOval(
                          child: Image.asset(
                            'assets/images/profile.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
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
                  language["Shop Name or Facebook Page Name"] ??
                      "Shop Name or Facebook Page Name",
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
              child: facebookPageImage.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.image_preview,
                          arguments: {
                            "image_url":
                                '${ApiConstants.baseUrl}${facebookPageImage}'
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          '${ApiConstants.baseUrl}$facebookPageImage',
                          height: 180,
                          fit: BoxFit.cover,
                        ),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: Text(
                              language["Upload Facebook Page Screenshot"] ??
                                  "Upload Facebook Page Screenshot",
                              textAlign: TextAlign.center,
                              style: FontConstants.subheadline2,
                            ),
                          ),
                        ],
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
                  language["Business Phone Number"] ?? "Business Phone Number",
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
                bottom: 16,
              ),
              child: TextFormField(
                controller: address,
                readOnly: true,
                style: FontConstants.body2,
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
                ),
              ),
            ),
            if (_buttonBarController.index == 0)
              Padding(
                padding: const EdgeInsets.only(
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
            if (_buttonBarController.index == 0)
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
                child: nrcFrontImage.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.image_preview,
                            arguments: {
                              "image_url":
                                  '${ApiConstants.baseUrl}${nrcFrontImage}'
                            },
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            '${ApiConstants.baseUrl}$nrcFrontImage',
                            height: 180,
                            fit: BoxFit.cover,
                          ),
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
            if (_buttonBarController.index == 0)
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
                child: nrcBackImage.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.image_preview,
                            arguments: {
                              "image_url":
                                  '${ApiConstants.baseUrl}${nrcBackImage}'
                            },
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            '${ApiConstants.baseUrl}$nrcBackImage',
                            height: 180,
                            fit: BoxFit.cover,
                          ),
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
            if (_buttonBarController.index == 1)
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
                child: passportImage.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.image_preview,
                            arguments: {
                              "image_url":
                                  '${ApiConstants.baseUrl}${passportImage}'
                            },
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            '${ApiConstants.baseUrl}$passportImage',
                            height: 180,
                            fit: BoxFit.cover,
                          ),
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
            if (_buttonBarController.index == 2)
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
                child: drivingLicenceImage.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.image_preview,
                            arguments: {
                              "image_url":
                                  '${ApiConstants.baseUrl}${drivingLicenceImage}'
                            },
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            '${ApiConstants.baseUrl}$drivingLicenceImage',
                            height: 180,
                            fit: BoxFit.cover,
                          ),
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
              child: signatureImage.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.image_preview,
                          arguments: {
                            "image_url":
                                '${ApiConstants.baseUrl}${signatureImage}'
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          '${ApiConstants.baseUrl}$signatureImage',
                          height: 180,
                          fit: BoxFit.cover,
                        ),
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
                    ],
                  ),
                ),
              ],
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
              child: bankAccountImage.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.image_preview,
                          arguments: {
                            "image_url":
                                '${ApiConstants.baseUrl}${bankAccountImage}'
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          '${ApiConstants.baseUrl}$bankAccountImage',
                          height: 180,
                          fit: BoxFit.cover,
                        ),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: Text(
                              language["Upload Bank Account Photo"] ??
                                  "Upload Bank Account Photo",
                              textAlign: TextAlign.center,
                              style: FontConstants.subheadline2,
                            ),
                          ),
                        ],
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
                bottom: 4,
              ),
              child: TextFormField(
                controller: sellerRegistrationFeeDesc,
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
                bottom: 16,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  formatter.format(amount),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.greenColor,
                  ),
                ),
              ),
            ),
            Container(
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
              child: monthlyTransactionImage.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.image_preview,
                          arguments: {
                            "image_url":
                                '${ApiConstants.baseUrl}${monthlyTransactionImage}'
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          '${ApiConstants.baseUrl}$monthlyTransactionImage',
                          height: 180,
                          fit: BoxFit.cover,
                        ),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: Text(
                              language[
                                      "Upload Monthly Fees Transaction Screenshot"] ??
                                  "Upload Monthly Fees Transaction Screenshot",
                              textAlign: TextAlign.center,
                              style: FontConstants.subheadline2,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 24,
        ),
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
            showLoadingDialog(context);
            updateUser();
          },
          child: Text(
            language["Approve"] ?? "Approve",
            style: FontConstants.button1,
          ),
        ),
      ),
    );
  }
}
