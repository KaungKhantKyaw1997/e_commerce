import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/orders_service.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderConfirmScreen extends StatefulWidget {
  const OrderConfirmScreen({super.key});

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  final ScrollController _scrollController = ScrollController();
  final orderService = OrderService();
  Object address = {};
  List<Map<String, dynamic>> carts = [];
  String paymenttype = '';
  XFile? pickedFile;
  String payslipImage = '';
  String insurancetype = 'No Insurance';
  double subtotal = 0.0;
  double commissionAmount = 0.0;
  double total = 0.0;
  int ruleId = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        address = arguments["address"] ?? {};
        carts = arguments["carts"] ?? [];
        paymenttype = arguments["paymenttype"] ?? '';
        pickedFile = arguments["pickedFile"] ?? null;
        insurancetype = arguments["insurancetype"] ?? 'No Insurance';
        subtotal = arguments["subtotal"] ?? 0.0;
        commissionAmount = arguments["commissionAmount"] ?? 0.0;
        total = arguments["total"] ?? 0.0;
        ruleId = arguments["ruleId"] ?? 0;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // orderService.cancelRequest();
    super.dispose();
  }

  createOrder() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> orderItems = carts.map((cartItem) {
      return {
        'product_id': cartItem['product_id'],
        'quantity': cartItem['quantity'],
      };
    }).toList();

    int shopId = carts[0]["shop_id"];

    try {
      final body = {
        "shop_id": shopId,
        "order_items": orderItems,
        "address": address,
        "payment_type": paymenttype,
        "payslip_screenshot_path": payslipImage,
        if (ruleId != 0) "rule_id": ruleId,
      };
      final response = await orderService.addOrderData(body);
      Navigator.pop(context);
      if (response["code"] == 200) {
        CartProvider cartProvider =
            Provider.of<CartProvider>(context, listen: false);
        cartProvider.addCount(0);

        carts = [];
        prefs.remove("carts");

        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.success,
          arguments: {
            "id": response["data"],
            "shopId": shopId,
            "isAlreadyReviewed": response["is_already_reviewed"],
          },
        );
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
    }
  }

  Future<void> uploadFile() async {
    try {
      var response = await AuthService.uploadFile(File(pickedFile!.path));
      var res = jsonDecode(response.body);
      if (res["code"] == 200) {
        payslipImage = res["url"];
      }
    } catch (error) {
      print('Error uploading file: $error');
    }
  }

  Widget _buildSummaryItem(String title, String amount,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: FontConstants.subheadline2,
          ),
          amount == "--"
              ? Text(
                  amount,
                  style: FontConstants.subheadline2,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    carts.isNotEmpty
                        ? Text(
                            carts[0]["symbol"] ?? "",
                            style: FontConstants.subheadline1,
                          )
                        : Text(''),
                    SizedBox(
                      width: 4,
                    ),
                    FormattedAmount(
                      amount: double.parse(amount),
                      mainTextStyle: FontConstants.subheadline1,
                      decimalTextStyle: FontConstants.caption2,
                    ),
                  ],
                ),
        ],
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
          language["Order"] ?? "Order",
          style: FontConstants.title1,
        ),
        leading: BackButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          return true;
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: carts.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 75,
                                    height: 75,
                                    decoration: BoxDecoration(
                                      image: carts[index]["product_images"]
                                              .isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  '${ApiConstants.baseUrl}${carts[index]["product_images"][0].toString()}'),
                                              fit: BoxFit.cover,
                                            )
                                          : DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/logo.png'),
                                              fit: BoxFit.cover,
                                            ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        left: 15,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            carts[index]["brand_name"] ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            style: FontConstants.body1,
                                          ),
                                          Text(
                                            carts[index]["model"] ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            style: FontConstants.caption1,
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              Text(
                                                carts[index]["symbol"] ?? "",
                                                style:
                                                    FontConstants.subheadline1,
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              FormattedAmount(
                                                amount: double.parse(
                                                    carts[index]["totalamount"]
                                                        .toString()),
                                                mainTextStyle:
                                                    FontConstants.subheadline1,
                                                decimalTextStyle:
                                                    FontConstants.caption3,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            index < carts.length - 1
                                ? Container(
                                    padding: const EdgeInsets.only(
                                      left: 100,
                                      right: 16,
                                    ),
                                    child: const Divider(
                                      height: 0,
                                      color: Colors.grey,
                                    ),
                                  )
                                : Container(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 16,
              ),
              margin: const EdgeInsets.only(
                top: 8,
                bottom: 10,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryItem(
                    language['Subtotal'] ?? 'Subtotal',
                    subtotal.toString(),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  _buildSummaryItem(
                    language['Shipping'] ?? 'Shipping',
                    '--',
                  ),
                  insurancetype != 'No Insurance'
                      ? SizedBox(
                          height: 16,
                        )
                      : Container(),
                  insurancetype != 'No Insurance'
                      ? _buildSummaryItem(
                          language['Commission'] ?? 'Commission',
                          commissionAmount.toString(),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Divider(
                      thickness: 1.5,
                    ),
                  ),
                  _buildSummaryItem(
                    language['Total'] ?? 'Total',
                    total.toString(),
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
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
            backgroundColor: Theme.of(context).primaryColor,
          ),
          onPressed: () async {
            showLoadingDialog(context);
            if (paymenttype == 'Preorder') {
              await uploadFile();
            }
            createOrder();
          },
          child: Text(
            language["Confirm"] ?? "Confirm",
            style: FontConstants.button1,
          ),
        ),
      ),
    );
  }
}
