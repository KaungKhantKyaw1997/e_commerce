import 'dart:convert';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemDetails extends StatefulWidget {
  const ItemDetails({super.key});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  ScrollController _detailsController = ScrollController();
  final PageController _imageController = PageController();
  List<Map<String, dynamic>> carts = [];
  Map<String, dynamic> item = {};
  double totalamount = 0;

  var images = [
    "assets/images/gshock1.png",
    "assets/images/gshock2.png",
    "assets/images/gshock3.png",
    "assets/images/gshock4.png",
  ];
  double _currentPage = 0;

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
          item = arguments;
          totalamount = double.parse(item["price"].toString()) *
              double.parse(item["qty"].toString());
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartsJson = prefs.getString("carts");
    if (cartsJson != null) {
      setState(() {
        List jsonData = jsonDecode(cartsJson) ?? [];
        for (var item in jsonData) {
          carts.add(item);
        }
      });
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
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        controller: _detailsController,
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
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
              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _imageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(images[index]),
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),
              DotsIndicator(
                dotsCount: images.length,
                position: _currentPage.toInt(),
                decorator: DotsDecorator(
                  size: Size.square(10),
                  activeSize: Size(16, 20),
                  color: Colors.grey,
                  activeColor: Theme.of(context).primaryColorDark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item["name"] ?? "",
                    style: FontConstants.subheadline1,
                  ),
                ),
              ),
              Container(
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
                          language["Information"] ?? "Information",
                          style: FontConstants.caption1,
                        ),
                      ),
                    ),
                    const Divider(
                      height: 0,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            language["Brand"] ?? "Brand",
                            style: FontConstants.caption1,
                          ),
                          Text(
                            item["brand"] ?? "",
                            style: FontConstants.caption2,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            language["Model Number"] ?? "Model Number",
                            style: FontConstants.caption1,
                          ),
                          Text(
                            item["model"] ?? "",
                            style: FontConstants.caption2,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
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
                              Text(
                                "Ks",
                                style: FontConstants.subheadline1,
                              ),
                              item["price"] != null
                                  ? FormattedAmount(
                                      amount: double.parse(
                                          item["price"].toString()),
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
                                    setState(() {
                                      if (int.parse(item["qty"]) > 0) {
                                        int qty = int.parse(item["qty"]);
                                        item["qty"] = (--qty).toString();
                                        totalamount = double.parse(
                                                item["price"].toString()) *
                                            double.parse(
                                                item["qty"].toString());
                                      }
                                    });
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
                                  item["qty"].toString(),
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
                                    setState(() {
                                      int qty = int.parse(item["qty"]);
                                      item["qty"] = (++qty).toString();
                                      totalamount = double.parse(
                                              item["price"].toString()) *
                                          double.parse(item["qty"].toString());
                                    });
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
                        bottom: 8,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: FormattedAmount(
                          amount: totalamount,
                          mainTextStyle: FontConstants.headline1,
                          decimalTextStyle: FontConstants.body1,
                        ),
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
            if (int.parse(item["qty"]) > 0) {
              carts.add(item);
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
