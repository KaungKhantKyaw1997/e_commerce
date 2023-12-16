import 'dart:convert';
import 'dart:io';

import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/seller_registration_fee_service.dart';
import 'package:e_commerce/src/services/user_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:e_commerce/src/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen> {
  final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final userService = UserService();
  final sellerRegistrationFeeService = SellerRegistrationFeeService();
  NumberFormat formatter = NumberFormat('###,###.00', 'en_US');
  AnimatedButtonController _buttonBarController = AnimatedButtonController();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _companyNameFocusNode = FocusNode();
  FocusNode _professionalTitleFocusNode = FocusNode();
  FocusNode _locationFocusNode = FocusNode();
  FocusNode _shopOrPageNameFocusNode = FocusNode();
  FocusNode _businessPhoneFocusNode = FocusNode();
  FocusNode _addressFocusNode = FocusNode();
  FocusNode _nrcFocusNode = FocusNode();
  FocusNode _bankCodeFocusNode = FocusNode();
  FocusNode _bankAccountFocusNode = FocusNode();
  FocusNode _walletTypeFocusNode = FocusNode();
  FocusNode _walletAccountFocusNode = FocusNode();

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
  bool offlineTrader = false;
  bool modifyOrderStatus = false;
  bool canViewAddress = false;
  bool canViewPhone = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;
  String profileImage = '';
  XFile? facebookProfilePickedFile;
  String facebookProfileImage = '';
  XFile? facebookPagePickedFile;
  String facebookPageImage = '';
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
  XFile? bankAccountPickedFile;
  String bankAccountImage = '';
  XFile? monthlyTransactionPickedFile;
  String monthlyTransactionImage = '';
  List sellerRegistrationFees = [];
  List<String> sellerRegistrationFeesDesc = [];
  int sellerRegistrationFeeId = 0;
  String sellerRegistrationFeeDesc = '';

  List<String> roles = [
    "user",
    "admin",
    "agent",
  ];
  String role = 'user';

  List<String> statuslist = [
    "pending",
    "active",
  ];
  String status = 'pending';
  double amount = 0.0;
  bool checkSeller = false;
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

          for (var data in response["data"]) {
            if (data["description"] != null) {
              sellerRegistrationFeesDesc.add(data["description"]);
            }
          }
          sellerRegistrationFeeId = sellerRegistrationFees[0]["fee_id"];
          sellerRegistrationFeeDesc = sellerRegistrationFees[0]["description"];
          amount = sellerRegistrationFees[0]["amount"];
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
          role = response["data"]["role"] ?? "user";
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
          status = response["data"]["account_status"] ?? "pending";
          modifyOrderStatus =
              response["data"]["can_modify_order_status"] ?? false;
          canViewAddress = response["data"]["can_view_address"] ?? false;
          canViewPhone = response["data"]["can_view_phone"] ?? false;

          if (response["data"]["seller_information"]["facebook_profile_image"]
              .isNotEmpty) {
            checkSeller = true;
          }

          if (checkSeller) {
            facebookProfileImage = response["data"]["seller_information"]
                    ["facebook_profile_image"] ??
                "";
            facebookPageImage = response["data"]["seller_information"]
                    ["facebook_page_image"] ??
                "";
            shopOrPageName.text = response["data"]["seller_information"]
                    ["shop_or_page_name"] ??
                "";
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
            int index = drivingLicenceImage.isNotEmpty
                ? 2
                : passportImage.isNotEmpty
                    ? 1
                    : 0;
            _buttonBarController.setIndex(index);

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
                sellerRegistrationFeeDesc = data["description"];
                amount = data["amount"];
                break;
              }
            }
            monthlyTransactionImage = response["data"]["seller_information"]
                    ["monthly_transaction_screenshot"] ??
                "";
          }
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

  Future<void> _pickImage(source, type) async {
    try {
      XFile? file = await _picker.pickImage(
        source: source,
      );
      if (type == "profile") {
        pickedFile = file;
      } else if (type == "facebookprofile") {
        facebookProfilePickedFile = file;
      } else if (type == "facebookpage") {
        facebookPagePickedFile = file;
      } else if (type == "frontnrc") {
        nrcFrontPickedFile = file;
      } else if (type == "backnrc") {
        nrcBackPickedFile = file;
      } else if (type == "passport") {
        passportPickedFile = file;
      } else if (type == "drivinglicence") {
        drivingLicencePickedFile = file;
      } else if (type == "signature") {
        signaturePickedFile = file;
      } else if (type == "bankaccount") {
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
      var response = await AuthService.uploadFile(File(pickedFile!.path));
      var res = jsonDecode(response.body);
      if (res["code"] == 200) {
        if (type == "profile") {
          profileImage = res["url"];
        } else if (type == "facebookprofile") {
          facebookProfileImage = res["url"];
        } else if (type == "facebookpage") {
          facebookPageImage = res["url"];
        } else if (type == "frontnrc") {
          nrcFrontImage = res["url"];
        } else if (type == "backnrc") {
          nrcBackImage = res["url"];
        } else if (type == "passport") {
          passportImage = res["url"];
        } else if (type == "drivinglicence") {
          drivingLicenceImage = res["url"];
        } else if (type == "signature") {
          signatureImage = res["url"];
        } else if (type == "bankaccount") {
          bankAccountImage = res["url"];
        } else if (type == "monthlytransaction") {
          monthlyTransactionImage = res["url"];
        }
      }
    } catch (error) {
      print('Error uploading file: $error');
    }
  }

  addUser() async {
    try {
      final body = {
        "username": email.text,
        "email": email.text,
        "password": password.text,
        "role": role,
        "name": name.text,
        "phone": '959${phone.text}',
        "profile_image": profileImage,
        "account_status": status,
        "can_modify_order_status": modifyOrderStatus,
        "can_view_address": canViewAddress,
        "can_view_phone": canViewPhone,
      };

      if (checkSeller) {
        body["seller_information"] = {
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
        };
      }

      final response = await userService.addUserData(body);
      Navigator.pop(context);
      if (response!["code"] == 201) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.users_setup,
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

  updateUser() async {
    try {
      final body = {
        "email": email.text,
        "password": password.text,
        "role": role,
        "name": name.text,
        "phone": '959${phone.text}',
        "profile_image": profileImage,
        "account_status": status,
        "can_modify_order_status": modifyOrderStatus,
        "can_view_address": canViewAddress,
        "can_view_phone": canViewPhone,
      };

      if (checkSeller) {
        body["seller_information"] = {
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
        };
      }

      final response = await userService.updateUserData(body, id);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.users_setup,
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

  deleteUser() async {
    try {
      final response = await userService.deleteUserData(id);
      Navigator.pop(context);
      if (response!["code"] == 204) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.users_setup,
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
        _emailFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        _confirmPasswordFocusNode.unfocus();
        _nameFocusNode.unfocus();
        _phoneFocusNode.unfocus();
        _companyNameFocusNode.unfocus();
        _professionalTitleFocusNode.unfocus();
        _locationFocusNode.unfocus();
        _shopOrPageNameFocusNode.unfocus();
        _businessPhoneFocusNode.unfocus();
        _addressFocusNode.unfocus();
        _nrcFocusNode.unfocus();
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
            language["User"] ?? "User",
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
                          _pickImage(ImageSource.gallery, "profile");
                        },
                        child: pickedFile != null
                            ? ClipOval(
                                child: Image.file(
                                  File(pickedFile!.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : profileImage.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      '${profileImage.startsWith("/images") ? ApiConstants.baseUrl : ""}$profileImage',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
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
                    ),
                    Positioned(
                      bottom: 24,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _pickImage(ImageSource.gallery, "profile");
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
                    style: id != 0 ? FontConstants.body2 : FontConstants.body1,
                    cursorColor: Colors.black,
                    readOnly: id != 0 ? true : false,
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
                    bottom: 16,
                  ),
                  child: TextFormField(
                    controller: phone,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
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
                  child: CustomDropDown(
                    value: role,
                    fillColor: ColorConstants.fillColor,
                    onChanged: (newValue) {
                      setState(() {
                        role = newValue ?? "user";
                        companyName.text = '';
                        professionalTitle.text = '';
                        location.text = '';
                        offlineTrader = false;
                        modifyOrderStatus = false;
                        canViewAddress = false;
                        canViewPhone = false;
                      });
                    },
                    items: roles,
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
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: role == 'agent' ? 16 : 24,
                  ),
                  child: CustomDropDown(
                    value: status,
                    fillColor: ColorConstants.fillColor,
                    onChanged: (newValue) {
                      setState(() {
                        status = newValue ?? "pending";
                      });
                    },
                    items: statuslist,
                  ),
                ),
                if (role == 'agent')
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language["Company Name"] ?? "Company Name",
                        style: FontConstants.caption1,
                      ),
                    ),
                  ),
                if (role == 'agent')
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: TextFormField(
                      controller: companyName,
                      focusNode: _companyNameFocusNode,
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
                          return language["Enter Company Name"] ??
                              "Enter Company Name";
                        }
                        return null;
                      },
                    ),
                  ),
                if (role == 'agent')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
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
                                  language["Professional Title"] ??
                                      "Professional Title",
                                  style: FontConstants.caption1,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 4,
                              ),
                              child: TextFormField(
                                controller: professionalTitle,
                                focusNode: _professionalTitleFocusNode,
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
                                    return language[
                                            "Enter Professional Title"] ??
                                        "Enter Professional Title";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
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
                                  language["Location"] ?? "Location",
                                  style: FontConstants.caption1,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                right: 16,
                              ),
                              child: TextFormField(
                                controller: location,
                                focusNode: _locationFocusNode,
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
                                    return language["Enter Location"] ??
                                        "Enter Location";
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
                if (role == 'agent')
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: offlineTrader,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    offlineTrader = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  language["Offline Trader"] ??
                                      "Offline Trader",
                                  style: FontConstants.caption1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: modifyOrderStatus,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    modifyOrderStatus = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  language["Order Status"] ?? "Order Status",
                                  style: FontConstants.caption1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                if (role == 'agent')
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: canViewAddress,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    canViewAddress = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  language["Vew Address"] ?? "Vew Address",
                                  style: FontConstants.caption1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: canViewPhone,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    canViewPhone = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  language["View Phone Number"] ??
                                      "View Phone Number",
                                  style: FontConstants.caption1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                if (checkSeller)
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
                          child: facebookProfilePickedFile != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(facebookProfilePickedFile!.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : facebookProfileImage.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        '${ApiConstants.baseUrl}$facebookProfileImage',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
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
                if (checkSeller)
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
                if (checkSeller)
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
                                  "Enter Shop Name or Facebook Page Name"] ??
                              "Enter Shop Name or Facebook Page Name";
                        }
                        return null;
                      },
                    ),
                  ),
                if (checkSeller)
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
                          : facebookPageImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    '${ApiConstants.baseUrl}$facebookPageImage',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          language[
                                                  "Upload Facebook Page Screenshot"] ??
                                              "Upload Facebook Page Screenshot",
                                          textAlign: TextAlign.center,
                                          style: FontConstants.subheadline2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                if (checkSeller)
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
                if (checkSeller)
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
                if (checkSeller)
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
                if (checkSeller)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
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
                if (checkSeller)
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
                if (checkSeller && _buttonBarController.index == 0)
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
                if (checkSeller && _buttonBarController.index == 0)
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
                if (checkSeller && _buttonBarController.index == 0)
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
                          : nrcFrontImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    '${ApiConstants.baseUrl}$nrcFrontImage',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                if (checkSeller && _buttonBarController.index == 0)
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
                          : nrcBackImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    '${ApiConstants.baseUrl}$nrcBackImage',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                if (checkSeller && _buttonBarController.index == 1)
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
                          : passportImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    '${ApiConstants.baseUrl}$passportImage',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                if (checkSeller && _buttonBarController.index == 2)
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
                          : drivingLicenceImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    '${ApiConstants.baseUrl}$drivingLicenceImage',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                if (checkSeller)
                  GestureDetector(
                    onTap: () {
                      _pickImage(ImageSource.gallery, "signature");
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
                      child: signaturePickedFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(signaturePickedFile!.path),
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            )
                          : signatureImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    '${ApiConstants.baseUrl}$signatureImage',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                if (checkSeller)
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
                                    return language["Enter Bank"] ??
                                        "Enter Bank";
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
                if (checkSeller)
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
                          : bankAccountImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    '${ApiConstants.baseUrl}$bankAccountImage',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          language[
                                                  "Upload Bank Account Photo"] ??
                                              "Upload Bank Account Photo",
                                          textAlign: TextAlign.center,
                                          style: FontConstants.subheadline2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                if (checkSeller)
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
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
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
                                    return language[
                                            "Enter Wallet Account Number"] ??
                                        "Enter Wallet Account Number";
                                  }
                                  final RegExp phoneRegExp =
                                      RegExp(r"^[+]{0,1}[0-9]{7,9}$");

                                  if (!phoneRegExp.hasMatch(value)) {
                                    return language[
                                            "Invalid Wallet Account Number"] ??
                                        "Invalid Wallet Account Number";
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
                if (checkSeller)
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
                if (checkSeller)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 4,
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
                          if (data["description"] ==
                              sellerRegistrationFeeDesc) {
                            sellerRegistrationFeeId = data["fee_id"];
                            amount = data["amount"];
                          }
                        }
                      },
                      items: sellerRegistrationFeesDesc,
                    ),
                  ),
                if (checkSeller)
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
                if (checkSeller)
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
                                fit: BoxFit.cover,
                              ),
                            )
                          : monthlyTransactionImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    '${ApiConstants.baseUrl}$monthlyTransactionImage',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 48,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: id == 0
            ? Container(
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
                    if (_formKey.currentState!.validate()) {
                      if (checkSeller && facebookProfilePickedFile == null) {
                        ToastUtil.showToast(
                            0,
                            language["Choose Facebook Profile"] ??
                                "Choose Facebook Profile");
                        return;
                      }
                      if (checkSeller && facebookPagePickedFile == null) {
                        ToastUtil.showToast(
                            0,
                            language["Choose Facebook Page Screenshot"] ??
                                "Choose Facebook Page Screenshot");
                        return;
                      }
                      if (checkSeller &&
                          _buttonBarController.index == 0 &&
                          nrcFrontPickedFile == null) {
                        ToastUtil.showToast(0,
                            language["Choose Front NRC"] ?? "Choose Front NRC");
                        return;
                      }
                      if (checkSeller &&
                          _buttonBarController.index == 0 &&
                          nrcBackPickedFile == null) {
                        ToastUtil.showToast(0,
                            language["Choose Back NRC"] ?? "Choose Back NRC");
                        return;
                      }
                      if (checkSeller &&
                          _buttonBarController.index == 1 &&
                          passportPickedFile == null) {
                        ToastUtil.showToast(0,
                            language["Choose Passport"] ?? "Choose Passport");
                        return;
                      }
                      if (checkSeller &&
                          _buttonBarController.index == 2 &&
                          drivingLicencePickedFile == null) {
                        ToastUtil.showToast(
                            0,
                            language["Choose Driving Licence"] ??
                                "Choose Driving Licence");
                        return;
                      }
                      if (checkSeller && signaturePickedFile == null) {
                        ToastUtil.showToast(0,
                            language["Choose Signature"] ?? "Choose Signature");
                        return;
                      }
                      if (checkSeller && bankAccountPickedFile == null) {
                        ToastUtil.showToast(
                            0,
                            language["Choose Bank Account Photo"] ??
                                "Choose Bank Account Photo");
                        return;
                      }
                      if (checkSeller && monthlyTransactionPickedFile == null) {
                        ToastUtil.showToast(
                            0,
                            language[
                                    "Choose Monthly Fees Transaction Screenshot"] ??
                                "Choose Monthly Fees Transaction Screenshot");
                        return;
                      }

                      showLoadingDialog(context);
                      if (pickedFile != null) {
                        await uploadFile(pickedFile, 'profile');
                      }
                      if (checkSeller) {
                        await uploadFile(
                            facebookProfilePickedFile, 'facebookprofile');
                        await uploadFile(
                            facebookPagePickedFile, 'facebookpage');
                        if (_buttonBarController.index == 0) {
                          await uploadFile(nrcFrontPickedFile, 'frontnrc');
                          await uploadFile(nrcBackPickedFile, 'backnrc');
                        } else if (_buttonBarController.index == 1) {
                          await uploadFile(passportPickedFile, 'passport');
                        } else if (_buttonBarController.index == 2) {
                          await uploadFile(
                              drivingLicencePickedFile, 'drivinglicence');
                        }
                        await uploadFile(signaturePickedFile, 'signature');
                        await uploadFile(bankAccountPickedFile, 'bankaccount');
                        await uploadFile(
                            monthlyTransactionPickedFile, 'monthlytransaction');
                      }

                      addUser();
                    }
                  },
                  child: Text(
                    language["Save"] ?? "Save",
                    style: FontConstants.button1,
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: Container(
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
                            backgroundColor: ColorConstants.redColor,
                          ),
                          onPressed: () async {
                            showLoadingDialog(context);
                            deleteUser();
                          },
                          child: Text(
                            language["Delete"] ?? "Delete",
                            style: FontConstants.button1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: Container(
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
                            if (_formKey.currentState!.validate()) {
                              if (checkSeller &&
                                  facebookProfilePickedFile == null &&
                                  facebookProfileImage.isEmpty) {
                                ToastUtil.showToast(
                                    0,
                                    language["Choose Facebook Profile"] ??
                                        "Choose Facebook Profile");
                                return;
                              }
                              if (checkSeller &&
                                  facebookPagePickedFile == null &&
                                  facebookPageImage.isEmpty) {
                                ToastUtil.showToast(
                                    0,
                                    language[
                                            "Choose Facebook Page Screenshot"] ??
                                        "Choose Facebook Page Screenshot");
                                return;
                              }
                              if (checkSeller &&
                                  _buttonBarController.index == 0 &&
                                  nrcFrontPickedFile == null &&
                                  nrcFrontImage.isEmpty) {
                                ToastUtil.showToast(
                                    0,
                                    language["Choose Front NRC"] ??
                                        "Choose Front NRC");
                                return;
                              }
                              if (checkSeller &&
                                  _buttonBarController.index == 0 &&
                                  nrcBackPickedFile == null &&
                                  nrcBackImage.isEmpty) {
                                ToastUtil.showToast(
                                    0,
                                    language["Choose Back NRC"] ??
                                        "Choose Back NRC");
                                return;
                              }
                              if (checkSeller &&
                                  _buttonBarController.index == 1 &&
                                  passportPickedFile == null &&
                                  passportImage.isEmpty) {
                                ToastUtil.showToast(
                                    0,
                                    language["Choose Passport"] ??
                                        "Choose Passport");
                                return;
                              }
                              if (checkSeller &&
                                  _buttonBarController.index == 2 &&
                                  drivingLicencePickedFile == null &&
                                  drivingLicenceImage.isEmpty) {
                                ToastUtil.showToast(
                                    0,
                                    language["Choose Driving Licence"] ??
                                        "Choose Driving Licence");
                                return;
                              }
                              if (checkSeller &&
                                  signaturePickedFile == null &&
                                  signatureImage.isEmpty) {
                                ToastUtil.showToast(
                                    0,
                                    language["Choose Signature"] ??
                                        "Choose Signature");
                                return;
                              }
                              if (checkSeller &&
                                  bankAccountPickedFile == null &&
                                  bankAccountImage.isEmpty) {
                                ToastUtil.showToast(
                                    0,
                                    language["Choose Bank Account Photo"] ??
                                        "Choose Bank Account Photo");
                                return;
                              }
                              if (checkSeller &&
                                  monthlyTransactionPickedFile == null &&
                                  monthlyTransactionImage.isEmpty) {
                                ToastUtil.showToast(
                                    0,
                                    language[
                                            "Choose Monthly Fees Transaction Screenshot"] ??
                                        "Choose Monthly Fees Transaction Screenshot");
                                return;
                              }

                              showLoadingDialog(context);
                              if (pickedFile != null) {
                                await uploadFile(pickedFile, 'profile');
                              }
                              if (checkSeller) {
                                if (facebookProfilePickedFile != null) {
                                  await uploadFile(facebookProfilePickedFile,
                                      'facebookprofile');
                                }
                                if (facebookPagePickedFile != null) {
                                  await uploadFile(
                                      facebookPagePickedFile, 'facebookpage');
                                }
                                if (_buttonBarController.index == 0) {
                                  if (nrcFrontPickedFile != null) {
                                    await uploadFile(
                                        nrcFrontPickedFile, 'frontnrc');
                                  }
                                  if (nrcBackPickedFile != null) {
                                    await uploadFile(
                                        nrcBackPickedFile, 'backnrc');
                                  }
                                } else if (_buttonBarController.index == 1) {
                                  if (passportPickedFile != null) {
                                    await uploadFile(
                                        passportPickedFile, 'passport');
                                  }
                                } else if (_buttonBarController.index == 2) {
                                  if (drivingLicencePickedFile != null) {
                                    await uploadFile(drivingLicencePickedFile,
                                        'drivinglicence');
                                  }
                                }
                                if (signaturePickedFile != null) {
                                  await uploadFile(
                                      signaturePickedFile, 'signature');
                                }
                                if (bankAccountPickedFile != null) {
                                  await uploadFile(
                                      bankAccountPickedFile, 'bankaccount');
                                }
                                if (monthlyTransactionPickedFile != null) {
                                  await uploadFile(monthlyTransactionPickedFile,
                                      'monthlytransaction');
                                }
                              }

                              updateUser();
                            }
                          },
                          child: Text(
                            language["Update"] ?? "Update",
                            style: FontConstants.button1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
