import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/products_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ScrollController _scrollController = ScrollController();
  final productsService = ProductsService();
  List products = [];
  List reviews = [];
  Map<String, dynamic> shop = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        shop = arguments;
        getProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getProducts() async {
    try {
      final body = {
        "page": 1,
        "per_page": 10,
        "shop_id": shop["shop_id"],
      };
      final response = await productsService.getProductsData(body);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            products = response["data"];
          });
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  reviewCard(index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        child: Center(
          child: Text(
            reviews[index]["name"].toString(),
            overflow: TextOverflow.ellipsis,
            style: FontConstants.caption2,
          ),
        ),
      ),
    );
  }

  productsCard(index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: products[index]["product_images"].isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(
                          '${ApiConstants.baseUrl}${products[index]["product_images"][0].toString()}'),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              border: Border.all(
                color: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 4,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                products[index]["brand_name"].toString(),
                overflow: TextOverflow.ellipsis,
                style: FontConstants.caption2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 4,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                products[index]["model"].toString(),
                overflow: TextOverflow.ellipsis,
                style: FontConstants.smallText1,
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
          language["Shop"] ?? "Shop",
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
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    image: shop["cover_image"] != ""
                        ? DecorationImage(
                            image: NetworkImage(
                                '${ApiConstants.baseUrl}${shop["cover_image"].toString()}'),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.fill,
                          ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      shop["name"].toString(),
                      style: FontConstants.body1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      shop["address"].toString(),
                      style: FontConstants.caption1,
                    ),
                  ),
                ),
                reviews.isNotEmpty
                    ? Container(
                        height: 110,
                        child: ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: (reviews.length / 2).ceil(),
                          itemBuilder: (context, pageIndex) {
                            int startIndex = pageIndex * 2;
                            int endIndex = (pageIndex * 2 + 1)
                                .clamp(0, reviews.length - 1);

                            return ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount: endIndex - startIndex + 1,
                              itemBuilder: (context, index) {
                                int itemIndex = startIndex + index;
                                if (itemIndex < reviews.length) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: 8,
                                      bottom: 8,
                                    ),
                                    child: reviewCard(itemIndex),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            );
                          },
                          itemExtent:
                              MediaQuery.of(context).size.width / 2 - 50,
                        ),
                      )
                    : Container(),
                products.isNotEmpty
                    ? Container(
                        padding: EdgeInsets.only(
                          top: 16,
                          bottom: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              language["Products"] ?? "Products",
                              style: FontConstants.body1,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.products,
                                  arguments: shop,
                                );
                              },
                              child: Text(
                                language["See More"] ?? "See More",
                                style: FontConstants.caption5,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                products.isNotEmpty
                    ? Container(
                        height: 250,
                        child: ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.product,
                                  arguments: products[index],
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: 8,
                                ),
                                child: productsCard(index),
                              ),
                            );
                          },
                          itemExtent:
                              MediaQuery.of(context).size.width / 2 - 25,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
