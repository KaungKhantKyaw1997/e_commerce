import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
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
  TextEditingController comment = TextEditingController(text: '');
  FocusNode _commentFocusNode = FocusNode();
  int reasonTypeId = 0;
  Map<String, dynamic> details = {};
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
  };
  List<Map<String, dynamic>> orderItems = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getData();
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        getOrderDetails(arguments["order_id"]);
        getShopName(arguments["order_id"]);
        setState(() {
          orderData = arguments;
        });
      }
    });
  }

  @override
  void dispose() {
    // orderService.cancelRequest();
    super.dispose();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "";
    });
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

  refundReasons() async {
    showLoadingDialog(context);
    try {
      final body = {
        "order_id": orderData["order_id"],
        "reason_type_id": reasonTypeId,
        "comment": comment.text,
      };

      final response =
          await orderService.refundReasonsData(body);
      Navigator.pop(context);
      if (response!["code"] == 200) {
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
                  role == "admin" || role == "agent"
                      ? Container(
                          padding: const EdgeInsets.all(
                            16,
                          ),
                          margin: const EdgeInsets.only(
                            bottom: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xff36936C),
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
                              SizedBox(
                                height: 8,
                              ),
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
                        )
                      : Text(""),
                  role == "admin" || role == "user"
                      ? Container(
                          padding: const EdgeInsets.all(
                            10,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xff1f335a),
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
                        )
                      : Text(""),
                  SizedBox(
                    height: 8,
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
      bottomNavigationBar: role == 'user' && orderData['status'] == 'Pending'
          ? Container(
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
            )
          : role == 'user' && (orderData['status'] == 'Pending'|| orderData['status'] == 'Delivered'|| orderData['status'] == 'Completed')
          ? Container(
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
                  refundReasons();
                },
                child: Text(
                  language["Get Refund"] ?? "Get Refund",
                  style: FontConstants.button1,
                ),
              ),
            ):null,
    );
  }
}
