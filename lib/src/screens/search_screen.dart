import 'dart:convert';

import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
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
    } catch (e) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      print('Error: $e');
    }
  }

  productCard(index) {
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
              image: products.length > 0 &&
                      products[index]["product_images"].isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(
                          '${ApiConstants.baseUrl}${products[index]["product_images"][0].toString()}'),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.fill,
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
                      GridView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisExtent: 250,
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
                                Routes.product,
                                arguments: products[index],
                              );
                            },
                            child: productCard(index),
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
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              language["Search Histories"] ??
                                  "Search Histories",
                              style: FontConstants.subheadline1,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          GridView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemCount: searchhistories.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisExtent: 25,
                              childAspectRatio: 2 / 1,
                              crossAxisSpacing: 8,
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                            ),
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          search.text =
                                              searchhistories[index].toString();
                                          page = 1;
                                          products = [];
                                          await getProducts();
                                        },
                                        child: Text(
                                          searchhistories[index].toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: FontConstants.caption2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        searchhistories.removeAt(index);
                                        saveListToSharedPreferences(
                                            searchhistories);
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 15,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
