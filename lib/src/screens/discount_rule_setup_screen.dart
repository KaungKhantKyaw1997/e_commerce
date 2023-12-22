import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/brand_service.dart';
import 'package:e_commerce/src/services/category_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/discount_rule_service.dart';
import 'package:e_commerce/src/services/product_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/range_text_input_formatter.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:e_commerce/src/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class DiscountRuleSetupScreen extends StatefulWidget {
  const DiscountRuleSetupScreen({super.key});

  @override
  State<DiscountRuleSetupScreen> createState() =>
      _DiscountRuleSetupScreenState();
}

class _DiscountRuleSetupScreenState extends State<DiscountRuleSetupScreen> {
  final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final productService = ProductService();
  final discountRuleService = DiscountRuleService();
  final categoryService = CategoryService();
  final brandService = BrandService();
  FocusNode _discountPriceFocusNode = FocusNode();
  FocusNode _discountPercentFocusNode = FocusNode();
  FocusNode _discountReasonFocusNode = FocusNode();

  TextEditingController shopName = TextEditingController(text: '');
  int shopId = 0;
  TextEditingController categoryName = TextEditingController(text: '');
  TextEditingController brandName = TextEditingController(text: '');
  TextEditingController discountFor = TextEditingController(text: '');
  TextEditingController discountType = TextEditingController(text: '');
  TextEditingController discountPercent = TextEditingController(text: '');
  TextEditingController discountPrice = TextEditingController(text: '');
  TextEditingController discountExpiration = TextEditingController(text: '');
  TextEditingController discountReason = TextEditingController(text: '');
  List<String> discountFors = [];
  List<String> discountTypes = [];
  int discountForId = 0;

  int id = 0;
  String role = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await getDiscountFors();
      await getDiscountTypes();
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        id = arguments["id"] ?? 0;
        role = arguments["role"] ?? "";
        if (id != 0) {
          getDiscountRule();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getDiscountFors() async {
    try {
      final response = await discountRuleService.getDiscountForsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            List<dynamic> dynamicList = response["data"];
            discountFors = dynamicList.map((item) => item.toString()).toList();
            discountFor.text = discountFors[0];
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

  getDiscountTypes() async {
    try {
      final response = await productService.getDiscountTypesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List<dynamic> dynamicList = response["data"];
          discountTypes = dynamicList.map((item) => item.toString()).toList();
          discountType.text = discountTypes[0];
          setState(() {});
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

  getDiscountRule() async {
    try {
      final response = await discountRuleService.getDiscountRuleData(id);
      if (response!["code"] == 200) {
        setState(() {
          shopName.text = response["data"]["shop_name"] ?? "";
          shopId = response["data"]["shop_id"] ?? 0;
          discountFor.text =
              response["data"]["discount_for"] ?? discountFors[0];
          discountForId = response["data"]["discount_for_id"] ?? 0;
          discountType.text = response["data"]["discount_type"] ?? "";
          discountExpiration.text =
              response["data"]["discount_expiration"] ?? "";
          if (discountExpiration.text.isNotEmpty) {
            DateTime expirationDateTime =
                DateTime.parse(discountExpiration.text);
            discountExpiration.text =
                DateFormat('dd/MM/yyyy').format(expirationDateTime);
          }
          discountPercent.text = response["data"]["discount_percent"] != 0.0
              ? response["data"]["discount_percent"].toString()
              : "";
          if (discountType.text == "Discount by Specific Amount") {
            discountPrice.text = response["data"]["discounted_price"] != 0.0
                ? response["data"]["discounted_price"].toString()
                : "";
          }
          discountReason.text = response["data"]["discount_reason"] ?? "";
        });

        if (discountFor.text == 'category') {
          getCategory(discountForId);
        } else if (discountFor.text == 'brand') {
          getBrand(discountForId);
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

  getCategory(id) async {
    try {
      final response = await categoryService.getCategoryData(id);
      if (response!["code"] == 200) {
        setState(() {
          categoryName.text = response["data"]["name"] ?? "";
        });
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

  getBrand(id) async {
    try {
      final response = await brandService.getBrandData(id);
      if (response!["code"] == 200) {
        setState(() {
          brandName.text = response["data"]["name"] ?? "";
        });
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

  Future<void> fetchShopData() async {
    var result = await Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.shops_setup,
      arguments: {
        "from": "discountrule",
        "role": role,
      },
      (route) => true,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        shopId = result["shop_id"] ?? 0;
        shopName.text = result["name"] ?? "";
      });
    }
  }

  Future<void> fetchCategoryData() async {
    var result = await Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.categories_setup,
      arguments: {
        "from": "discountrule",
      },
      (route) => true,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        discountForId = result["category_id"] ?? 0;
        categoryName.text = result["name"] ?? "";
      });
    }
  }

  Future<void> fetchBrandData() async {
    var result = await Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.brands_setup,
      arguments: {
        "from": "discountrule",
      },
      (route) => true,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        discountForId = result["brand_id"] ?? 0;
        brandName.text = result["name"] ?? "";
      });
    }
  }

  addDiscountRule() async {
    try {
      double price = discountPrice.text.isNotEmpty
          ? double.parse(discountPrice.text.replaceAll(',', ''))
          : 0.0;
      double percent = discountPercent.text.isNotEmpty
          ? double.parse(discountPercent.text.replaceAll(',', ''))
          : 0.0;
      final body = {
        "shop_id": shopId,
        "discount_for": discountFor.text,
        "discount_for_id": discountForId,
        "discount_type": discountType.text,
        "discount_expiration": DateFormat("yyyy-MM-dd")
            .format(DateFormat("dd/MM/yyyy").parse(discountExpiration.text))
            .toString(),
        "discounted_price": price,
        "discount_percent": percent,
        "discount_reason": discountReason.text,
      };

      final response = await discountRuleService.addDiscountRuleData(body);
      Navigator.pop(context);
      if (response!["code"] == 201) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.discount_rules_setup,
        );
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
      Navigator.pop(context);
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

  updateDiscountRule() async {
    try {
      double price = discountPrice.text.isNotEmpty
          ? double.parse(discountPrice.text.replaceAll(',', ''))
          : 0.0;
      double percent = discountPercent.text.isNotEmpty
          ? double.parse(discountPercent.text.replaceAll(',', ''))
          : 0.0;
      final body = {
        "shop_id": shopId,
        "discount_for": discountFor.text,
        "discount_for_id": discountForId,
        "discount_type": discountType.text,
        "discount_expiration": DateFormat("yyyy-MM-dd")
            .format(DateFormat("dd/MM/yyyy").parse(discountExpiration.text))
            .toString(),
        "discounted_price": price,
        "discount_percent": percent,
        "discount_reason": discountReason.text,
      };

      final response =
          await discountRuleService.updateDiscountRuleData(body, id);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.discount_rules_setup,
        );
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
      Navigator.pop(context);
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

  deleteDiscountRule() async {
    try {
      final response = await discountRuleService.deleteDiscountRuleData(id);
      Navigator.pop(context);
      if (response!["code"] == 204) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.discount_rules_setup,
        );
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
      Navigator.pop(context);
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

  getDate() async {
    var data = await _getDate();
    if (data != null) {
      discountExpiration.text =
          DateFormat("dd/MM/yyyy").format(data).toString();
    } else {
      discountExpiration.text = "";
    }
  }

  Future<DateTime?> _getDate() async {
    DateTime currentDate = DateTime.now();
    DateTime firstDate = currentDate;
    DateTime lastDate = DateTime(currentDate.year + 10);

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child ?? Container(),
        );
      },
    );

    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _discountPriceFocusNode.unfocus();
        _discountPercentFocusNode.unfocus();
        _discountReasonFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            language["Discount Rule"] ?? "Discount Rule",
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
              padding: EdgeInsets.symmetric(
                vertical: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language["Shop"] ?? "Shop",
                        style: FontConstants.caption1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: TextFormField(
                      controller: shopName,
                      readOnly: true,
                      style: FontConstants.body2,
                      decoration: InputDecoration(
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
                        suffixIcon: IconButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          onPressed: fetchShopData,
                          icon: SvgPicture.asset(
                            "assets/icons/shop.svg",
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return language["Enter Shop"] ?? "Enter Shop";
                        }
                        return null;
                      },
                    ),
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
                        language["Type"] ?? "Type",
                        style: FontConstants.caption1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: CustomDropDown(
                      value: discountFor.text,
                      fillColor: ColorConstants.fillColor,
                      onChanged: (newValue) {
                        setState(() {
                          discountFor.text = newValue ?? discountFors[0];
                        });
                      },
                      items: discountFors,
                    ),
                  ),
                  if (discountFor.text == 'category')
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 4,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          language["Category"] ?? "Category",
                          style: FontConstants.caption1,
                        ),
                      ),
                    ),
                  if (discountFor.text == 'category')
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: TextFormField(
                        controller: categoryName,
                        readOnly: true,
                        style: FontConstants.body2,
                        decoration: InputDecoration(
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
                          suffixIcon: IconButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            onPressed: fetchCategoryData,
                            icon: SvgPicture.asset(
                              "assets/icons/category.svg",
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return language["Enter Category"] ??
                                "Enter Category";
                          }
                          return null;
                        },
                      ),
                    ),
                  if (discountFor.text == 'brand')
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 4,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          language["Brand"] ?? "Brand",
                          style: FontConstants.caption1,
                        ),
                      ),
                    ),
                  if (discountFor.text == 'brand')
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: TextFormField(
                        controller: brandName,
                        readOnly: true,
                        style: FontConstants.body2,
                        decoration: InputDecoration(
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
                          suffixIcon: IconButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            onPressed: fetchBrandData,
                            icon: SvgPicture.asset(
                              "assets/icons/brand.svg",
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return language["Enter Brand"] ?? "Enter Brand";
                          }
                          return null;
                        },
                      ),
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
                        language["Discount Type"] ?? "Discount Type",
                        style: FontConstants.caption1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: CustomDropDown(
                      value: discountType.text,
                      fillColor: ColorConstants.fillColor,
                      onChanged: (newValue) {
                        setState(() {
                          discountType.text = newValue ?? discountTypes[0];
                          discountExpiration.text = "";
                          discountPrice.text = "";
                          discountPercent.text = "";
                          discountReason.text = "";
                        });
                      },
                      items: discountTypes,
                    ),
                  ),
                  if (discountType.text != 'No Discount')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 4,
                                  bottom: 4,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    language["Discount Expiration"] ??
                                        "Discount Expiration",
                                    style: FontConstants.caption1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 4,
                                  bottom: 16,
                                ),
                                child: TextFormField(
                                  controller: discountExpiration,
                                  readOnly: true,
                                  style: FontConstants.body2,
                                  decoration: InputDecoration(
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
                                    suffixIcon: IconButton(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      onPressed: () {
                                        getDate();
                                      },
                                      icon: SvgPicture.asset(
                                        "assets/icons/calendar.svg",
                                        width: 24,
                                        height: 24,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (discountType.text == "Discount by Specific Amount")
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    right: 16,
                                    bottom: 4,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      language["Discount Price"] ??
                                          "Discount Price",
                                      style: FontConstants.caption1,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    right: 16,
                                    bottom: 16,
                                  ),
                                  child: TextFormField(
                                    controller: discountPrice,
                                    focusNode: _discountPriceFocusNode,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    style: FontConstants.body1,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: ColorConstants.fillColor,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return language[
                                                "Enter Discount Price"] ??
                                            "Enter Discount Price";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (discountType.text ==
                            "Discount by Specific Percentage")
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    right: 16,
                                    bottom: 4,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      language["Discount Percent"] ??
                                          "Discount Percent",
                                      style: FontConstants.caption1,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    right: 16,
                                    bottom: 16,
                                  ),
                                  child: TextFormField(
                                    controller: discountPercent,
                                    focusNode: _discountPercentFocusNode,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,1}$')),
                                      FilteringTextInputFormatter
                                          .singleLineFormatter,
                                      RangeTextInputFormatter(min: 0, max: 100),
                                    ],
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    style: FontConstants.body1,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: ColorConstants.fillColor,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                      suffixIcon: IconButton(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        onPressed: null,
                                        icon: SvgPicture.asset(
                                          "assets/icons/percent.svg",
                                          width: 24,
                                          height: 24,
                                          colorFilter: ColorFilter.mode(
                                            Colors.black,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return language[
                                                "Enter Discount Percent"] ??
                                            "Enter Discount Percent";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  if (discountType.text != 'No Discount')
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 4,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          language["Discount Reason"] ?? "Discount Reason",
                          style: FontConstants.caption1,
                        ),
                      ),
                    ),
                  if (discountType.text != 'No Discount')
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: TextFormField(
                        controller: discountReason,
                        focusNode: _discountReasonFocusNode,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        style: FontConstants.body1,
                        cursorColor: Colors.black,
                        maxLines: 2,
                        decoration: InputDecoration(
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
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: id == 0
            ? Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 24,
                ),
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
                    if (_formKey.currentState!.validate()) {
                      showLoadingDialog(context);
                      addDiscountRule();
                    }
                  },
                  child: Text(
                    language["Save"] ?? "Save",
                    style: FontConstants.button1,
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 24,
                        ),
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
                            backgroundColor: ColorConstants.redColor,
                          ),
                          onPressed: () async {
                            showLoadingDialog(context);
                            deleteDiscountRule();
                          },
                          child: Text(
                            language["Delete"] ?? "Delete",
                            style: FontConstants.button1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 24,
                        ),
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
                            if (_formKey.currentState!.validate()) {
                              showLoadingDialog(context);
                              updateDiscountRule();
                            }
                          },
                          child: Text(
                            language["Update"] ?? "Update",
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
