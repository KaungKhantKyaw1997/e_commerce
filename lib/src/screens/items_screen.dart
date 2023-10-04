import 'dart:io';

import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/services/products_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen>
    with SingleTickerProviderStateMixin {
  final productsService = ProductsService();
  final ScrollController _itemController = ScrollController();
  TextEditingController search = TextEditingController(text: '');
  List items = [];
  int page = 1;
  int pageCounts = 0;
  int total = 0;
  int shopId = 0;
  int categoryId = 0;
  double fromPrice = 0;
  double toPrice = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        shopId = arguments["shop_id"] ?? 0;
        categoryId = arguments["category_id"] ?? 0;
        getProducts();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getProducts() async {
    try {
      final body = {
        "page": page,
        "per_page": 10,
        "search": search.text,
        if (shopId != 0) "shop_id": shopId,
        if (categoryId != 0) "category_id": categoryId,
        if (fromPrice != 0) "from_price": fromPrice,
        if (toPrice != 0) "to_price": toPrice,
        "brands": [],
        "models": []
      };

      final response = await productsService.getProductsData(body);
      if (response["code"] == 200) {
        if (response["data"].isNotEmpty) {
          items = response["data"];
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    double _startValue = 0;
    double _endValue = 200000;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
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
                  RangeSlider(
                    values: RangeValues(_startValue, _endValue),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _startValue = values.start;
                        _endValue = values.end;
                      });
                    },
                    min: 0,
                    max: 1000000,
                    divisions: 1000000,
                    labels: RangeLabels('$_startValue', '$_endValue'),
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
                        Navigator.pop(context);
                      },
                      child: Text(
                        language["Search"] ?? "Search",
                        style: FontConstants.button1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  itemCard(index) {
    return Container(
      padding: EdgeInsets.only(
        top: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                // image: NetworkImage(
                //     '${ApiConstants.baseUrl}${items[index]["product_images"][0].toString()}'),
                image: AssetImage("assets/images/gshock1.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
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
                items[index]["brand_name"].toString(),
                style: FontConstants.caption2,
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
              alignment: Alignment.centerLeft,
              child: Text(
                items[index]["model"].toString(),
                style: FontConstants.body1,
              ),
            ),
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
          language["Products"] ?? "Products",
          style: FontConstants.title1,
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorConstants.fillcolor,
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                "assets/icons/filter.svg",
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                _showFilterBottomSheet(context);
              },
            ),
          ),
        ],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          width: double.infinity,
          child: Column(
            children: [
              GridView.builder(
                controller: _itemController,
                shrinkWrap: true,
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 230,
                  childAspectRatio: 2 / 1,
                  crossAxisSpacing: 15,
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.item_details,
                        arguments: items[index],
                      );
                    },
                    child: itemCard(index),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
