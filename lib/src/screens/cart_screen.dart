import 'dart:convert';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
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
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> carts = [];
  double subtotal = 0.0;
  double total = 0.0;
  String role = '';

  @override
  void initState() {
    super.initState();
    getData();
    getCart();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role') ?? "";
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
        calculateSubTotal();
      });
    }
  }

  Future<void> saveListToSharedPreferences(
      List<Map<String, dynamic>> datalist) async {
    final prefs = await SharedPreferences.getInstance();
    const key = "carts";

    final jsonData = jsonEncode(datalist);

    await prefs.setString(key, jsonData);
    setState(() {});
  }

  void calculateSubTotal() {
    subtotal = 0.0;
    total = 0.0;
    for (Map<String, dynamic> cart in carts) {
      subtotal += cart["totalamount"];
    }
    total = subtotal;
    setState(() {});
  }

  Widget _buildSummaryItem(String title, String amount,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: FontConstants.subheadline2,
        ),
        amount == "--"
            ? Text(
                amount,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            language["Cart"] ?? "Cart",
            style: FontConstants.title2,
          ),
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
                    role.isEmpty
                        ? Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.login,
                            (route) => true,
                          )
                        : Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.order,
                            arguments: {
                              "carts": carts,
                              "subtotal": subtotal,
                              "total": total,
                            },
                            (route) => true,
                          );
                  },
                )
              : Container(),
        ],
      ),
      body: carts.isNotEmpty
          ? Column(
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
                              Slidable(
                                key: const ValueKey(0),
                                endActionPane: ActionPane(
                                  motion: const BehindMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (BuildContext context) {
                                        CartProvider cartProvider =
                                            Provider.of<CartProvider>(context,
                                                listen: false);
                                        cartProvider
                                            .addCount(cartProvider.count - 1);

                                        carts.removeAt(index);
                                        saveListToSharedPreferences(carts);
                                      },
                                      backgroundColor: ColorConstants.redcolor,
                                      foregroundColor: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(
                                            index == 0 ? 10 : 0),
                                        bottomRight: Radius.circular(
                                            index == carts.length - 1 ? 10 : 0),
                                      ),
                                      icon: Icons.delete,
                                      label: language["Delete"] ?? "Delete",
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.baseline,
                                                textBaseline:
                                                    TextBaseline.alphabetic,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      carts[index]
                                                              ["brand_name"] ??
                                                          "",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          FontConstants.body1,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .baseline,
                                                    textBaseline:
                                                        TextBaseline.alphabetic,
                                                    children: [
                                                      Text(
                                                        carts[index]
                                                                ["symbol"] ??
                                                            "",
                                                        style: FontConstants
                                                            .subheadline1,
                                                      ),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      carts[index][
                                                                  "totalamount"] !=
                                                              null
                                                          ? FormattedAmount(
                                                              amount: double.parse(carts[
                                                                          index]
                                                                      [
                                                                      "totalamount"]
                                                                  .toString()),
                                                              mainTextStyle:
                                                                  FontConstants
                                                                      .subheadline1,
                                                              decimalTextStyle:
                                                                  FontConstants
                                                                      .caption3,
                                                            )
                                                          : Text(""),
                                                    ],
                                                  ),
                                                ],
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
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(8),
                                                        bottomLeft:
                                                            Radius.circular(8),
                                                      ),
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColorLight,
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
                                                        if (carts[index]
                                                                ['quantity'] >
                                                            1) {
                                                          carts[index]
                                                              ['quantity']--;
                                                          carts[index][
                                                              'totalamount'] = double
                                                                  .parse(carts[
                                                                              index]
                                                                          [
                                                                          "price"]
                                                                      .toString()) *
                                                              carts[index]
                                                                  ['quantity'];
                                                        } else {
                                                          CartProvider
                                                              cartProvider =
                                                              Provider.of<
                                                                      CartProvider>(
                                                                  context,
                                                                  listen:
                                                                      false);
                                                          cartProvider.addCount(
                                                              cartProvider
                                                                      .count -
                                                                  1);

                                                          carts.removeAt(index);
                                                        }
                                                        calculateSubTotal();
                                                        saveListToSharedPreferences(
                                                            carts);
                                                      },
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColorLight,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    height: 32,
                                                    child: Center(
                                                      child: Text(
                                                        carts[index]['quantity']
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: FontConstants
                                                            .subheadline1,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(8),
                                                        bottomRight:
                                                            Radius.circular(8),
                                                      ),
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColorLight,
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
                                                        if (carts[index]
                                                                ['quantity'] <
                                                            int.parse(carts[
                                                                        index][
                                                                    "stock_quantity"]
                                                                .toString())) {
                                                          carts[index]
                                                              ['quantity']++;
                                                          carts[index][
                                                              'totalamount'] = double
                                                                  .parse(carts[
                                                                              index]
                                                                          [
                                                                          "price"]
                                                                      .toString()) *
                                                              carts[index]
                                                                  ['quantity'];
                                                          calculateSubTotal();
                                                          saveListToSharedPreferences(
                                                              carts);
                                                        }
                                                      },
                                                    ),
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
                  )),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                  padding: const EdgeInsets.all(
                    16,
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
                      Divider(
                        thickness: 1.5,
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
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/cart.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    color: Theme.of(context).primaryColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 10,
                    ),
                    child: Text(
                      "Empty Cart",
                      textAlign: TextAlign.center,
                      style: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? FontConstants.title1
                          : FontConstants.title2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: Text(
                      "Looks like you haven't made your choice yet...",
                      textAlign: TextAlign.center,
                      style: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? FontConstants.caption1
                          : FontConstants.subheadline2,
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
