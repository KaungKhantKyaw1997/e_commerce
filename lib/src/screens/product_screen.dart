import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:e_commerce/src/providers/chats_provider.dart';
import 'package:e_commerce/src/services/buyer_protection_service.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/seller_report_service.dart';
import 'package:e_commerce/src/services/user_service.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerce/src/utils/toast.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final crashlytic = new CrashlyticsService();
  ScrollController _scrollController = ScrollController();
  final buyerProtectionService = BuyerProtectionService();
  final chatService = ChatService();
  final userService = UserService();
  final sellerReportService = SellerReportService();
  final PageController _imageController = PageController();
  final _formKey = GlobalKey<FormState>();
  TextEditingController phone = TextEditingController(text: '');
  TextEditingController message = TextEditingController(text: '');
  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _messageFocusNode = FocusNode();
  List<Map<String, dynamic>> carts = [];
  Map<String, dynamic> product = {};
  Map<String, dynamic> sellerinfo = {};
  double _currentPage = 0;
  bool updateCart = false;
  List buyerProtections = [];
  List reportSubjects = [];
  List<String> reportSubjectsDesc = [];
  int reportSubjectId = 0;
  String reportSubjectDesc = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    getData();
    getCart();
    getBuyerProtections();
    _imageController.addListener(() {
      setState(() {
        _currentPage = _imageController.page ?? 0;
      });
    });
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        product = arguments;
        getSellerInformation(product["creator_id"]);

        setState(() {
          product["quantity"] = 0;
          product["totalamount"] = 0.0;

          for (var cart in carts) {
            if (cart["product_id"] == product['product_id']) {
              product["quantity"] = cart["quantity"] ?? 0;
              product["totalamount"] = cart["totalamount"] ?? 0.0;
              updateCart = true;
              break;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "";
    });
    if (role == 'user') {
      getReportSubjects();
    }
  }

  getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartsJson = prefs.getString("carts");
    if (cartsJson != null) {
      setState(() {
        List jsonData = jsonDecode(cartsJson) ?? [];
        for (var product in jsonData) {
          carts.add(product);
        }
      });
    }
  }

  getBuyerProtections() async {
    try {
      final response = await buyerProtectionService.getBuyerProtectionsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          buyerProtections = response["data"];
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

  getReportSubjects() async {
    try {
      final response = await sellerReportService.getReportSubjectsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          reportSubjects = response["data"];

          for (var data in response["data"]) {
            if (data["description"] != null) {
              reportSubjectsDesc.add(data["description"]);
            }
          }
          reportSubjectId = reportSubjects[0]["subject_id"];
          reportSubjectDesc = reportSubjects[0]["description"];
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

  addSellerReport() async {
    try {
      final body = {
        "seller_id": product["creator_id"],
        "subject_id": reportSubjectId,
        "phone": '959${phone.text}',
        "message": message.text,
      };
      final response = await sellerReportService.addSellerReportData(body);
      Navigator.pop(context);
      if (response!["code"] == 201) {
        Navigator.pop(context);
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

  getSellerInformation(id) async {
    try {
      final response = await userService.getSellerInformationData(id);
      if (response!["code"] == 200) {
        sellerinfo = response["data"];
        setState(() {});
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

  getChatSession() async {
    ChatsProvider chatProvider =
        Provider.of<ChatsProvider>(context, listen: false);
    chatProvider.setChats([]);
    try {
      final response = await chatService.getChatSessionData(
          receiverId: product["creator_id"]);
      if (response!["code"] == 200) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.chat,
          arguments: {
            'receiver_id': product["creator_id"],
            'chat_name': sellerinfo["seller_name"],
            'profile_image': sellerinfo["seller_profile_image"],
            'user_id': product["creator_id"],
            'from': 'product',
          },
          (route) => true,
        );
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
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.chat,
            arguments: {
              'receiver_id': product["creator_id"],
              'chat_name': sellerinfo["seller_name"],
              'profile_image': sellerinfo["seller_profile_image"],
              'user_id': product["creator_id"],
              'from': 'product',
            },
            (route) => true,
          );
        }
      }
    }
  }

  Future<void> saveListToSharedPreferences(
      List<Map<String, dynamic>> datalist) async {
    final prefs = await SharedPreferences.getInstance();
    const key = "carts";

    final jsonData = jsonEncode(datalist);

    await prefs.setString(key, jsonData);
  }

  clearReportDialog() {
    phone.text = '';
    message.text = '';
    reportSubjectId = reportSubjects[0]["subject_id"];
    reportSubjectDesc = reportSubjects[0]["description"];
  }

  showReportDialog() async {
    clearReportDialog();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _phoneFocusNode.unfocus();
                _messageFocusNode.unfocus();
              },
              child: Form(
                key: _formKey,
                child: AlertDialog(
                  backgroundColor: Colors.white,
                  titlePadding: EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                        ),
                        child: Text(
                          language["Report Listing"] ?? "Report Listing",
                          style: FontConstants.subheadline1,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 24,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
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
                          bottom: 16,
                        ),
                        child: TextFormField(
                          controller: phone,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          style: FontConstants.body1,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            prefixText: '+959',
                            prefixStyle: FontConstants.body2,
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
                          bottom: 4,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            language["Subject"] ?? "Subject",
                            style: FontConstants.caption1,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: CustomDropDown(
                          value: reportSubjectDesc,
                          fillColor: ColorConstants.fillcolor,
                          onChanged: (newValue) {
                            setState(() {
                              reportSubjectDesc =
                                  newValue ?? reportSubjectsDesc[0];
                            });
                            for (var data in reportSubjects) {
                              if (data["description"] == reportSubjectDesc) {
                                reportSubjectId = data["subject_id"];
                              }
                            }
                          },
                          items: reportSubjectsDesc,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 4,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            language["Message"] ?? "Message",
                            style: FontConstants.caption1,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: TextFormField(
                          controller: message,
                          focusNode: _messageFocusNode,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          style: FontConstants.body1,
                          cursorColor: Colors.black,
                          maxLines: 2,
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
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      width: double.infinity,
                      child: TextButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColor),
                        ),
                        child: Text(
                          language["Submit message"] ?? "Submit message",
                          style: FontConstants.button1,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            showLoadingDialog(context);
                            addSellerReport();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          language["Details"] ?? "Details",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 24,
          ),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 12,
                  right: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 400,
                        child: Column(
                          children: [
                            product.containsKey("product_images") &&
                                    product["product_images"].isNotEmpty
                                ? Expanded(
                                    child: PageView.builder(
                                      scrollDirection: Axis.horizontal,
                                      controller: _imageController,
                                      itemCount:
                                          product["product_images"].length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, Routes.image_preview,
                                                arguments: {
                                                  "image_url":
                                                      '${ApiConstants.baseUrl}${product["product_images"][index].toString()}'
                                                });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              image: product["product_images"]
                                                          [index] !=
                                                      ""
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                          '${ApiConstants.baseUrl}${product["product_images"][index].toString()}'),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/logo.png'),
                                                      fit: BoxFit.cover,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Container(),
                            product.containsKey("product_images") &&
                                    product["product_images"].isNotEmpty
                                ? DotsIndicator(
                                    dotsCount: product["product_images"].length,
                                    position: _currentPage.toInt(),
                                    decorator: DotsDecorator(
                                      size: Size.square(8),
                                      activeSize: Size(20, 16),
                                      color: Colors.grey,
                                      activeColor:
                                          Theme.of(context).primaryColorDark,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                      ),
                      child: Text(
                        product["brand_name"] ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: FontConstants.headline1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          product["model"] ?? "",
                          style: FontConstants.body2,
                        ),
                      ),
                    ),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            language["Description"] ?? "Description",
                            style: FontConstants.body1,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                product["description"] ?? "",
                                style: FontConstants.caption1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            language["Specifications"] ?? "Specifications",
                            style: FontConstants.body1,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Gender"] ?? "Gender",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["gender_description"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Color"] ?? "Color",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["color"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Strap Material"] ??
                                      "Strap Material",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["strap_material"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Strap Color"] ?? "Strap Color",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["strap_color"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Case Material"] ?? "Case Material",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["case_material"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Case Diameter"] ?? "Case Diameter",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["case_diameter"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Case Depth"] ?? "Case Depth",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["case_depth"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Case Width"] ?? "Case Width",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["case_width"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Dial Glass Type"] ??
                                      "Dial Glass Type",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["dial_glass_type_description"] ??
                                        "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Dial Color"] ?? "Dial Color",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["dial_color"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Condition"] ?? "Condition",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["condition"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Movement Country"] ??
                                      "Movement Country",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["movement_country"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Movement Type"] ?? "Movement Type",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["movement_type"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Movement Caliber"] ??
                                      "Movement Caliber",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["movement_caliber"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Water Resistance"] ??
                                      "Water Resistance",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["water_resistance"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Warranty Period"] ??
                                      "Warranty Period",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["warranty_period"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Warranty Type"] ?? "Warranty Type",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["warranty_type_description"] ?? "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language["Other Accessories"] ??
                                      "Other Accessories",
                                  style: FontConstants.caption1,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    product["other_accessories_type_description"] ??
                                        "",
                                    textAlign: TextAlign.end,
                                    style: FontConstants.caption2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          product.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        language["Preorder"] ?? "Preorder",
                                        style: FontConstants.caption1,
                                      ),
                                      Expanded(
                                        child: Text(
                                          product["is_preorder"] ? 'Yes' : 'No',
                                          textAlign: TextAlign.end,
                                          style: FontConstants.caption2,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          product.isNotEmpty && product["is_preorder"]
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        language["Waiting Time"] ??
                                            "Waiting Time",
                                        style: FontConstants.caption1,
                                      ),
                                      Text(
                                        product["waiting_time"] ?? "",
                                        style: FontConstants.caption2,
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.withOpacity(0.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            language[
                                    "Watch Vault by Diggie Buyer Protection"] ??
                                "Watch Vault by Diggie Buyer Protection",
                            style: FontConstants.headline1,
                          ),
                        ),
                        SvgPicture.asset(
                          "assets/icons/shield_mark.svg",
                          width: 32,
                          height: 32,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: buyerProtections.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.done,
                                  color: Colors.green,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    buyerProtections[index]["description"],
                                    style: FontConstants.body1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              sellerinfo.isNotEmpty
                  ? Container(
                      margin: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 24,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  language["Seller"] ?? "Seller",
                                  overflow: TextOverflow.ellipsis,
                                  style: FontConstants.headline1,
                                ),
                              ),
                              Container(
                                width: 37,
                                height: 37,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                child: IconButton(
                                  icon: SvgPicture.asset(
                                    "assets/icons/message.svg",
                                    width: 24,
                                    height: 24,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (role.isNotEmpty) {
                                      getChatSession();
                                    } else {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        Routes.login,
                                        (route) => true,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            sellerinfo["company_name"] ?? "",
                            style: FontConstants.subheadline1,
                          ),
                          Text(
                            sellerinfo["professional_title"] ?? "",
                            style: FontConstants.body2,
                          ),
                          Text(
                            "${language["Active on Watch Vault by Diggie"] ?? "Active on Watch Vault by Diggie"}: ${sellerinfo["active_since_year"]}",
                            style: FontConstants.body2,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/tags.svg",
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      language["Sales"] ?? "Sales",
                                      style: FontConstants.subheadline1,
                                    ),
                                    Text(
                                      "${language["Watches sold on Watch Vault by Diggie"] ?? "Watches sold on Watch Vault by Diggie"}: ${sellerinfo["sold_product_counts"]}",
                                      style: FontConstants.body2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/trusted.svg",
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      language[
                                              "Watch Vault by Diggie Trusted Seller"] ??
                                          "Watch Vault by Diggie Trusted Seller",
                                      style: FontConstants.subheadline1,
                                    ),
                                    Text(
                                      "${language["Trusted Seller since"] ?? "Trusted Seller since"} ${sellerinfo["active_since_year"]}",
                                      style: FontConstants.body2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/map.svg",
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      language["Location"] ?? "Location",
                                      style: FontConstants.subheadline1,
                                    ),
                                    Text(
                                      "${sellerinfo["location"]}",
                                      style: FontConstants.body2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/product.svg",
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      language["Listings"] ?? "Listings",
                                      style: FontConstants.subheadline1,
                                    ),
                                    Text(
                                      "${language["Watches listed on Watch Vault by Diggie"] ?? "Watches listed on Watch Vault by Diggie"}: ${sellerinfo["product_counts"]}",
                                      style: FontConstants.body2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          sellerinfo.isNotEmpty && sellerinfo["offline_trader"]
                              ? SizedBox(
                                  height: 16,
                                )
                              : Container(),
                          sellerinfo.isNotEmpty && sellerinfo["offline_trader"]
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4,
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/icons/shop.svg",
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            language["Offline trader"] ??
                                                "Offline trader",
                                            style: FontConstants.subheadline1,
                                          ),
                                          Text(
                                            language[
                                                    "This seller has a retail location"] ??
                                                "This seller has a retail location",
                                            style: FontConstants.body2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          reportSubjects.isNotEmpty
                              ? SizedBox(
                                  height: 16,
                                )
                              : Container(),
                          reportSubjects.isNotEmpty
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/report.svg",
                                      width: 24,
                                      height: 24,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showReportDialog();
                                      },
                                      child: Text(
                                        language["Report Listing"] ??
                                            "Report Listing",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product.isNotEmpty && product["discount_percent"] > 0.0)
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          product["symbol"].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        product["price"] != null
                            ? FormattedAmount(
                                amount:
                                    double.parse(product["price"].toString()),
                                mainTextStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                decimalTextStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              )
                            : Text(""),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        left: 16,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: ColorConstants.orangecolor,
                      ),
                      child: Center(
                        child: Text(
                          language["Price dropped!"] ?? "Price dropped!",
                          textAlign: TextAlign.center,
                          style: FontConstants.body3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 8,
                top: product.isNotEmpty && product["discount_percent"] > 0.0
                    ? 0
                    : 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        product["symbol"].toString(),
                        style: FontConstants.subheadline1,
                      ),
                      product["discounted_price"] != null
                          ? FormattedAmount(
                              amount: double.parse(
                                  product["discounted_price"].toString()),
                              mainTextStyle: FontConstants.subheadline1,
                              decimalTextStyle: FontConstants.subheadline1,
                            )
                          : Text(""),
                    ],
                  ),
                  if (product.isNotEmpty && product["discount_percent"] > 0.0)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                      ),
                      child: Text(
                        "You save ${product["discount_percent"]} %",
                        style: FontConstants.subheadline2,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          border: Border.all(
                            color: Theme.of(context).primaryColorLight,
                            width: 1,
                          ),
                        ),
                        width: 32,
                        height: 32,
                        child: IconButton(
                          icon: Icon(
                            Icons.remove,
                            size: 15,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            if (product['quantity'] > 0) {
                              setState(() {
                                product['quantity']--;
                                product['totalamount'] =
                                    double.parse(product["price"].toString()) *
                                        product['quantity'];
                              });
                            }
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColorLight,
                            width: 1,
                          ),
                        ),
                        height: 32,
                        child: Center(
                          child: Text(
                            product['quantity'].toString(),
                            textAlign: TextAlign.center,
                            style: FontConstants.subheadline1,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          border: Border.all(
                            color: Theme.of(context).primaryColorLight,
                            width: 1,
                          ),
                        ),
                        width: 32,
                        height: 32,
                        child: IconButton(
                          icon: Icon(
                            Icons.add,
                            size: 15,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            if (product['quantity'] <
                                int.parse(
                                    product["stock_quantity"].toString())) {
                              setState(() {
                                product['quantity']++;
                                product['totalamount'] =
                                    double.parse(product["price"].toString()) *
                                        product['quantity'];
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: product.isNotEmpty &&
                              int.parse(product["stock_quantity"].toString()) <
                                  1
                          ? ColorConstants.redcolor
                          : ColorConstants.greencolor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Center(
                          child: Text(
                            product.isNotEmpty &&
                                    int.parse(product["stock_quantity"]
                                            .toString()) <
                                        1
                                ? language["Out of Stock"] ?? "Out of Stock"
                                : language["In Stock"] ?? "In Stock",
                            textAlign: TextAlign.center,
                            style: FontConstants.body3,
                          ),
                        ),
                        if (product.isNotEmpty &&
                            int.parse(product["stock_quantity"].toString()) > 0)
                          Center(
                            child: Text(
                              ": ${product["stock_quantity"]} left",
                              textAlign: TextAlign.center,
                              style: FontConstants.caption4,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 4,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  language["Total Amount"] ?? "Total Amount",
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
              child: Align(
                alignment: Alignment.center,
                child: product["totalamount"] != null
                    ? FormattedAmount(
                        amount: product['totalamount'],
                        mainTextStyle: FontConstants.headline1,
                        decimalTextStyle: FontConstants.headline1,
                      )
                    : Text(""),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 4,
              ),
              child: Divider(
                height: 0,
                thickness: 1,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    child: Container(
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
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 0.5,
                          ),
                        ),
                        onPressed: () async {
                          if (product['quantity'] <= 0) {
                            ToastUtil.showToast(
                                0,
                                language["Choose Quantity"] ??
                                    "Choose Quantity");
                            return;
                          }
                          if (carts.isNotEmpty) {
                            if (product['shop_id'] != carts[0]['shop_id']) {
                              ToastUtil.showToast(
                                  0,
                                  language[
                                          "You can only order items from one shop at a time. Please place separate orders for items from different shops!"] ??
                                      "You can only order items from one shop at a time. Please place separate orders for items from different shops!");
                              return;
                            }
                            if (product['currency_id'] !=
                                carts[0]['currency_id']) {
                              ToastUtil.showToast(
                                  0,
                                  language[
                                          "You can only order items with the same currency at a time. Please place separate orders for items with different currencies!"] ??
                                      "You can only order items with the same currency at a time. Please place separate orders for items with different currencies!");
                              return;
                            }
                          }
                          if (updateCart) {
                            for (var cart in carts) {
                              if (cart["product_id"] == product["product_id"]) {
                                cart["quantity"] = product["quantity"] ?? 0;
                                cart["totalamount"] =
                                    product["totalamount"] ?? 0.0;
                                break;
                              }
                            }
                          } else {
                            carts.add(product);
                          }

                          saveListToSharedPreferences(carts);

                          CartProvider cartProvider =
                              Provider.of<CartProvider>(context, listen: false);
                          cartProvider.addCount(carts.length);

                          Navigator.pop(context);
                        },
                        child: Text(
                          language["Add to cart"] ?? "Add to cart",
                          style: FontConstants.button2,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    child: Container(
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
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: () async {
                          if (product['quantity'] <= 0) {
                            ToastUtil.showToast(
                                0,
                                language["Choose Quantity"] ??
                                    "Choose Quantity");
                            return;
                          }
                          if (carts.isNotEmpty) {
                            if (product['shop_id'] != carts[0]['shop_id']) {
                              ToastUtil.showToast(
                                  0,
                                  language[
                                          "You can only order items from one shop at a time. Please place separate orders for items from different shops!"] ??
                                      "You can only order items from one shop at a time. Please place separate orders for items from different shops!");
                              return;
                            }
                            if (product['currency_id'] !=
                                carts[0]['currency_id']) {
                              ToastUtil.showToast(
                                  0,
                                  language[
                                          "You can only order items with the same currency at a time. Please place separate orders for items with different currencies!"] ??
                                      "You can only order items with the same currency at a time. Please place separate orders for items with different currencies!");
                              return;
                            }
                          }
                          if (updateCart) {
                            for (var cart in carts) {
                              if (cart["product_id"] == product["product_id"]) {
                                cart["quantity"] = product["quantity"] ?? 0;
                                cart["totalamount"] =
                                    product["totalamount"] ?? 0.0;
                                break;
                              }
                            }
                          } else {
                            carts.add(product);
                          }

                          saveListToSharedPreferences(carts);

                          CartProvider cartProvider =
                              Provider.of<CartProvider>(context, listen: false);
                          cartProvider.addCount(carts.length);

                          BottomProvider bottomProvider =
                              Provider.of<BottomProvider>(context,
                                  listen: false);
                          bottomProvider.selectIndex(1);

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.cart,
                            (route) => false,
                          );
                        },
                        child: Text(
                          language["Buy Now"] ?? "Buy Now",
                          style: FontConstants.button1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
