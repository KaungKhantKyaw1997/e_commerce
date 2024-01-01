import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/brand_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/model_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:e_commerce/src/widgets/multi_select_chip.dart';
import 'package:flutter/material.dart';

class ProductsFilterScreen extends StatefulWidget {
  const ProductsFilterScreen({super.key});

  @override
  State<ProductsFilterScreen> createState() => _ProductsFilterScreenState();
}

class _ProductsFilterScreenState extends State<ProductsFilterScreen> {
  final crashlytic = new CrashlyticsService();
  final modelService = ModelService();
  final brandService = BrandService();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  FocusNode _fromFocusNode = FocusNode();
  FocusNode _toFocusNode = FocusNode();
  TextEditingController _fromPrice = TextEditingController(text: '');
  TextEditingController _toPrice = TextEditingController(text: '');
  double _startValue = 0;
  double _endValue = 0;

  List<String> models = [];
  List<String> selectedModels = [];

  List brands = [];
  List<String> brandnames = [];
  List<int> selectedBrands = [];
  List<String> selectedBrandsName = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        _fromPrice.text = arguments["_fromPrice"] ?? '';
        _toPrice.text = arguments["_toPrice"] ?? '';
        _startValue = arguments["_startValue"] ?? 0;
        _endValue = arguments["_endValue"] ?? 0;

        await getBrands();
        selectedBrands = arguments["selectedBrands"] ?? [];
        for (int selectedBrand in selectedBrands) {
          for (Map<String, dynamic> brand in brands) {
            if (brand["brand_id"] == selectedBrand) {
              selectedBrandsName.add(brand["name"]);
              break;
            }
          }
        }

        await getModels();
        selectedModels = arguments["selectedModels"] ?? [];
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getBrands() async {
    try {
      final response = await brandService.getBrandsData(perPage: 999999999);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            brands = response["data"];
            brandnames = brands.map((item) => item["name"] as String).toList();
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

  getModels() async {
    try {
      final response = await modelService.getModelsData(perPage: 999999999);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _fromFocusNode.unfocus();
        _toFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            language["Filters"] ?? "Filters",
            style: FontConstants.title1,
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      language["Price Range"] ?? "Price Range",
                      style: FontConstants.subheadline1,
                    ),
                  ),
                  RangeSlider(
                    values: RangeValues(_startValue, _endValue),
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: ColorConstants.borderColor,
                    onChanged: (RangeValues values) {
                      setState(() {
                        _startValue = values.start;
                        _endValue = values.end;
                        _fromPrice.text = _startValue.toString();
                        _toPrice.text = _endValue.toString();
                        // _fromPrice.text =
                        //     '${formatter.format(_startValue)}';
                        // _toPrice.text =
                        //     '${formatter.format(_endValue)}';
                      });
                    },
                    min: 0,
                    max: 500000,
                    divisions: 500,
                    labels: RangeLabels(
                      _startValue.toString(),
                      _endValue.toString(),
                    ),
                    // labels: RangeLabels(
                    //     '${formatter.format(_startValue)}',
                    //     '${formatter.format(_endValue)}'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 4,
                            top: 8,
                          ),
                          child: TextFormField(
                            controller: _fromPrice,
                            focusNode: _fromFocusNode,
                            // inputFormatters: [
                            //   CurrencyInputFormatter()
                            // ],
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: language["From"] ?? "From",
                              filled: true,
                              fillColor: ColorConstants.fillColor,
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
                            top: 8,
                          ),
                          child: TextFormField(
                            controller: _toPrice,
                            focusNode: _toFocusNode,
                            // inputFormatters: [
                            //   CurrencyInputFormatter()
                            // ],
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: language["To"] ?? "To",
                              filled: true,
                              fillColor: ColorConstants.fillColor,
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
                  SizedBox(
                    height: 16,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      language["Brands"] ?? "Brands",
                      style: FontConstants.subheadline1,
                    ),
                  ),
                  MultiSelectChip(
                    brandnames,
                    selectedBrandsName,
                    onSelectionChanged: (selectedList) {
                      setState(() {
                        selectedBrandsName = selectedList;
                      });
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      language["Models"] ?? "Models",
                      style: FontConstants.subheadline1,
                    ),
                  ),
                  MultiSelectChip(
                    models,
                    selectedModels,
                    onSelectionChanged: (selectedList) {
                      setState(() {
                        selectedModels = selectedList;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Row(
          children: [
            Expanded(
              child: FractionallySizedBox(
                widthFactor: 1,
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 0.5,
                      ),
                    ),
                    onPressed: () async {
                      _startValue = 0.0;
                      _endValue = 0.0;
                      _fromPrice.text = '';
                      _toPrice.text = '';
                      selectedModels = [];
                      selectedBrands = [];

                      Navigator.of(context).pop({
                        "_fromPrice": _fromPrice.text,
                        "_toPrice": _toPrice.text,
                        "_startValue": _startValue,
                        "_endValue": _endValue,
                        "selectedModels": selectedModels,
                        "selectedBrands": selectedBrands,
                      });
                    },
                    child: Text(
                      language["Reset"] ?? "Reset",
                      style: FontConstants.button4,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FractionallySizedBox(
                widthFactor: 1,
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
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
                      selectedBrands = [];
                      for (String selectedBrandName in selectedBrandsName) {
                        for (Map<String, dynamic> brand in brands) {
                          if (brand["name"] == selectedBrandName) {
                            selectedBrands.add(brand["brand_id"]);
                            break;
                          }
                        }
                      }

                      Navigator.of(context).pop({
                        "_fromPrice": _fromPrice.text,
                        "_toPrice": _toPrice.text,
                        "_startValue": _startValue,
                        "_endValue": _endValue,
                        "selectedModels": selectedModels,
                        "selectedBrands": selectedBrands,
                      });
                    },
                    child: Text(
                      language["Apply"] ?? "Apply",
                      style: FontConstants.button1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
