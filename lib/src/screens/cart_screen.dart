import 'dart:convert';

import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/services/orders_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
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
  final orderService = OrderService();
  FocusNode _countryFocusNode = FocusNode();
  FocusNode _cityFocusNode = FocusNode();
  FocusNode _stateFocusNode = FocusNode();
  FocusNode _townshipFocusNode = FocusNode();
  FocusNode _postalCodeFocusNode = FocusNode();
  FocusNode _houseNoFocusNode = FocusNode();
  FocusNode _streetFocusNode = FocusNode();
  FocusNode _wardFocusNode = FocusNode();
  FocusNode _noteFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  TextEditingController country = TextEditingController(text: '');
  TextEditingController city = TextEditingController(text: '');
  TextEditingController state = TextEditingController(text: '');
  TextEditingController township = TextEditingController(text: '');
  TextEditingController postalCode = TextEditingController(text: '');
  TextEditingController ward = TextEditingController(text: '');
  TextEditingController streetAddress = TextEditingController(text: '');
  TextEditingController homeAddress = TextEditingController(text: '');
  TextEditingController note = TextEditingController(text: '');
  List<Map<String, dynamic>> carts = [];

  @override
  void initState() {
    super.initState();
    getCart();
  }

  @override
  void dispose() {
    _cartController.dispose();
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

  createOrder() async {
    showLoadingDialog(context);
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> orderItems = carts.map((cartItem) {
      return {
        'product_id': cartItem['product_id'],
        'quantity': cartItem['quantity'],
      };
    }).toList();

    try {
      final body = {
        "order_items": orderItems,
        "address": {
          "street_address": streetAddress.text,
          "city": city.text,
          "state": state.text,
          "postal_code": postalCode.text,
          "country": country.text,
          "township": township.text,
          "ward": ward.text,
          "home_address": homeAddress.text,
          "note": note.text,
        },
      };
      final response = await orderService.createOrderData(body);
      if (response["code"] == 200) {
        CartProvider cartProvider =
            Provider.of<CartProvider>(context, listen: false);
        cartProvider.addCount(0);

        carts = [];
        prefs.remove("carts");

        Navigator.pushNamed(
          context,
          Routes.success,
        );
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
    }
  }

  void _showOrderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _countryFocusNode.unfocus();
            _cityFocusNode.unfocus();
            _stateFocusNode.unfocus();
            _townshipFocusNode.unfocus();
            _postalCodeFocusNode.unfocus();
            _houseNoFocusNode.unfocus();
            _streetFocusNode.unfocus();
            _wardFocusNode.unfocus();
            _noteFocusNode.unfocus();
          },
          child: Form(
            key: _formKey,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? MediaQuery.of(context).size.height - 10
                      : MediaQuery.of(context).size.height - 100,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 180,
                      right: 180,
                    ),
                    child: const Divider(
                      height: 0,
                      color: Colors.grey,
                      thickness: 4,
                    ),
                  ),
                  Expanded(
                    child: DraggableScrollableSheet(
                      initialChildSize: 1.0,
                      maxChildSize: 1.0,
                      minChildSize: 0.2,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return ListView(
                          controller: scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 4,
                                      top: 16,
                                      bottom: 8,
                                    ),
                                    child: TextFormField(
                                      controller: country,
                                      focusNode: _countryFocusNode,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: FontConstants.body1,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText:
                                            language["Country"] ?? "Country",
                                        filled: true,
                                        fillColor: ColorConstants.fillcolor,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return language["Enter Country"] ??
                                              "Enter Country";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      right: 16,
                                      top: 16,
                                      bottom: 8,
                                    ),
                                    child: TextFormField(
                                      controller: city,
                                      focusNode: _cityFocusNode,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: FontConstants.body1,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText: language["City"] ?? "City",
                                        filled: true,
                                        fillColor: ColorConstants.fillcolor,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return language["Enter City"] ??
                                              "Enter City";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 4,
                                      bottom: 8,
                                    ),
                                    child: TextFormField(
                                      controller: state,
                                      focusNode: _stateFocusNode,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: FontConstants.body1,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText: language["State"] ?? "State",
                                        filled: true,
                                        fillColor: ColorConstants.fillcolor,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return language["Enter State"] ??
                                              "Enter State";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      right: 4,
                                      bottom: 8,
                                    ),
                                    child: TextFormField(
                                      controller: township,
                                      focusNode: _townshipFocusNode,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: FontConstants.body1,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText:
                                            language["Township"] ?? "Township",
                                        filled: true,
                                        fillColor: ColorConstants.fillcolor,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return language["Enter Township"] ??
                                              "Enter Township";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 4,
                                      bottom: 8,
                                    ),
                                    child: TextFormField(
                                      controller: postalCode,
                                      focusNode: _postalCodeFocusNode,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: FontConstants.body1,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText: language["Postal Code"] ??
                                            "Postal Code",
                                        filled: true,
                                        fillColor: ColorConstants.fillcolor,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return language[
                                                  "Enter Postal Code"] ??
                                              "Enter Postal Code";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      right: 16,
                                      bottom: 8,
                                    ),
                                    child: TextFormField(
                                      controller: homeAddress,
                                      focusNode: _houseNoFocusNode,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: FontConstants.body1,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText: language["House No."] ??
                                            "House No.",
                                        filled: true,
                                        fillColor: ColorConstants.fillcolor,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return language["Enter House No."] ??
                                              "Enter House No.";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 4,
                                      bottom: 8,
                                    ),
                                    child: TextFormField(
                                      controller: streetAddress,
                                      focusNode: _streetFocusNode,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: FontConstants.body1,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText:
                                            language["Street"] ?? "Street",
                                        filled: true,
                                        fillColor: ColorConstants.fillcolor,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return language["Enter Street"] ??
                                              "Enter Street";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      right: 16,
                                      bottom: 8,
                                    ),
                                    child: TextFormField(
                                      controller: ward,
                                      focusNode: _wardFocusNode,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: FontConstants.body1,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText: language["Ward"] ?? "Ward",
                                        filled: true,
                                        fillColor: ColorConstants.fillcolor,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return language["Enter Ward"] ??
                                              "Enter Ward";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 24,
                              ),
                              child: TextFormField(
                                controller: note,
                                focusNode: _noteFocusNode,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                style: FontConstants.body1,
                                cursorColor: Colors.black,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: language["Note"] ?? "Note",
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
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: const Divider(
                      height: 0,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
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
                          createOrder();
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
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(index == 0 ? 10 : 0),
                                bottomLeft: Radius.circular(
                                    index == carts.length - 1 ? 10 : 0),
                              ),
                              icon: Icons.update,
                              label: language["Update"] ?? "Update",
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    // image: NetworkImage(
                                    //     '${ApiConstants.baseUrl}${carts[index]["product_images"][0].toString()}'),
                                    image: AssetImage("assets/images/logo.png"),
                                    fit: BoxFit.fill,
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
                                    left: 4,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              carts[index]["brand_name"] ?? "",
                                              overflow: TextOverflow.ellipsis,
                                              style: FontConstants.body1,
                                            ),
                                          ),
                                          Text(
                                            'x ${carts[index]["quantity"].toString()}',
                                            style: FontConstants.caption1,
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
                                      FormattedAmount(
                                        amount: carts[index]["totalamount"],
                                        mainTextStyle:
                                            FontConstants.subheadline1,
                                        decimalTextStyle:
                                            FontConstants.caption3,
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
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
