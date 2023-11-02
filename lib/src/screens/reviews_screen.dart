import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/rating_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final crashlytic = new CrashlyticsService();
  final ratingService = RatingService();
  final ScrollController _scrollController = ScrollController();
  TextEditingController comment = TextEditingController(text: '');
  double rating = 1.0;
  List reviews = [];
  Map<String, dynamic> shop = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        reviews = arguments["reviews"];
        shop = arguments["shop"];
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  addSellerReviews() async {
    try {
      final body = {
        "shop_id": shop["shop_id"],
        "rating": rating,
        "comment": comment.text,
      };
      final response = await ratingService.addSellerReviewsData(body);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        comment.text = '';
        getSellerReviews();
      }
    } catch (e, s) {
      Navigator.pop(context);
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

  getSellerReviews() async {
    try {
      final response =
          await ratingService.getSellerReviewsData(shop["shop_id"]);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            reviews = response["data"];
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

  reviewCard(index) {
    int fullStars = reviews[index]["rating"].floor();
    bool hasHalfStar = (reviews[index]["rating"] - fullStars) >= 0.5;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(
                    right: 8,
                  ),
                  decoration: BoxDecoration(
                    image: reviews[index]["profile_image"].isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                                '${ApiConstants.baseUrl}${reviews[index]["profile_image"].toString()}'),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image: AssetImage('assets/images/profile.png'),
                            fit: BoxFit.cover,
                          ),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviews[index]["name"].toString(),
                      overflow: TextOverflow.ellipsis,
                      style: FontConstants.body1,
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        if (index < fullStars) {
                          return Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          );
                        } else if (hasHalfStar && index == fullStars) {
                          return Icon(
                            Icons.star_half,
                            color: Colors.amber,
                            size: 16,
                          );
                        } else {
                          return Icon(
                            Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
              ),
              child: Text(
                reviews[index]["comment"].toString(),
                style: FontConstants.caption1,
              ),
            ),
          ],
        ),
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
          language["Reviews"] ?? "Reviews",
          style: FontConstants.title1,
        ),
        leading: BackButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(
              context,
              Routes.shop,
              arguments: shop,
            );
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            Routes.shop,
            arguments: shop,
          );
          return true;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            width: double.infinity,
            child: Column(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return reviewCard(index);
                  },
                ),
              ],
            ),
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
              padding: const EdgeInsets.only(
                top: 16,
              ),
              child: Center(
                child: RatingBar.builder(
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  glowColor: Colors.amber,
                  unratedColor: Colors.amber.withOpacity(0.2),
                  itemPadding: EdgeInsets.symmetric(
                    horizontal: 3.0,
                  ),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (r) {
                    rating = r;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: 16,
              ),
              child: TextFormField(
                controller: comment,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                style: FontConstants.body1,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: language["Comment"] ?? "Comment",
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
                  showLoadingDialog(context);
                  addSellerReviews();
                },
                child: Text(
                  language["Post"] ?? "Post",
                  style: FontConstants.button1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
