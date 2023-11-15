import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/address_service.dart';
import 'package:e_commerce/src/services/bank_accounts_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/insurance_rules_service.dart';
import 'package:e_commerce/src/services/payment_type_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:e_commerce/src/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  final addressService = AddressService();
  final paymentTypeService = PaymentTypeService();
  final insuranceRulesService = InsuranceRulesService();
  final bankAccountsService = BankAccountsService();
  FocusNode _countryFocusNode = FocusNode();
  FocusNode _cityFocusNode = FocusNode();
  FocusNode _stateFocusNode = FocusNode();
  FocusNode _townshipFocusNode = FocusNode();
  FocusNode _postalCodeFocusNode = FocusNode();
  FocusNode _houseNoFocusNode = FocusNode();
  FocusNode _streetFocusNode = FocusNode();
  FocusNode _wardFocusNode = FocusNode();
  FocusNode _noteFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  TextEditingController country = TextEditingController(text: '');
  TextEditingController city = TextEditingController(text: '');
  TextEditingController state = TextEditingController(text: '');
  TextEditingController township = TextEditingController(text: '');
  TextEditingController postalCode = TextEditingController(text: '');
  TextEditingController ward = TextEditingController(text: '');
  TextEditingController streetAddress = TextEditingController(text: '');
  TextEditingController homeAddress = TextEditingController(text: '');
  TextEditingController note = TextEditingController(text: '');
  List<Map<String, dynamic>> insurancerules = [
    {
      "description": "No Insurance",
      "commission_percentage": 0.0,
    }
  ];
  List<String> insurancenames = ["No Insurance"];
  String insurancetype = "No Insurance";
  double commissionPercentage = 0.0;
  List<String> paymenttypes = [
    'Cash on Delivery',
    'Preorder',
  ];
  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;
  String paymenttype = 'Cash on Delivery';
  int ruleId = 0;
  List<Map<String, dynamic>> carts = [];
  double subtotal = 0.0;
  double total = 0.0;
  List bankaccounts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        carts = arguments["carts"] ?? [];
        subtotal = arguments["subtotal"] ?? 0.0;
        total = arguments["total"] ?? 0.0;
      }
    });
    getAddress();
    getPaymentTypes();
    getInsuranceRules();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  getAddress() async {
    try {
      final response = await addressService.getAddressData();
      if (response!["code"] == 200) {
        setState(() {
          country.text = response["data"]["country"] ?? "";
          city.text = response["data"]["city"] ?? "";
          state.text = response["data"]["state"] ?? "";
          township.text = response["data"]["township"] ?? "";
          postalCode.text = response["data"]["postal_code"] ?? "";
          ward.text = response["data"]["ward"] ?? "";
          streetAddress.text = response["data"]["street_address"] ?? "";
          homeAddress.text = response["data"]["home_address"] ?? "";
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
        }
      }
    }
  }

  getPaymentTypes() async {
    try {
      final response = await paymentTypeService.getPaymentTypesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
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

  getInsuranceRules() async {
    try {
      insurancetype = "No Insurance";
      commissionPercentage = 0.0;
      ruleId = 0;
      insurancenames = ["No Insurance"];
      insurancerules = [
        {
          "description": "No Insurance",
          "commission_percentage": 0.0,
          "rule_id": 0,
        }
      ];

      final response =
          await insuranceRulesService.getInsuranceRulesData(amount: total);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          insurancerules = [
            ...insurancerules,
            ...(response["data"] as List).cast<Map<String, dynamic>>()
          ];

          for (var data in response["data"]) {
            if (data["description"] != null) {
              insurancenames.add(data["description"]);
            }
          }
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

  getBankAccounts(accountType) async {
    try {
      setState(() {
        bankaccounts = [];
      });
      final response = await bankAccountsService.getBankAccountsData(
          accountType: accountType);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          bankaccounts = response["data"];
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _countryFocusNode.unfocus();
        _cityFocusNode.unfocus();
        _stateFocusNode.unfocus();
        _townshipFocusNode.unfocus();
        _postalCodeFocusNode.unfocus();
        _houseNoFocusNode.unfocus();
        _streetFocusNode.unfocus();
        _wardFocusNode.unfocus();
        _noteFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            language["Order"] ?? "Order",
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 4,
                            bottom: 8,
                          ),
                          child: TextFormField(
                            controller: country,
                            focusNode: _countryFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: language["Country"] ?? "Country",
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
                                return language["Enter Country"] ??
                                    "Enter Country";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 8,
                          ),
                          child: TextFormField(
                            controller: city,
                            focusNode: _cityFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: language["City"] ?? "City",
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
                                return language["Enter City"] ?? "Enter City";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 4,
                            bottom: 8,
                          ),
                          child: TextFormField(
                            controller: state,
                            focusNode: _stateFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: language["State"] ?? "State",
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
                                return language["Enter State"] ?? "Enter State";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 8,
                          ),
                          child: TextFormField(
                            controller: township,
                            focusNode: _townshipFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: language["Township"] ?? "Township",
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
                                return language["Enter Township"] ??
                                    "Enter Township";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 4,
                            bottom: 8,
                          ),
                          child: TextFormField(
                            controller: postalCode,
                            focusNode: _postalCodeFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText:
                                  language["Postal Code"] ?? "Postal Code",
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
                                return language["Enter Postal Code"] ??
                                    "Enter Postal Code";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 8,
                          ),
                          child: TextFormField(
                            controller: homeAddress,
                            focusNode: _houseNoFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: language["House No."] ?? "House No.",
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
                                return language["Enter House No."] ??
                                    "Enter House No.";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 4,
                            bottom: 8,
                          ),
                          child: TextFormField(
                            controller: streetAddress,
                            focusNode: _streetFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: language["Street"] ?? "Street",
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
                                return language["Enter Street"] ??
                                    "Enter Street";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 8,
                          ),
                          child: TextFormField(
                            controller: ward,
                            focusNode: _wardFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: language["Ward"] ?? "Ward",
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
                                return language["Enter Ward"] ?? "Enter Ward";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: TextFormField(
                      controller: note,
                      focusNode: _noteFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      style: FontConstants.body1,
                      cursorColor: Colors.black,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: language["Note"] ?? "Note",
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
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: CustomDropDown(
                      value: paymenttype,
                      fillColor: ColorConstants.fillcolor,
                      onChanged: (newValue) {
                        setState(() {
                          pickedFile = null;
                          paymenttype = newValue ?? "Cash on Delivery";
                        });
                        if (paymenttype == 'Preorder') {
                          getBankAccounts('mbanking');
                        }
                      },
                      items: paymenttypes,
                    ),
                  ),
                  paymenttype == 'Preorder'
                      ? TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(
                              child: Text(
                                "mBanking",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Wallet",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                          onTap: (index) {
                            if (index == 0) {
                              getBankAccounts('mbanking');
                            } else {
                              getBankAccounts('wallet');
                            }
                          },
                        )
                      : Container(),
                  bankaccounts.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: 16,
                            bottom: 4,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              language[
                                      "Transfer Half-Prepaid to the mentioned account numbers only"] ??
                                  "Transfer Half-Prepaid to the mentioned account numbers only",
                              style: FontConstants.caption2,
                            ),
                          ),
                        )
                      : Container(),
                  if (paymenttype == 'Preorder')
                    ...bankaccounts.map((item) {
                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        color: ColorConstants.fillcolor,
                        child: ListTile(
                          leading: item["bank_logo"].isNotEmpty
                              ? ClipRRect(
                                  child: Image.network(
                                    '${ApiConstants.baseUrl}${item["bank_logo"]}',
                                    fit: BoxFit.cover,
                                    height: 60,
                                    width: 60,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                    height: 60,
                                    width: 60,
                                  ),
                                ),
                          title: Text(
                            "${item["account_number"]}",
                            style: FontConstants.body1,
                          ),
                          subtitle: Text(
                            "${item["account_holder_name"]}",
                            style: FontConstants.caption2,
                          ),
                        ),
                      );
                    }).toList(),
                  paymenttype == 'Preorder'
                      ? GestureDetector(
                          onTap: () async {
                            try {
                              pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              setState(() {});
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 16,
                              bottom: 8,
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: ColorConstants.fillcolor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: pickedFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(pickedFile!.path),
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 58,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/upload.svg",
                                          width: 24,
                                          height: 24,
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
                                                  "Upload transaction history screenshot"] ??
                                              "Upload transaction history screenshot",
                                          style: FontConstants.subheadline2,
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: insurancetype != 'No Insurance' ? 4 : 24,
                    ),
                    child: CustomDropDown(
                      value: insurancetype,
                      fillColor: ColorConstants.fillcolor,
                      onChanged: (newValue) {
                        setState(() {
                          insurancetype = newValue ?? insurancenames[0];
                        });
                        for (var data in insurancerules) {
                          if (data["description"] == insurancetype) {
                            commissionPercentage =
                                data["commission_percentage"];
                            ruleId = data["rule_id"];
                          }
                        }
                      },
                      items: insurancenames,
                    ),
                  ),
                  insurancetype != 'No Insurance'
                      ? Padding(
                          padding: EdgeInsets.only(
                            bottom: 24,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'A commission of ${commissionPercentage.toString()}%.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xffF97316),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
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
                if (paymenttype == 'Preorder' && pickedFile == null) {
                  ToastUtil.showToast(
                      0, language["Choose Image"] ?? "Choose Image");
                  return;
                }
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.order_confirm,
                  arguments: {
                    "carts": carts,
                    "address": {
                      "street_address": streetAddress.text,
                      "city": city.text,
                      "state": state.text,
                      "postal_code": postalCode.text,
                      "country": country.text,
                      "township": township.text,
                      "ward": ward.text,
                      "home_address": homeAddress.text,
                      "note": note.text,
                    },
                    "paymenttype": paymenttype,
                    "pickedFile": pickedFile,
                    "insurancetype": insurancetype,
                    "subtotal": subtotal,
                    "commissionAmount": subtotal * (commissionPercentage / 100),
                    "total": total + (subtotal * (commissionPercentage / 100)),
                    "ruleId": ruleId,
                  },
                  (route) => true,
                );
              }
            },
            child: Text(
              language["Order"] ?? "Order",
              style: FontConstants.button1,
            ),
          ),
        ),
      ),
    );
  }
}
