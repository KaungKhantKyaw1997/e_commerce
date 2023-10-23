import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ScrollController _scrollController = ScrollController();
  List reviews = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        reviews = arguments["reviews"];
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    );
  }
}
