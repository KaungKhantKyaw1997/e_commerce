import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/product_service.dart';
import 'package:e_commerce/src/services/rating_service.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  final productService = ProductService();
  final ratingService = RatingService();
  List products = [];
  List reviews = [];
  List<double> ratings = [];
  Map<String, dynamic> shop = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        shop = arguments;
        setState(() {});
        getProducts();
        getSellerReviews();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getSellerReviews() async {
    try {
      final response =
          await ratingService.getSellerReviewsData(shop["shop_id"]);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            reviews = response["data"];
            for (var item in reviews) {
              ratings.add(item["rating"]);
            }
          });
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

  double calculateAverageRating(ratings) {
    if (ratings.isEmpty) {
      return 0.0;
    }

    double totalRatings = 0.0;
    for (double rating in ratings) {
      totalRatings += rating;
    }

    double averageRating = totalRatings / ratings.length;
    return double.parse(averageRating.toStringAsFixed(1));
  }

  getProducts() async {
    try {
      final body = {
        "page": 1,
        "per_page": 10,
        "shop_id": shop["shop_id"],
        "view": "user"
      };
      final response = await productService.getProductsData(body);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            products = response["data"];
          });
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

  averageRatingCard() {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.reviews,
          arguments: {
            "reviews": reviews,
            "shop": shop,
          },
          (route) => true,
        );

        ratings = [];
        getSellerReviews();
      },
      child: Container(
        margin: EdgeInsets.only(
          top: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          child: Row(
            children: [
              Container(
                width: 37,
                height: 37,
                margin: EdgeInsets.only(
                  right: 8,
                ),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                  color: Colors.amber.withOpacity(0.2),
                ),
                child: SvgPicture.asset(
                  "assets/icons/star.svg",
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.amber,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          language["Rating"] ?? "Rating",
                          style: FontConstants.body1,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          "-",
                          style: FontConstants.body1,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          calculateAverageRating(ratings).toString(),
                          style: FontConstants.body1,
                        )
                      ],
                    ),
                    Text(
                      '${reviews.length.toString()} ${language["Reviews"] ?? "Reviews"}',
                      overflow: TextOverflow.ellipsis,
                      style: FontConstants.caption1,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
              ),
            ],
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
          if (products[index].isNotEmpty &&
              products[index]["discount_percent"] > 0.0)
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    products[index]["symbol"].toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.grey,
                    ),
                  ),
                  products[index]["price"] != null
                      ? FormattedAmount(
                          amount:
                              double.parse(products[index]["price"].toString()),
                          mainTextStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey,
                          ),
                          decimalTextStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey,
                          ),
                        )
                      : Text(""),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  products[index]["symbol"].toString(),
                  style: FontConstants.caption2,
                ),
                products[index]["discounted_price"] != null
                    ? FormattedAmount(
                        amount: double.parse(
                            products[index]["discounted_price"].toString()),
                        mainTextStyle: FontConstants.caption2,
                        decimalTextStyle: FontConstants.caption2,
                      )
                    : Text(""),
              ],
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
        scrolledUnderElevation: 0,
        title: Text(
          language["Shop"] ?? "Shop",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          fit: BoxFit.cover,
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
              averageRatingCard(),
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
                            onTap: () async {
                              await Navigator.pushNamedAndRemoveUntil(
                                context,
                                Routes.products,
                                arguments: shop,
                                (route) => true,
                              );

                              getProducts();
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
                      height: 290,
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.pushNamedAndRemoveUntil(
                                context,
                                Routes.product,
                                arguments: products[index],
                                (route) => true,
                              );

                              getProducts();
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                right: 8,
                              ),
                              child: productsCard(index),
                            ),
                          );
                        },
                        itemExtent: MediaQuery.of(context).size.width / 2 - 25,
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
