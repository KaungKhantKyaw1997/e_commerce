import 'dart:ui';

import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/brands_service.dart';
import 'package:e_commerce/src/services/categories_service.dart';
import 'package:e_commerce/src/services/shops_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final authService = AuthService();
  final shopsService = ShopsService();
  final brandsService = BrandsService();
  final categoriesService = CategoriesService();
  final storage = FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  List shops = [];
  List brands = [];
  List categories = [];
  int page = 1;
  int pageCounts = 0;
  int total = 0;
  int crossAxisCount = 1;
  bool shopTab = false;
  bool productTab = false;
  String profileImage = '';
  String profileName = '';
  bool validtoken = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    verifyToken();
    getProfile();
    getShops();
    getProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    shopsService.cancelRequest();
    brandsService.cancelRequest();
    categoriesService.cancelRequest();
    super.dispose();
  }

  verifyToken() async {
    var token = await storage.read(key: "token") ?? "";
    if (token == "") {
      validtoken = false;
      return;
    }
    try {
      final body = {
        "token": token,
      };
      final response = await authService.verifyTokenData(body);
      if (response["code"] != 200) {
        setState(() {
          validtoken = false;
        });
        authService.clearData();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    profileImage = prefs.getString('profile_image') ?? "";
    profileName = prefs.getString('name') ?? "";
  }

  getShops() async {
    try {
      final response = await shopsService.getShopsData(page: page);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            shops = response["data"];
            page = response["page"];
            pageCounts = response["page_counts"];
            total = response["total"];
            shopTab = true;
          });
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getProducts() {
    getBrands();
    getCategories();
  }

  getBrands() async {
    try {
      final response = await brandsService.getBrandsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            brands = response["data"];
          });
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
          setState(() {
            categories = response["data"];
            productTab = true;
          });
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: crossAxisCount == 1 ? 240 : 150,
            decoration: BoxDecoration(
              image: shops[index]["cover_image"] != ""
                  ? DecorationImage(
                      image: NetworkImage(
                          '${ApiConstants.baseUrl}${shops[index]["cover_image"].toString()}'),
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
                shops[index]["name"].toString(),
                overflow: TextOverflow.ellipsis,
                style: crossAxisCount == 1
                    ? FontConstants.body1
                    : FontConstants.caption2,
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
                shops[index]["address"].toString(),
                overflow: TextOverflow.ellipsis,
                style: crossAxisCount == 1
                    ? FontConstants.caption1
                    : FontConstants.smallText1,
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
            overflow: TextOverflow.ellipsis,
            style: FontConstants.caption2,
          ),
        ),
      ),
    );
  }

  categoriesCard(index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              image: categories[index]["cover_image"] != ""
                  ? DecorationImage(
                      image: NetworkImage(
                          '${ApiConstants.baseUrl}${categories[index]["cover_image"].toString()}'),
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
                categories[index]["name"].toString(),
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

  Stream<DateTime> dateTimeStream =
      Stream.periodic(Duration.zero, (_) => DateTime.now());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Align(
            alignment: Alignment.centerLeft,
            child: StreamBuilder<DateTime>(
              stream: dateTimeStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final time = snapshot.data;
                  final hour = time!.hour;

                  String greeting;

                  if (hour >= 0 && hour < 12) {
                    greeting = 'Good Morning';
                  } else if (hour >= 12 && hour < 17) {
                    greeting = 'Good Afternoon';
                  } else {
                    greeting = 'Good Evening';
                  }

                  return profileName == ""
                      ? Text(
                          greeting,
                          style: FontConstants.body1,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: FontConstants.body1,
                            ),
                            Text(
                              profileName,
                              style: FontConstants.caption2,
                            ),
                          ],
                        );
                } else {
                  return Text(
                    'Loading...',
                    style: FontConstants.body1,
                  );
                }
              },
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              if (validtoken) {
                Navigator.pushNamed(
                  context,
                  Routes.profile,
                  arguments: {
                    'from': 'home',
                  },
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(
                left: 16,
                top: 8,
                bottom: 8,
              ),
              decoration: profileImage == ''
                  ? BoxDecoration(
                      color: ColorConstants.fillcolor,
                      image: DecorationImage(
                        image: AssetImage("assets/images/profile.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    )
                  : BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            '${ApiConstants.baseUrl}${profileImage.toString()}'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
            ),
          ),
          actions: [
            // IconButton(
            //   icon: SvgPicture.asset(
            //     "assets/icons/sign_out.svg",
            //     width: 22,
            //     height: 22,
            //     colorFilter: const ColorFilter.mode(
            //       Colors.black,
            //       BlendMode.srcIn,
            //     ),
            //   ),
            //   onPressed: () {},
            // ),
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
          child: TabBarView(
            controller: _tabController,
            children: [
              shopTab
                  ? SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 24,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                top: 4,
                                bottom: 4,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Total ${total.toString()}',
                                    style: FontConstants.caption1,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
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
                                        config: const NumberPaginatorUIConfig(
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
                                          colorFilter: const ColorFilter.mode(
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
                            ),
                            GridView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount: shops.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisExtent: crossAxisCount == 1 ? 300 : 210,
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
                      ),
                    )
                  : Container(),
              productTab
                  ? SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 24,
                        ),
                        child: Column(
                          children: [
                            brands.isNotEmpty
                                ? Container(
                                    padding: EdgeInsets.only(
                                      top: 16,
                                      bottom: 4,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
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
                                  )
                                : Container(),
                            brands.isNotEmpty
                                ? Container(
                                    height: 110,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: (brands.length / 2).ceil(),
                                      itemBuilder: (context, pageIndex) {
                                        int startIndex = pageIndex * 2;
                                        int endIndex = (pageIndex * 2 + 1)
                                            .clamp(0, brands.length - 1);

                                        return ListView.builder(
                                          controller: _scrollController,
                                          shrinkWrap: true,
                                          itemCount: endIndex - startIndex + 1,
                                          itemBuilder: (context, index) {
                                            int itemIndex = startIndex + index;
                                            if (itemIndex < brands.length) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    Routes.products,
                                                    arguments:
                                                        brands[itemIndex],
                                                  );
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 8,
                                                    bottom: 8,
                                                  ),
                                                  child: brandsCard(itemIndex),
                                                ),
                                              );
                                            } else {
                                              return Container();
                                            }
                                          },
                                        );
                                      },
                                      itemExtent:
                                          MediaQuery.of(context).size.width /
                                                  2 -
                                              50,
                                    ),
                                  )
                                : Container(),
                            categories.isNotEmpty
                                ? Container(
                                    padding: EdgeInsets.only(
                                      top: 8,
                                      bottom: 4,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          language["Categories"] ??
                                              "Categories",
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
                                  )
                                : Container(),
                            categories.isNotEmpty
                                ? Container(
                                    height: 200,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: categories.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              Routes.products,
                                              arguments: categories[index],
                                            );
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: categoriesCard(index),
                                          ),
                                        );
                                      },
                                      itemExtent:
                                          MediaQuery.of(context).size.width /
                                                  2 -
                                              25,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        bottomNavigationBar: const BottomBarScreen(),
      ),
    );
  }
}
