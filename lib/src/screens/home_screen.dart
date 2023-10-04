import 'dart:io';

import 'package:autoscale_tabbarview/autoscale_tabbarview.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/services/brands_service.dart';
import 'package:e_commerce/src/services/categories_service.dart';
import 'package:e_commerce/src/services/shops_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';
import 'package:number_paginator/number_paginator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final shopsService = ShopsService();
  final brandsService = BrandsService();
  final categoriesService = CategoriesService();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  List shops = [];
  List brands = [];
  List categories = [];
  int page = 1;
  int pageCounts = 0;
  int total = 0;
  int crossAxisCount = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getShops();
    getBrands();
    getCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    shopsService.cancelRequest();
    brandsService.cancelRequest();
    categoriesService.cancelRequest();
    super.dispose();
  }

  getShops() async {
    try {
      final response = await shopsService.getShopsData(page: page);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          shops = response["data"];
          page = response["page"];
          pageCounts = response["page_counts"];
          total = response["total"];
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getBrands() async {
    try {
      final response = await brandsService.getBrandsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          brands = response["data"];
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getCategories() async {
    try {
      final response = await categoriesService.getCategoriesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          categories = response["data"];
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  shopCard(index) {
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
                //     '${ApiConstants.baseUrl}${shops[index]["cover_image"].toString()}'),
                image: AssetImage("assets/images/gshock1.png"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10),
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
                shops[index]["name"].toString(),
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
                shops[index]["address"].toString(),
                overflow: TextOverflow.ellipsis,
                style: FontConstants.smallText1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  brandsCard(index) {
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
            brands[index]["name"].toString(),
            style: FontConstants.caption2,
          ),
        ),
      ),
    );
  }

  categoriesCard(index) {
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
                //     '${ApiConstants.baseUrl}${categories[index]["cover_image"].toString()}'),
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
                categories[index]["name"].toString(),
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
                categories[index]["description"].toString(),
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          language["Home"] ?? "Home",
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
                "assets/icons/search.svg",
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.search,
                );
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorPadding: EdgeInsets.symmetric(
            horizontal: 30,
          ),
          tabs: [
            Tab(
              child: Text(
                language["Shops"] ?? "Shops",
                style: FontConstants.subtitle1,
              ),
            ),
            Tab(
              child: Text(
                language["Products"] ?? "Products",
                style: FontConstants.subtitle1,
              ),
            ),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 24,
            ),
            width: double.infinity,
            child: shops.isNotEmpty && categories.isNotEmpty
                ? AutoScaleTabBarView(
                    controller: _tabController,
                    children: [
                      Column(
                        children: [
                          shops.isNotEmpty
                              ? Container(
                                  padding: EdgeInsets.only(
                                    top: 4,
                                    bottom: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Total ${total.toString()}',
                                        style: FontConstants.caption1,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          NumberPaginator(
                                            numberPages: pageCounts,
                                            onPageChange: (int index) {
                                              setState(() {
                                                page = index + 1;
                                                getShops();
                                              });
                                            },
                                            config:
                                                const NumberPaginatorUIConfig(
                                              mode: ContentDisplayMode.hidden,
                                            ),
                                          ),
                                          IconButton(
                                            icon: SvgPicture.asset(
                                              crossAxisCount == 1
                                                  ? "assets/icons/grid_2.svg"
                                                  : "assets/icons/grid_4.svg",
                                              width: 24,
                                              height: 24,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                Colors.black,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                crossAxisCount =
                                                    crossAxisCount == 1 ? 2 : 1;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          GridView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemCount: shops.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisExtent: 220,
                              childAspectRatio: 2 / 1,
                              crossAxisSpacing: 8,
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 8,
                            ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.products,
                                    arguments: shops[index],
                                  );
                                },
                                child: shopCard(index),
                              );
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
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
                                  language["Brands"] ?? "Brands",
                                  style: FontConstants.body1,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.brands,
                                    );
                                  },
                                  child: Text(
                                    language["See More"] ?? "See More",
                                    style: FontConstants.caption1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (brands.length / 2).ceil(),
                              itemBuilder: (context, pageIndex) {
                                int startIndex = pageIndex * 2;
                                int endIndex = (pageIndex * 2 + 1)
                                    .clamp(0, brands.length - 1);

                                return ListView.builder(
                                  itemCount: endIndex - startIndex + 1,
                                  itemBuilder: (context, index) {
                                    int itemIndex = startIndex + index;
                                    if (itemIndex < brands.length) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          right: 8,
                                          bottom: 8,
                                        ),
                                        child: brandsCard(itemIndex),
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
                          ),
                          Container(
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
                                  language["Categories"] ?? "Categories",
                                  style: FontConstants.body1,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.categories,
                                    );
                                  },
                                  child: Text(
                                    language["See More"] ?? "See More",
                                    style: FontConstants.caption1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: 8,
                                  ),
                                  child: categoriesCard(index),
                                );
                              },
                              itemExtent:
                                  MediaQuery.of(context).size.width / 2 - 25,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Container(),
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
