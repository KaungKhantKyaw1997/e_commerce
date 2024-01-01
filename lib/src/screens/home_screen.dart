import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/chat_histories_provider.dart';
import 'package:e_commerce/src/providers/message_provider.dart';
import 'package:e_commerce/src/providers/noti_provider.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/brand_service.dart';
import 'package:e_commerce/src/services/category_service.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/notification_service.dart';
import 'package:e_commerce/src/services/product_service.dart';
import 'package:e_commerce/src/services/shop_service.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final crashlytic = new CrashlyticsService();
  final authService = AuthService();
  final shopService = ShopService();
  final brandService = BrandService();
  final categoryService = CategoryService();
  final productService = ProductService();
  final notificationService = NotificationService();
  final chatService = ChatService();
  final storage = FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late TabController _tabController;
  List shops = [];
  List brands = [];
  List products = [];
  List categories = [];
  int page = 1;
  int crossAxisCount = 1;
  String profileImage = '';
  String profileName = '';
  String role = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getData();
    getProfile();
    getShops();
    getProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    // shopService.cancelRequest();
    // brandService.cancelRequest();
    // categoryService.cancelRequest();
    // notificationService.cancelRequest();
    super.dispose();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "";
      if (role == 'user' || role == 'agent') {
        unreadNotifications();
        getTotalUnreadCounts();
      }
    });
  }

  unreadNotifications() async {
    try {
      final response = await notificationService.unreadNotificationsData();
      if (response!["code"] == 200) {
        NotiProvider notiProvider =
            Provider.of<NotiProvider>(context, listen: false);
        notiProvider.addCount(response["data"]);
        FlutterAppBadger.updateBadgeCount(response["data"]);
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
        }
      }
    }
  }

  getTotalUnreadCounts() async {
    try {
      final response = await chatService.getTotalUnreadCountsData();
      if (response!["code"] == 200) {
        MessageProvider messageProvider =
            Provider.of<MessageProvider>(context, listen: false);
        messageProvider.addCount(response["data"]);
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
        }
      }
    }
  }

  getProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    profileImage = prefs.getString('profile_image') ?? "";
    profileName = prefs.getString('name') ?? "";
  }

  getShops() async {
    try {
      final response = await shopService.getShopsData(page: page, view: "user");
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          shops += response["data"];
          page++;
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
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

  getProducts() {
    getTopModels();
    getBrands();
    getCategories();
  }

  getTopModels() async {
    try {
      final body = {
        "is_top_model": true,
        "page": 1,
        "per_page": 10,
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

  getBrands() async {
    try {
      final response = await brandService.getBrandsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            brands = response["data"];
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

  getCategories() async {
    try {
      final response = await categoryService.getCategoriesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            categories = response["data"];
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
      if (e is DioException && e.response?.statusCode == 401) {
        Navigator.pushNamed(
          context,
          Routes.unauthorized,
        );
      }
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
              image: shops[index]["cover_image"].isNotEmpty
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
              image: categories[index]["cover_image"].isNotEmpty
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
              products[index]["discount_type"] != 'No Discount' &&
              products[index]["price"] != products[index]["discounted_price"])
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

  Stream<DateTime> dateTimeStream =
      Stream.periodic(Duration.zero, (_) => DateTime.now());

  @override
  Widget build(BuildContext context) {
    MessageProvider messageProvider =
        Provider.of<MessageProvider>(context, listen: true);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
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

                  return profileName.isEmpty
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
          leading: role.isNotEmpty
              ? GestureDetector(
                  onTap: () async {
                    var result = await Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.profile,
                      (route) => true,
                    );
                    if (result != null && result is Map<String, dynamic>) {
                      setState(() {
                        profileImage = result["profileImage"];
                        profileName = result["profileName"];
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      top: 8,
                      bottom: 8,
                    ),
                    decoration: profileImage.isEmpty
                        ? BoxDecoration(
                            color: ColorConstants.fillColor,
                            image: DecorationImage(
                              image: AssetImage("assets/images/profile.png"),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          )
                        : BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  '${profileImage.startsWith("/images") ? ApiConstants.baseUrl : ""}$profileImage'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                  ),
                )
              : null,
          actions: [
            IconButton(
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
                Navigator.of(context).pushNamed(
                  Routes.search,
                );
              },
            ),
            if (role.isNotEmpty)
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 3,
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        "assets/icons/message.svg",
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        ChatHistoriesProvider chatHistoriesProvider =
                            Provider.of<ChatHistoriesProvider>(context,
                                listen: false);
                        chatHistoriesProvider.setChatHistories([]);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          Routes.chat_history,
                          arguments: {
                            'from': 'home',
                          },
                          (route) => true,
                        );
                      },
                    ),
                  ),
                  if (messageProvider.count > 0)
                    Positioned(
                      top: 8,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: ColorConstants.redColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${messageProvider.count}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: FontConstants.bottom,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Center(
                  child: Text(
                    language["Shops"] ?? "Shops",
                    style: FontConstants.subtitle1,
                  ),
                ),
              ),
              Tab(
                child: Center(
                  child: Text(
                    language["Products"] ?? "Products",
                    style: FontConstants.subtitle1,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            shops.isNotEmpty
                ? SmartRefresher(
                    header: WaterDropMaterialHeader(
                      backgroundColor: Theme.of(context).primaryColor,
                      color: Colors.white,
                    ),
                    footer: ClassicFooter(),
                    controller: _refreshController,
                    enablePullDown: true,
                    enablePullUp: true,
                    onRefresh: () async {
                      if (role == 'user' || role == 'agent') {
                        unreadNotifications();
                        getTotalUnreadCounts();
                      }
                      page = 1;
                      shops = [];
                      await getShops();
                    },
                    onLoading: () async {
                      await getShops();
                    },
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GridView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount: shops.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisExtent: crossAxisCount == 1 ? 310 : 210,
                                childAspectRatio: 2 / 1,
                                crossAxisSpacing: 8,
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 8,
                              ),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      Routes.shop,
                                      arguments: shops[index],
                                      (route) => true,
                                    );
                                  },
                                  child: shopCard(index),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(),
            products.isNotEmpty || brands.isNotEmpty || categories.isNotEmpty
                ? SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          products.isNotEmpty
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
                                        language["Products"] ?? "Products",
                                        style: FontConstants.body1,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await Navigator
                                              .pushNamedAndRemoveUntil(
                                            context,
                                            Routes.products,
                                            arguments: {
                                              "is_top_model": true,
                                            },
                                            (route) => true,
                                          );

                                          getTopModels();
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
                                  width: double.infinity,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          await Navigator
                                              .pushNamedAndRemoveUntil(
                                            context,
                                            Routes.product,
                                            arguments: products[index],
                                            (route) => true,
                                          );

                                          getTopModels();
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
                                        MediaQuery.of(context).size.width / 2 -
                                            25,
                                  ),
                                )
                              : Container(),
                          brands.isNotEmpty
                              ? Container(
                                  padding: EdgeInsets.only(
                                    top: 24,
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
                                        onTap: () async {
                                          await Navigator
                                              .pushNamedAndRemoveUntil(
                                            context,
                                            Routes.brands,
                                            (route) => true,
                                          );

                                          getBrands();
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
                                              onTap: () async {
                                                await Navigator
                                                    .pushNamedAndRemoveUntil(
                                                  context,
                                                  Routes.products,
                                                  arguments: brands[itemIndex],
                                                  (route) => true,
                                                );

                                                getBrands();
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
                                        MediaQuery.of(context).size.width / 2 -
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
                                        language["Categories"] ?? "Categories",
                                        style: FontConstants.body1,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await Navigator
                                              .pushNamedAndRemoveUntil(
                                            context,
                                            Routes.categories,
                                            (route) => true,
                                          );

                                          getCategories();
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
                          categories.isNotEmpty
                              ? Container(
                                  height: 200,
                                  width: double.infinity,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          await Navigator
                                              .pushNamedAndRemoveUntil(
                                            context,
                                            Routes.products,
                                            arguments: categories[index],
                                            (route) => true,
                                          );

                                          getCategories();
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
                                        MediaQuery.of(context).size.width / 2 -
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
        bottomNavigationBar: const BottomBarScreen(),
      ),
    );
  }
}
