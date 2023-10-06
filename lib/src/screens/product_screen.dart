import 'dart:convert';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
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
  ScrollController _detailsController = ScrollController();
  final PageController _imageController = PageController();
  List<Map<String, dynamic>> carts = [];
  Map<String, dynamic> product = {};
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
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
          product['quantity'] = product['quantity'] ?? 0;
          product['totalamount'] = product['totalamount'] ?? 0.0;
        });
        getCart();
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
        controller: _detailsController,
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 24,
          ),
          width: double.infinity,
          height: MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                              image: DecorationImage(
                                // image: NetworkImage(
                                //     '${ApiConstants.baseUrl}${product["product_images"][index].toString()}'),
                                image: AssetImage("assets/images/watch.png"),
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.circular(10),
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
                        size: Size.square(10),
                        activeSize: Size(16, 20),
                        color: Colors.grey,
                        activeColor: Theme.of(context).primaryColorDark,
                      ),
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  right: 4,
                  top: 16,
                  bottom: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      product["brand_name"] ?? "",
                      style: FontConstants.subheadline1,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      '(${product["model"]})',
                      style: FontConstants.body2,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 4,
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
                                child: Text(
                                  product['quantity'].toString(),
                                  textAlign: TextAlign.center,
                                  style: FontConstants.subheadline1,
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
                                    if (product['quantity'] <
                                        int.parse(product["stock_quantity"]
                                            .toString())) {
                                      setState(() {
                                        product['quantity']++;
                                        product['totalamount'] = double.parse(
                                                product["price"].toString()) *
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
              carts.add(product);
              saveListToSharedPreferences(carts);

              CartProvider cartProvider =
                  Provider.of<CartProvider>(context, listen: false);
              cartProvider.addCount(carts.length);

              Navigator.pop(context);
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
