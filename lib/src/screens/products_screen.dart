import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/services/models_service.dart';
import 'package:e_commerce/src/services/products_service.dart';
import 'package:e_commerce/src/utils/currency_input_formatter.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:e_commerce/src/widgets/multi_select_chip.dart';
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
  final modelsService = ModelsService();
  final productsService = ProductsService();
  FocusNode _fromFocusNode = FocusNode();
  FocusNode _toFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController search = TextEditingController(text: '');
  TextEditingController _fromPrice = TextEditingController(text: '');
  TextEditingController _toPrice = TextEditingController(text: '');
  NumberFormat formatter = NumberFormat('###,###.00', 'en_US');

  List products = [];
  int page = 1;
  int shopId = 0;
  int categoryId = 0;
  int brandId = 0;
  List<int> productIds = [];
  List brands = [];
  List<String> models = [];
  List<String> selectedModels = [];
  double _startValue = 0;
  double _endValue = 0;
  bool isTopModel = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    getModels();
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
        getProducts();
      }
    });
  }

  @override
  void dispose() {
    modelsService.cancelRequest();
    _scrollController.dispose();
    super.dispose();
  }

  getModels() async {
    try {
      final response = await modelsService.getModelsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            List<dynamic> dynamicList = response["data"];
            models = dynamicList.map((item) => item.toString()).toList();
          });
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getProducts() async {
    try {
      double fromPrice = _fromPrice.text == ''
          ? 0.0
          : double.parse(_fromPrice.text.replaceAll(',', ''));
      double toPrice = _toPrice.text == ''
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
    } catch (e) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      print('Error: $e');
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    _startValue = 0;
    _endValue = 0;
    _fromPrice.text = '';
    _toPrice.text = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _fromFocusNode.unfocus();
                _toFocusNode.unfocus();
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                height:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? MediaQuery.of(context).size.height - 10
                        : MediaQuery.of(context).size.height - 300,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 45,
                        height: 4,
                      ),
                    ),
                    Expanded(
                      child: DraggableScrollableSheet(
                        initialChildSize: 1.0,
                        maxChildSize: 1.0,
                        minChildSize: 0.2,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return ListView(
                            controller: scrollController,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                  ),
                                  child: Text(
                                    language["Price Range"] ?? "Price Range",
                                    style: FontConstants.subheadline1,
                                  ),
                                ),
                              ),
                              RangeSlider(
                                values: RangeValues(_startValue, _endValue),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    _startValue = values.start;
                                    _endValue = values.end;
                                    _fromPrice.text =
                                        '${formatter.format(_startValue)}';
                                    _toPrice.text =
                                        '${formatter.format(_endValue)}';
                                  });
                                },
                                min: 0,
                                max: 500000,
                                divisions: 500,
                                labels: RangeLabels(
                                    '${formatter.format(_startValue)}',
                                    '${formatter.format(_endValue)}'),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 4,
                                        top: 8,
                                      ),
                                      child: TextFormField(
                                        controller: _fromPrice,
                                        focusNode: _fromFocusNode,
                                        inputFormatters: [
                                          CurrencyInputFormatter()
                                        ],
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        style: FontConstants.body1,
                                        cursorColor: Colors.black,
                                        decoration: InputDecoration(
                                          hintText: language["From"] ?? "From",
                                          filled: true,
                                          fillColor: ColorConstants.fillcolor,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        right: 16,
                                        top: 8,
                                      ),
                                      child: TextFormField(
                                        controller: _toPrice,
                                        focusNode: _toFocusNode,
                                        inputFormatters: [
                                          CurrencyInputFormatter()
                                        ],
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        style: FontConstants.body1,
                                        cursorColor: Colors.black,
                                        decoration: InputDecoration(
                                          hintText: language["To"] ?? "To",
                                          filled: true,
                                          fillColor: ColorConstants.fillcolor,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                  ),
                                  child: Text(
                                    language["Models"] ?? "Models",
                                    style: FontConstants.subheadline1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                ),
                                child: MultiSelectChip(
                                  models,
                                  onSelectionChanged: (selectedList) {
                                    setState(() {
                                      selectedModels = selectedList;
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: const Divider(
                        height: 0,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
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
                          Navigator.pop(context);
                          getProducts();
                        },
                        child: Text(
                          language["Search"] ?? "Search",
                          style: FontConstants.button1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
                      products[index]["product_images"][0] != ""
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
          onChanged: (value) {
            _startValue = 0;
            _endValue = 0;
            _fromPrice.text = '';
            _toPrice.text = '';
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
            onPressed: () {
              _showFilterBottomSheet(context);
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
                            style: FontConstants.title2,
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
                            style: FontConstants.subheadline2,
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
