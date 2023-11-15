import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/bank_account_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:e_commerce/src/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class BankAccountSetupScreen extends StatefulWidget {
  const BankAccountSetupScreen({super.key});

  @override
  State<BankAccountSetupScreen> createState() => _BankAccountSetupScreenState();
}

class _BankAccountSetupScreenState extends State<BankAccountSetupScreen> {
  final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final bankAccountService = BankAccountService();
  FocusNode _accountHolderNameFocusNode = FocusNode();
  FocusNode _accountNumberFocusNode = FocusNode();

  TextEditingController accountHolderName = TextEditingController(text: '');
  TextEditingController accountNumber = TextEditingController(text: '');

  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;
  String logoUrl = '';

  List<String> accountTypes = [
    'mbanking',
    'wallet',
  ];
  String accountType = 'mbanking';

  int id = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        id = arguments["id"] ?? 0;
        if (id != 0) {
          getBankAccount();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(source) async {
    try {
      pickedFile = await _picker.pickImage(
        source: source,
      );
      logoUrl = "";
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
        logoUrl = res["url"];
      }
    } catch (error) {
      print('Error uploading file: $error');
    }
  }

  getBankAccount() async {
    try {
      final response = await bankAccountService.getBankAccountData(id);
      if (response!["code"] == 200) {
        setState(() {
          accountType = response["data"]["account_type"] ?? "";
          accountHolderName.text =
              response["data"]["account_holder_name"] ?? "";
          accountNumber.text = response["data"]["account_number"] ?? "";
          logoUrl = response["data"]["bank_logo"] ?? "";
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

  addBankAccount() async {
    try {
      final body = {
        "account_type": accountType,
        "account_holder_name": accountHolderName.text,
        "account_number": accountNumber.text,
        "bank_logo": logoUrl,
      };

      final response = await bankAccountService.addBankAccountData(body);
      Navigator.pop(context);
      if (response!["code"] == 201) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.bank_accounts_setup,
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

  updateBankAccount() async {
    try {
      final body = {
        "account_type": accountType,
        "account_holder_name": accountHolderName.text,
        "account_number": accountNumber.text,
        "bank_logo": logoUrl,
      };

      final response = await bankAccountService.updateBankAccountData(body, id);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.bank_accounts_setup,
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

  deleteBankAccount() async {
    try {
      final response = await bankAccountService.deleteBankAccountData(id);
      Navigator.pop(context);
      if (response!["code"] == 204) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.bank_accounts_setup,
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
        _accountHolderNameFocusNode.unfocus();
        _accountNumberFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            language["Bank Account"] ?? "Bank Account",
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
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                        },
                        child: logoUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  '${ApiConstants.baseUrl}${logoUrl.toString()}',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : pickedFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(pickedFile!.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                      ),
                      Positioned(
                        bottom: -5,
                        right: -10,
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
                              "assets/icons/gallery.svg",
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
                      top: 24,
                      bottom: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language["Account Number"] ?? "Account Number",
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
                      controller: accountNumber,
                      focusNode: _accountNumberFocusNode,
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
                          return language["Enter Account Number"] ??
                              "Enter Account Number";
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
                        language["Account Holder Name"] ??
                            "Account Holder Name",
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
                      controller: accountHolderName,
                      focusNode: _accountHolderNameFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
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
                          return language["Enter Account Holder Name"] ??
                              "Enter Account Holder Name";
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
                        language["Account Type"] ?? "Account Type",
                        style: FontConstants.caption1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 4,
                    ),
                    child: CustomDropDown(
                      value: accountType,
                      fillColor: ColorConstants.fillcolor,
                      onChanged: (newValue) {
                        setState(() {
                          pickedFile = null;
                          accountType = newValue ?? "mbanking";
                        });
                      },
                      items: accountTypes,
                    ),
                  ),
                ],
              ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      showLoadingDialog(context);
                      if (pickedFile != null) {
                        await uploadFile();
                      }
                      addBankAccount();
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: ColorConstants.redcolor,
                          ),
                          onPressed: () async {
                            showLoadingDialog(context);
                            deleteBankAccount();
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              showLoadingDialog(context);
                              if (pickedFile != null) {
                                await uploadFile();
                              }
                              updateBankAccount();
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
