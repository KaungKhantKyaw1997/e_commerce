import 'dart:convert';

import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController _cartController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  TextEditingController address = TextEditingController(text: '');
  List<Map<String, dynamic>> carts = [];

  @override
  void initState() {
    super.initState();
    getCart();
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

  void _showOrderBottomSheet(BuildContext context) {
    address.text = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Form(
          key: _formKey,
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
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 24,
                  ),
                  child: TextFormField(
                    controller: address,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    style: FontConstants.body1,
                    cursorColor: Colors.black,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: language["Address"] ?? "Address",
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
                        return language["Enter Address"] ?? "Enter Address";
                      }
                      return null;
                    },
                  ),
                ),
                Container(
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
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      language["Order"] ?? "Order",
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
  }

  Future<void> saveListToSharedPreferences(
      List<Map<String, dynamic>> datalist) async {
    final prefs = await SharedPreferences.getInstance();
    const key = "carts";

    final jsonData = jsonEncode(datalist);

    await prefs.setString(key, jsonData);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          language["Cart"] ?? "Cart",
          style: FontConstants.title1,
        ),
        actions: [
          carts.isNotEmpty
              ? IconButton(
                  icon: SvgPicture.asset(
                    "assets/icons/check.svg",
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    _showOrderBottomSheet(context);
                  },
                )
              : Container(),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
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
                controller: _cartController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: carts.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slidable(
                        key: const ValueKey(0),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) {
                                Navigator.pushNamed(
                                  context,
                                  Routes.product,
                                  arguments: carts[index],
                                );
                              },
                              backgroundColor: const Color(0xFF33A031),
                              foregroundColor: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(index == 0 ? 10 : 0),
                                bottomLeft: Radius.circular(
                                    index == carts.length - 1 ? 10 : 0),
                              ),
                              icon: Icons.update,
                              label: 'Update',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) {
                                CartProvider cartProvider =
                                    Provider.of<CartProvider>(context,
                                        listen: false);
                                cartProvider.addCount(cartProvider.count - 1);

                                carts.removeAt(index);
                                saveListToSharedPreferences(carts);
                              },
                              backgroundColor: const Color(0xFFE3200F),
                              foregroundColor: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(index == 0 ? 10 : 0),
                                bottomRight: Radius.circular(
                                    index == carts.length - 1 ? 10 : 0),
                              ),
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Container(
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
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        AssetImage(carts[index]["image_url"]),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    left: 4,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${carts[index]["name"].toString()} x ${carts[index]["qty"].toString()}',
                                        style: FontConstants.body1,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 14,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  language["Amount"] ??
                                                      "Amount",
                                                  style: FontConstants.caption1,
                                                ),
                                                FormattedAmount(
                                                  amount: double.parse(
                                                      carts[index]["price"]
                                                          .toString()),
                                                  mainTextStyle: FontConstants
                                                      .subheadline1,
                                                  decimalTextStyle:
                                                      FontConstants.caption3,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  language["Total Amount"] ??
                                                      "Total Amount",
                                                  style: FontConstants.caption1,
                                                ),
                                                FormattedAmount(
                                                  amount: double.parse(
                                                          carts[index]["price"]
                                                              .toString()) *
                                                      double.parse(carts[index]
                                                              ["qty"]
                                                          .toString()),
                                                  mainTextStyle: FontConstants
                                                      .subheadline1,
                                                  decimalTextStyle:
                                                      FontConstants.caption3,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      index < carts.length - 1
                          ? Container(
                              padding: const EdgeInsets.only(
                                left: 16,
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
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
