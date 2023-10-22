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
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  final crashlytic = new CrashlyticsService();
  final productsService = ProductsService();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController search = TextEditingController(text: '');

  TextEditingController _fromPrice = TextEditingController(text: '');
  TextEditingController _toPrice = TextEditingController(text: '');
  double _startValue = 0;
  double _endValue = 0;
  NumberFormat formatter = NumberFormat('###,###.00', 'en_US');
  List<String> selectedModels = [];

  List products = [];
  int page = 1;
  int shopId = 0;
  int categoryId = 0;
  int brandId = 0;
  List<int> productIds = [];
  List brands = [];

  bool isTopModel = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        shopId = arguments["shop_id"] ?? 0;
        categoryId = arguments["category_id"] ?? 0;
        brandId = arguments["brand_id"] ?? 0;
        productIds = arguments["productIds"] ?? [];
        isTopModel = arguments["is_top_model"] ?? false;
        if (brandId != 0) {
          brands.add(brandId);
        }
      }
      getProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getProducts() async {
    try {
      double fromPrice = _fromPrice.text.isEmpty
          ? 0.0
          : double.parse(_fromPrice.text.replaceAll(',', ''));
      double toPrice = _toPrice.text.isEmpty
          ? 0.0
          : double.parse(_toPrice.text.replaceAll(',', ''));

      final body = {
        "page": page,
        "per_page": 10,
        "search": search.text,
        "shop_id": shopId,
        "category_id": categoryId,
        "from_price": fromPrice,
        "to_price": toPrice,
        "brands": brands,
        "models": selectedModels,
        "products": productIds,
        if (isTopModel) "is_top_model": isTopModel,
      };

      if (shopId == 0) body.remove("shop_id");
      if (categoryId == 0) body.remove("category_id");
      if (toPrice == 0.0) body.remove("from_price");
      if (toPrice == 0.0) body.remove("to_price");

      final response = await productsService.getProductsData(body);
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          products += response["data"];
          page++;
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
      setState(() {
        if (products.isEmpty) {
          _dataLoaded = true;
        }
      });
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
          onChanged: (value) {
            page = 1;
            products = [];
            getProducts();
          },
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/filter.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () async {
              var result = await Navigator.pushNamed(
                context,
                Routes.products_filter,
                arguments: {
                  "_fromPrice": _fromPrice.text,
                  "_toPrice": _toPrice.text,
                  "_startValue": _startValue,
                  "_endValue": _endValue,
                  "selectedModels": selectedModels,
                },
              );

              if (result != null && result is Map<String, dynamic>) {
                _fromPrice.text = result["_fromPrice"] ?? '';
                _toPrice.text = result["_toPrice"] ?? '';
                _startValue = result["_startValue"] ?? 0;
                _endValue = result["_endValue"] ?? 0;
                selectedModels = result["selectedModels"] ?? [];
                page = 1;
                products = [];
                getProducts();
              }
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
        enablePullDown: true,
        enablePullUp: true,
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
            : _dataLoaded
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 150
                              : 300,
                          height: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 150
                              : 300,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/no_data.png'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 4,
                          ),
                          child: Text(
                            "Empty Product",
                            textAlign: TextAlign.center,
                            style: MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? FontConstants.title1
                                : FontConstants.title2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                          child: Text(
                            "There is no data...",
                            textAlign: TextAlign.center,
                            style: MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? FontConstants.caption1
                                : FontConstants.subheadline2,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
      ),
    );
  }
}
