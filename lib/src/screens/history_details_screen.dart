import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/reason_type_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/order_service.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryDetailsScreen extends StatefulWidget {
  const HistoryDetailsScreen({super.key});

  @override
  State<HistoryDetailsScreen> createState() => _HistoryDetailsScreenState();
}

class _HistoryDetailsScreenState extends State<HistoryDetailsScreen> {
  final crashlytic = new CrashlyticsService();
  final orderService = OrderService();
  final reasonTypeService = ReasonTypeService();
  List<String> statuslist = [
    "Pending",
    "Processing",
    "Shipped",
    "Delivered",
    "Completed",
    "Cancelled",
    "Refunded",
    "Failed",
    "On Hold",
    "Backordered",
    "Returned"
  ];
  String role = "";
  String shopName = "";
  Map<String, dynamic> orderData = {
    "order_id": 0,
    "user_name": "",
    "phone": "",
    "email": "",
    "home_address": "",
    "street_address": "",
    "city": "",
    "state": "",
    "postal_code": "",
    "country": "",
    "township": "",
    "ward": "",
    "note": "",
    "status": "Pending",
    "order_total": 0.0,
    "item_counts": 0,
    "payment_type": "Cash on Delivery",
    "payslip_screenshot_path": "",
    "created_at": "",
    "commission_amount": 0.0,
    "symbol": "",
    "can_view_address": false,
  };
  List<Map<String, dynamic>> orderItems = [];
  TextEditingController comment = TextEditingController(text: '');
  FocusNode _commentFocusNode = FocusNode();
  List reasonTypes = [];
  List<String> reasonTypesDesc = [];
  int reasonTypeId = 0;
  String reasonTypeDesc = '';
  Map<String, dynamic> refundData = {};

  @override
  void initState() {
    super.initState();
    getData();
    getReasonTypes();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        getOrderDetails(arguments["order_id"]);
        getShopName(arguments["order_id"]);
        refundReason(arguments["order_id"]);
        setState(() {
          orderData = arguments;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "";
    });
  }

  getReasonTypes() async {
    try {
      final response = await reasonTypeService.getReasonTypesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          reasonTypes = response["data"];

          for (var data in response["data"]) {
            if (data["description"] != null) {
              reasonTypesDesc.add(data["description"]);
            }
          }
          reasonTypeId = reasonTypes[0]["reason_type_id"];
          reasonTypeDesc = reasonTypes[0]["description"];
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

  getOrderDetails(int order_id) async {
    try {
      final response = await orderService.getOrderDetailsData(order_id);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          orderItems = (response["data"] as List).cast<Map<String, dynamic>>();
        }
        setState(() {});
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

  getShopName(int order_id) async {
    try {
      final response = await orderService.getShopNameData(order_id);
      if (response!["code"] == 200) {
        shopName = response["data"] ?? "";
        setState(() {});
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

  refundReason(int order_id) async {
    try {
      final response = await orderService.refundReasonData(order_id);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          refundData = response["data"];
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
        }
      }
    }
  }

  updateOrder(status) async {
    showLoadingDialog(context);
    try {
      final body = {
        "status": status,
      };

      final response =
          await orderService.updateOrderData(orderData["order_id"], body);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        setState(() {
          orderData["status"] = status;
        });
        Navigator.pop(context);
        ToastUtil.showToast(response["code"], response["message"]);
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

  showProductReceiveDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          title: Text(
            language["Product Receive"] ?? "Product Receive",
            style: FontConstants.subheadline1,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          content: Text(
            language["Are you ready to receive the product?"] ??
                "Are you ready to receive the product?",
            style: FontConstants.caption2,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 4,
              ),
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: Text(
                  language["Cancel"] ?? "Cancel",
                  style: FontConstants.button2,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 4,
                right: 8,
              ),
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).primaryColor),
                ),
                child: Text(
                  language["Ok"] ?? "Ok",
                  style: FontConstants.button1,
                ),
                onPressed: () async {
                  updateOrder("Completed");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRefundReasonsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _commentFocusNode.unfocus();
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(
                        16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            language["Refund"] ?? "Refund",
                            style: FontConstants.subheadline1,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 22,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              reasonTypeId = reasonTypes[0]["reason_type_id"];
                              reasonTypeDesc = reasonTypes[0]["description"];
                              comment.text = '';
                            },
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
                        alignment: Alignment.centerLeft,
                        child: Text(
                          language["Reason"] ?? "Reason",
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
                        value: reasonTypeDesc,
                        fillColor: ColorConstants.fillcolor,
                        onChanged: (newValue) {
                          setState(() {
                            reasonTypeDesc = newValue ?? reasonTypesDesc[0];
                          });
                          for (var data in reasonTypes) {
                            if (data["description"] == reasonTypeDesc) {
                              reasonTypeId = data["reason_type_id"];
                            }
                          }
                        },
                        items: reasonTypesDesc,
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
                          language["Comment"] ?? "Comment",
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
                        controller: comment,
                        focusNode: _commentFocusNode,
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
                    Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 32,
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
                          Navigator.of(context).pop();
                          refundReasons();
                        },
                        child: Text(
                          language["Submit"] ?? "Submit",
                          style: FontConstants.button1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  refundReasons() async {
    showLoadingDialog(context);
    try {
      final body = {
        "order_id": orderData["order_id"],
        "reason_type_id": reasonTypeId,
        "comment": comment.text,
      };

      final response = await orderService.refundReasonsData(body);
      Navigator.pop(context);
      if (response!["code"] == 201) {
        setState(() {
          orderData["status"] = "Returned";
        });
        ToastUtil.showToast(response["code"], response["message"]);
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

  remindSeller() async {
    showLoadingDialog(context);
    try {
      final response =
          await orderService.remindSellerData(orderData["order_id"]);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
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
        title: Text(
          language["Track Order"] ?? "Track Order",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderData["created_at"].isEmpty
                      ? ""
                      : Jiffy.parseFromDateTime(
                              DateTime.parse(orderData["created_at"] + "Z")
                                  .toLocal())
                          .format(pattern: "dd MMM yyyy, hh:mm a"),
                  style: FontConstants.body1,
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${language["Order ID"] ?? "Order ID"}: #${orderData["order_id"]}',
                      style: FontConstants.body1,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          orderData['symbol'].toString(),
                          style: FontConstants.body1,
                        ),
                        FormattedAmount(
                          amount: orderData["order_total"],
                          mainTextStyle: FontConstants.body1,
                          decimalTextStyle: FontConstants.body1,
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${language["Commission"] ?? "Commission"}',
                      style: FontConstants.body1,
                    ),
                    FormattedAmount(
                      amount: orderData["commission_amount"],
                      mainTextStyle: FontConstants.body1,
                      decimalTextStyle: FontConstants.body1,
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${language["Payment Type"] ?? "Payment Type"}',
                      style: FontConstants.body1,
                    ),
                    Text(
                      "${orderData['payment_type']}",
                      style: FontConstants.body1,
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${language["Order Status"] ?? "Order Status"}',
                        style: FontConstants.body1,
                      ),
                    ),
                    Expanded(
                      child: role == 'admin'
                          ? CustomDropDown(
                              value: orderData['status'],
                              fillColor: Colors.white,
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  updateOrder(newValue);
                                }
                              },
                              items: statuslist,
                            )
                          : Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                orderData['status'],
                                style: FontConstants.body1,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              child: ListView(
                children: [
                  if (role == "admin" || role == "agent")
                    Container(
                      padding: const EdgeInsets.all(
                        16,
                      ),
                      margin: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.greenlightcolor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/profile.svg",
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                '${language["Order by"] ?? "Order by"}: ${orderData["user_name"]}',
                                style: FontConstants.subheadline3,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          GestureDetector(
                            onTap: () async {
                              String phoneNumber = orderData["phone"];
                              String uri = 'tel:+$phoneNumber';
                              await launchUrl(Uri.parse(uri));
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/phone.svg",
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "+" + orderData["phone"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          GestureDetector(
                            onTap: () async {
                              String emailAddress = orderData["email"];
                              String uri = 'mailto:+$emailAddress';
                              await launchUrl(Uri.parse(uri));
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/mailbox.svg",
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  orderData["email"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (shopName.isNotEmpty)
                            SizedBox(
                              height: 8,
                            ),
                          if (shopName.isNotEmpty)
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/shop.svg",
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  shopName,
                                  style: FontConstants.body3,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  if ((orderData["can_view_address"] && role == "agent") ||
                      (role == "admin" || role == "user"))
                    Container(
                      padding: const EdgeInsets.all(
                        10,
                      ),
                      margin: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.primarycolor,
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${language["Address"] ?? "Address"}',
                                style: FontConstants.caption4,
                              ),
                            ],
                          ),
                          Text(
                            '${language["Deliver to"] ?? "Deliver to"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            '${orderData["home_address"]}, ${orderData["street_address"]}, Ward ${orderData["ward"]}, ${orderData["township"]}',
                            style: FontConstants.body3,
                          ),
                          Text(
                            '${orderData["city"]}, ${orderData["state"]} ${orderData["postal_code"]}',
                            style: FontConstants.body3,
                          ),
                          Text(
                            '${orderData["country"]}',
                            style: FontConstants.body3,
                          ),
                        ],
                      ),
                    ),
                  if (refundData.isNotEmpty &&
                      (role == "admin" || role == "agent"))
                    Container(
                      padding: const EdgeInsets.all(
                        16,
                      ),
                      margin: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.redlightcolor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/profile.svg",
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                '${language["Refund by"] ?? "Refund by"}: ${refundData["customer_name"]}',
                                style: FontConstants.subheadline3,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/calendar.svg",
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                refundData["created_at"].isEmpty
                                    ? ""
                                    : Jiffy.parseFromDateTime(DateTime.parse(
                                                refundData["created_at"] + "Z")
                                            .toLocal())
                                        .format(
                                            pattern: "dd MMM yyyy, hh:mm a"),
                                style: FontConstants.body3,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/description.svg",
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                refundData["reason_type_description"],
                                style: FontConstants.body3,
                              ),
                            ],
                          ),
                          if (refundData["comment"].isNotEmpty)
                            SizedBox(
                              height: 8,
                            ),
                          if (refundData["comment"].isNotEmpty)
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/message.svg",
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  refundData["comment"],
                                  style: FontConstants.body3,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ...orderItems.map((item) {
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
                      child: ListTile(
                        leading: Image.network(
                          '${ApiConstants.baseUrl}${item["product_images"][0]}',
                          fit: BoxFit.cover,
                          height: 60,
                          width: 60,
                        ),
                        title: Text(
                          "${item["brand"]} ${item["model"]}",
                          style: FontConstants.subheadline1,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "${language["Quantity"] ?? "Quantity"}: ",
                                  style: FontConstants.body2,
                                ),
                                Text(
                                  "${item["quantity"]}",
                                  style: FontConstants.body1,
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "${language["Price"] ?? "Price"}: ",
                                  style: FontConstants.body2,
                                ),
                                FormattedAmount(
                                  amount: item["price"],
                                  mainTextStyle: FontConstants.body1,
                                  decimalTextStyle: FontConstants.body1,
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "${language["Amount"] ?? "Amount"}: ",
                                  style: FontConstants.body2,
                                ),
                                FormattedAmount(
                                  amount: item["amount"],
                                  mainTextStyle: FontConstants.body1,
                                  decimalTextStyle: FontConstants.body1,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  if (orderData["payment_type"] != "Cash on Delivery") ...[
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      '${language["Payslip"] ?? "Payslip"}',
                      style: FontConstants.headline1,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final url =
                            '${ApiConstants.baseUrl}${orderData["payslip_screenshot_path"]}';
                        await launchUrl(Uri.parse(url));
                      },
                      child: Image.network(
                        '${ApiConstants.baseUrl}${orderData["payslip_screenshot_path"]}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: role == 'user'
          ? Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 24,
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (orderData['status'] == 'Pending')
                    Container(
                      padding: const EdgeInsets.only(),
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
                          backgroundColor: ColorConstants.redcolor,
                        ),
                        onPressed: () async {
                          updateOrder("Cancelled");
                        },
                        child: Text(
                          language["Order Cancel"] ?? "Order Cancel",
                          style: FontConstants.button1,
                        ),
                      ),
                    ),
                  if (orderData['status'] == 'Delivered')
                    Container(
                      padding: const EdgeInsets.only(
                        top: 8,
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
                          showProductReceiveDialog();
                        },
                        child: Text(
                          language["Product Receive"] ?? "Product Receive",
                          style: FontConstants.button1,
                        ),
                      ),
                    ),
                  if (orderData['status'] == 'Completed')
                    Container(
                      padding: const EdgeInsets.only(
                        top: 8,
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
                          backgroundColor: ColorConstants.redlightcolor,
                        ),
                        onPressed: () async {
                          _showRefundReasonsBottomSheet(context);
                        },
                        child: Text(
                          language["Get Refund"] ?? "Get Refund",
                          style: FontConstants.button1,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.only(
                      top: 8,
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
                          color: ColorConstants.redcolor,
                          width: 0.5,
                        ),
                      ),
                      onPressed: () async {
                        remindSeller();
                      },
                      child: Text(
                        language["Remind Seller"] ?? "Remind Seller",
                        style: FontConstants.button3,
                      ),
                    ),
                  )
                ],
              ),
            )
          : null,
    );
  }
}
