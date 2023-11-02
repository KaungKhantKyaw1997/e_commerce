import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:e_commerce/src/services/buyer_protections_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/user_service.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
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
  final buyerProtectionsService = BuyerProtectionsService();
  final userService = UserService();
  final PageController _imageController = PageController();
  List<Map<String, dynamic>> carts = [];
  Map<String, dynamic> product = {};
  Map<String, dynamic> sellerinfo = {};
  double _currentPage = 0;
  bool updateCart = false;
  List buyerProtections = [];

  @override
  void initState() {
    super.initState();
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
      final response = await buyerProtectionsService.getBuyerProtectionsData();
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

  Future<void> saveListToSharedPreferences(
      List<Map<String, dynamic>> datalist) async {
    final prefs = await SharedPreferences.getInstance();
    const key = "carts";

    final jsonData = jsonEncode(datalist);

    await prefs.setString(key, jsonData);
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
                                  language["In Stock"] ?? "In Stock",
                                  style: FontConstants.caption1,
                                ),
                                Expanded(
                                  child: Text(
                                    product["stock_quantity"].toString() ?? "",
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Seller",
                            style: FontConstants.headline1,
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
                            "Active on Watch Vault by Diggie: ${sellerinfo["active_since_year"]}" ??
                                "",
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
                                      "Sales",
                                      style: FontConstants.subheadline1,
                                    ),
                                    Text(
                                      "Watches sold on Watch Vault by Diggie: ${sellerinfo["sold_product_counts"]}",
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
                                      "Watch Vault by Diggie Trusted Seller",
                                      style: FontConstants.subheadline1,
                                    ),
                                    Text(
                                      "Trusted Seller since ${sellerinfo["active_since_year"]}",
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
                                      "Location",
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
                                      "Listings",
                                      style: FontConstants.subheadline1,
                                    ),
                                    Text(
                                      "Watches listed on Watch Vault by Diggie: ${sellerinfo["product_counts"]}",
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
                                            "Offline trader",
                                            style: FontConstants.subheadline1,
                                          ),
                                          Text(
                                            "This seller has a retail location",
                                            style: FontConstants.body2,
                                          ),
                                        ],
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
            Padding(
              padding: const EdgeInsets.all(
                16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      SizedBox(
                        width: 4,
                      ),
                      product["price"] != null
                          ? FormattedAmount(
                              amount: double.parse(product["price"].toString()),
                              mainTextStyle: FontConstants.subheadline1,
                              decimalTextStyle: FontConstants.caption3,
                            )
                          : Text(""),
                    ],
                  ),
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
                        decimalTextStyle: FontConstants.body1,
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

                          Navigator.pushNamed(
                            context,
                            Routes.cart,
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
