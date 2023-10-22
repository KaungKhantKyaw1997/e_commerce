import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/products_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/routes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final crashlytic = new CrashlyticsService();
  final productsService = ProductsService();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController search = TextEditingController(text: '');

  List products = [];
  int page = 1;
  List<String> searchhistories = [];

  @override
  void initState() {
    super.initState();
    getSearchHistories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getSearchHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final searchhistoriesJson = prefs.getString("searchhistories");
    if (searchhistoriesJson != null) {
      setState(() {
        List jsonData = jsonDecode(searchhistoriesJson) ?? [];
        for (var item in jsonData) {
          searchhistories.add(item);
        }
      });
    }
  }

  Future<void> saveListToSharedPreferences(List<String> datalist) async {
    final prefs = await SharedPreferences.getInstance();
    const key = "searchhistories";

    final jsonData = jsonEncode(datalist);

    await prefs.setString(key, jsonData);
  }

  getProducts() async {
    try {
      final body = {
        "page": page,
        "per_page": 10,
        "search": search.text,
      };

      final response = await productsService.getProductsData(body);
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          products += response["data"];
          page++;
        }
        if (!searchhistories.contains(search.text)) {
          searchhistories.add(search.text);
          saveListToSharedPreferences(searchhistories);
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
      setState(() {});
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

  productCard(index) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(index == 0 ? 10 : 0),
          topRight: Radius.circular(index == 0 ? 10 : 0),
          bottomLeft: Radius.circular(index == products.length - 1 ? 10 : 0),
          bottomRight: Radius.circular(index == products.length - 1 ? 10 : 0),
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              image: products.length > 0 &&
                      products[index]["product_images"].isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(
                          '${ApiConstants.baseUrl}${products[index]["product_images"][0].toString()}'),
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
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                left: 15,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    products[index]["brand_name"].toString(),
                    overflow: TextOverflow.ellipsis,
                    style: FontConstants.body1,
                  ),
                  Text(
                    products[index]["model"].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FontConstants.caption1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  searchHistoriesList() {
    List<Widget> choices = [];
    searchhistories.forEach(
      (item) {
        choices.add(
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 4.0,
            ),
            child: ChoiceChip(
              label: Text(
                item,
                style: FontConstants.caption2,
              ),
              selected: true,
              selectedColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onSelected: (selected) async {
                search.text = item;
                page = 1;
                products = [];
                await getProducts();
              },
            ),
          ),
        );
      },
    );
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: TextField(
          controller: search,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: FontConstants.body1,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: language["Search"] ?? "Search",
            filled: true,
            fillColor: ColorConstants.fillcolor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            page = 1;
            products = [];
            if (value.isEmpty) {
              setState(() {});
              return;
            }
            getProducts();
          },
        ),
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
              page = 1;
              products = [];
              if (search.text.isEmpty) {
                setState(() {});
                return;
              }
              getProducts();
            },
          ),
        ],
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SmartRefresher(
        header: WaterDropMaterialHeader(
          backgroundColor: Theme.of(context).primaryColor,
          color: Colors.white,
        ),
        footer: ClassicFooter(),
        controller: _refreshController,
        enablePullDown: search.text.isNotEmpty ? true : false,
        enablePullUp: search.text.isNotEmpty ? true : false,
        onRefresh: () async {
          page = 1;
          products = [];
          await getProducts();
        },
        onLoading: () async {
          await getProducts();
        },
        child: products.isNotEmpty
            ? SingleChildScrollView(
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                productCard(index),
                                index < products.length - 1
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
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            : searchhistories.isNotEmpty
                ? SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                language["Search Histories"] ??
                                    "Search Histories",
                                style: FontConstants.subheadline1,
                              ),
                              GestureDetector(
                                onTap: () {
                                  searchhistories = [];
                                  saveListToSharedPreferences(searchhistories);
                                  setState(() {});
                                },
                                child: SvgPicture.asset(
                                  "assets/icons/trash.svg",
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Wrap(
                            children: searchHistoriesList(),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
      ),
    );
  }
}
