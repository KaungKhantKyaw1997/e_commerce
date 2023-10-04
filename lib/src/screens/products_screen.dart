import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/services/products_service.dart';
import 'package:e_commerce/src/utils/currency_input_formatter.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/routes.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  final productsService = ProductsService();
  final ScrollController _productController = ScrollController();
  TextEditingController search = TextEditingController(text: '');
  TextEditingController _fromPrice = TextEditingController(text: '');
  TextEditingController _toPrice = TextEditingController(text: '');
  NumberFormat formatter = NumberFormat('###,###.00', 'en_US');

  List products = [];
  int page = 1;
  int pageCounts = 0;
  int total = 0;
  int shopId = 0;
  int categoryId = 0;
  int brandId = 0;
  List brands = [];
  double _startValue = 0;
  double _endValue = 0;

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
        if (brandId != 0) {
          brands.add(brandId);
        }
        getProducts();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
        "models": []
      };

      if (shopId == 0) body.remove("shop_id");
      if (categoryId == 0) body.remove("category_id");
      if (toPrice == 0.0) body.remove("from_price");
      if (toPrice == 0.0) body.remove("to_price");

      final response = await productsService.getProductsData(body);
      if (response["code"] == 200) {
        products = [];
        page = 1;
        pageCounts = 0;
        total = 0;
        if (response["data"].isNotEmpty) {
          products = response["data"];
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

  void _showFilterBottomSheet(BuildContext context) {
    _startValue = 0;
    _endValue = 0;
    _fromPrice.text = '';
    _toPrice.text = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                    ),
                    child: Text(
                      language["Price Range"] ?? "Price Range",
                      style: FontConstants.subheadline1,
                    ),
                  ),
                  RangeSlider(
                    values: RangeValues(_startValue, _endValue),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _startValue = values.start;
                        _endValue = values.end;
                        _fromPrice.text = '${formatter.format(_startValue)}';
                        _toPrice.text = '${formatter.format(_endValue)}';
                      });
                    },
                    min: 0,
                    max: 500000,
                    divisions: 500,
                    labels: RangeLabels('${formatter.format(_startValue)}',
                        '${formatter.format(_endValue)}'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 4,
                            top: 8,
                            bottom: 24,
                          ),
                          child: TextFormField(
                            controller: _fromPrice,
                            inputFormatters: [CurrencyInputFormatter()],
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: language["From"] ?? "From",
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
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                            right: 16,
                            top: 8,
                            bottom: 24,
                          ),
                          child: TextFormField(
                            controller: _toPrice,
                            inputFormatters: [CurrencyInputFormatter()],
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: language["To"] ?? "To",
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
                      ),
                    ],
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
            );
          },
        );
      },
    );
  }

  productCard(index) {
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
                //     '${ApiConstants.baseUrl}${products[index]["product_images"][0].toString()}'),
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
                products[index]["brand_name"].toString(),
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
                products[index]["model"].toString(),
                style: FontConstants.body1,
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
          autofocus: true,
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 24,
          ),
          width: double.infinity,
          child: Column(
            children: [
              products.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.only(
                        top: 4,
                        bottom: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Total ${total.toString()}',
                            style: FontConstants.caption1,
                          ),
                          NumberPaginator(
                            numberPages: pageCounts,
                            onPageChange: (int index) {
                              setState(() {
                                page = index + 1;
                                getProducts();
                              });
                            },
                            config: const NumberPaginatorUIConfig(
                              mode: ContentDisplayMode.hidden,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              GridView.builder(
                controller: _productController,
                shrinkWrap: true,
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 230,
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
      ),
    );
  }
}
