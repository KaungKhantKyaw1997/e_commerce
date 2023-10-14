import 'dart:convert';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  ScrollController _scrollController = ScrollController();
  final PageController _imageController = PageController();
  List<Map<String, dynamic>> carts = [];
  Map<String, dynamic> product = {};
  double _currentPage = 0;
  bool updateCart = false;

  @override
  void initState() {
    super.initState();
    getCart();
    _imageController.addListener(() {
      setState(() {
        _currentPage = _imageController.page ?? 0;
      });
    });
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        setState(() {
          product = arguments;
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          width: double.infinity,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 200,
                      child: Column(
                        children: [
                          product.containsKey("product_images") &&
                                  product["product_images"].isNotEmpty
                              ? Expanded(
                                  child: PageView.builder(
                                    scrollDirection: Axis.horizontal,
                                    controller: _imageController,
                                    itemCount: product["product_images"].length,
                                    itemBuilder: (context, index) {
                                      return Container(
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
                                                  fit: BoxFit.fill,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.transparent,
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
                                    activeSize: Size(12, 16),
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
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 4,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              product["brand_name"] ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: FontConstants.headline1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            bottom: 16,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              product["model"] ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: FontConstants.body2,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              product["description"] ?? "",
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: FontConstants.body1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 4,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          language["Specifications"] ?? "Specifications",
                          style: FontConstants.caption2,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                      ),
                      child: const Divider(
                        height: 0,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            language["Color"] ?? "Color",
                            style: FontConstants.caption1,
                          ),
                          Text(
                            product["color"] ?? "",
                            style: FontConstants.caption2,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            language["Strap Material"] ?? "Strap Material",
                            style: FontConstants.caption1,
                          ),
                          Text(
                            product["strap_material"] ?? "",
                            style: FontConstants.caption2,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            language["Strap Color"] ?? "Strap Color",
                            style: FontConstants.caption1,
                          ),
                          Text(
                            product["strap_color"] ?? "",
                            style: FontConstants.caption2,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            language["Case Material"] ?? "Case Material",
                            style: FontConstants.caption1,
                          ),
                          Text(
                            product["case_material"] ?? "",
                            style: FontConstants.caption2,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            language["Dial Color"] ?? "Dial Color",
                            style: FontConstants.caption1,
                          ),
                          Text(
                            product["dial_color"] ?? "",
                            style: FontConstants.caption2,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            language["Movement Type"] ?? "Movement Type",
                            style: FontConstants.caption1,
                          ),
                          Text(
                            product["movement_type"] ?? "",
                            style: FontConstants.caption2,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            language["Dimensions"] ?? "Dimensions",
                            style: FontConstants.caption1,
                          ),
                          Text(
                            product["dimensions"] ?? "",
                            style: FontConstants.caption2,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            language["Water Resistance"] ?? "Water Resistance",
                            style: FontConstants.caption1,
                          ),
                          Text(
                            product["water_resistance"] ?? "",
                            style: FontConstants.caption2,
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 0,
                      color: Colors.grey,
                    ),
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
                                "Ks",
                                style: FontConstants.subheadline1,
                              ),
                              product["price"] != null
                                  ? FormattedAmount(
                                      amount: double.parse(
                                          product["price"].toString()),
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
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    if (product['quantity'] > 0) {
                                      setState(() {
                                        product['quantity']--;
                                        product['totalamount'] = double.parse(
                                                product["price"].toString()) *
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
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 1,
                                  ),
                                ),
                                width: 50,
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
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    // if (product['quantity'] <
                                    //     int.parse(product["stock_quantity"]
                                    //         .toString())) {
                                    setState(() {
                                      product['quantity']++;
                                      product['totalamount'] = double.parse(
                                              product["price"].toString()) *
                                          product['quantity'];
                                    });
                                    // }
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
                  ],
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
            if (product['quantity'] > 0) {
              if (updateCart) {
                for (var cart in carts) {
                  if (cart["product_id"] == product["product_id"]) {
                    cart["quantity"] = product["quantity"] ?? 0;
                    cart["totalamount"] = product["totalamount"] ?? 0.0;
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
                  Provider.of<BottomProvider>(context, listen: false);
              bottomProvider.selectIndex(1);

              Navigator.pushNamed(context, Routes.cart);
            }
          },
          child: Text(
            language["Add to cart"] ?? "Add to cart",
            style: FontConstants.button1,
          ),
        ),
      ),
    );
  }
}
