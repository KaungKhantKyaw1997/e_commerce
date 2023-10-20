import 'dart:convert';
import 'dart:io';

import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/currencies_service.dart';
import 'package:e_commerce/src/services/products_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:e_commerce/src/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class ProductSetupScreen extends StatefulWidget {
  const ProductSetupScreen({super.key});

  @override
  State<ProductSetupScreen> createState() => _ProductSetupScreenState();
}

class _ProductSetupScreenState extends State<ProductSetupScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final productsService = ProductsService();
  final currenciesService = CurrenciesService();
  FocusNode _modelFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _colorFocusNode = FocusNode();
  FocusNode _strapMaterialFocusNode = FocusNode();
  FocusNode _strapColorFocusNode = FocusNode();
  FocusNode _caseMaterialFocusNode = FocusNode();
  FocusNode _dialColorFocusNode = FocusNode();
  FocusNode _movementTypeFocusNode = FocusNode();
  FocusNode _waterResistanceFocusNode = FocusNode();
  FocusNode _warrantyPeriodFocusNode = FocusNode();
  FocusNode _dimensionsFocusNode = FocusNode();
  FocusNode _priceFocusNode = FocusNode();
  FocusNode _stockQuantityFocusNode = FocusNode();

  TextEditingController shopName = TextEditingController(text: '');
  int shopId = 0;
  TextEditingController categoryName = TextEditingController(text: '');
  int categoryId = 0;
  TextEditingController brandName = TextEditingController(text: '');
  int brandId = 0;
  TextEditingController model = TextEditingController(text: '');
  TextEditingController description = TextEditingController(text: '');
  TextEditingController color = TextEditingController(text: '');
  TextEditingController strapMaterial = TextEditingController(text: '');
  TextEditingController strapColor = TextEditingController(text: '');
  TextEditingController caseMaterial = TextEditingController(text: '');
  TextEditingController dialColor = TextEditingController(text: '');
  TextEditingController movementType = TextEditingController(text: '');
  TextEditingController waterResistance = TextEditingController(text: '');
  TextEditingController warrantyPeriod = TextEditingController(text: '');
  TextEditingController dimensions = TextEditingController(text: '');
  TextEditingController price = TextEditingController(text: '');
  TextEditingController stockQuantity = TextEditingController(text: '');
  bool isTopModel = false;
  List productImages = [];
  List<XFile> pickedMultiFile = <XFile>[];
  List currencies = [];
  List<String> currencycodes = [];
  int currencyId = 0;
  String currencyCode = '';

  int id = 0;
  String from = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await getCurrencies();
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        id = arguments["id"] ?? 0;
        from = arguments["from"] ?? '';
        if (from == 'shop') {
          shopId = arguments["shopId"] ?? 0;
          shopName.text = arguments["shopName"] ?? '';
        }
        getProduct();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getCurrencies() async {
    try {
      final response = await currenciesService.getCurrenciesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          currencies = response["data"];

          for (var data in response["data"]) {
            if (data["currency_code"] != null) {
              currencycodes.add(data["currency_code"]);
            }
          }
          currencyId = currencies[0]["currency_id"];
          currencyCode = currencies[0]["currency_code"];
          setState(() {});
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getProduct() async {
    try {
      final response = await productsService.getProductData(id);
      if (response!["code"] == 200) {
        setState(() {
          if (from != 'shop') {
            shopName.text = response["data"]["shop_name"] ?? "";
            shopId = response["data"]["shop_id"] ?? 0;
          }
          categoryName.text = response["data"]["category_name"] ?? "";
          categoryId = response["data"]["category_id"] ?? 0;
          brandName.text = response["data"]["brand_name"] ?? "";
          brandId = response["data"]["brand_id"] ?? 0;
          model.text = response["data"]["model"] ?? "";
          description.text = response["data"]["description"] ?? "";
          color.text = response["data"]["color"] ?? "";
          strapMaterial.text = response["data"]["strap_material"] ?? "";
          strapColor.text = response["data"]["strap_color"] ?? "";
          caseMaterial.text = response["data"]["case_material"] ?? "";
          dialColor.text = response["data"]["dial_color"] ?? "";
          movementType.text = response["data"]["movement_type"] ?? "";
          waterResistance.text = response["data"]["water_resistance"] ?? "";
          warrantyPeriod.text = response["data"]["warranty_period"] ?? "";
          dimensions.text = response["data"]["dimensions"] ?? "";
          price.text = response["data"]["price"].toString() ?? "";
          currencyCode = response["data"]["currency_code"] ?? "";
          currencyId = response["data"]["currency_id"] ?? 0;
          stockQuantity.text =
              response["data"]["stock_quantity"].toString() ?? "";
          isTopModel = response["data"]["is_top_model"] ?? false;
          productImages = response["data"]["product_images"] ?? [];
        });
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _pickMultiImage() async {
    try {
      pickedMultiFile = await ImagePicker().pickMultiImage();
      productImages = [];
      setState(() {});
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> uploadFile() async {
    for (var pickedFile in pickedMultiFile) {
      try {
        var response = await AuthService.uploadFile(File(pickedFile.path),
            resolution: "400x400");
        var res = jsonDecode(response.body);
        if (res["code"] == 200) {
          productImages.add(res["url"]);
        }
      } catch (error) {
        print('Error uploading file: $error');
      }
    }
  }

  addProduct() async {
    try {
      double _price = price.text.isEmpty
          ? 0.0
          : double.parse(price.text.replaceAll(',', ''));

      final body = {
        "shop_id": shopId,
        "category_id": categoryId,
        "brand_id": brandId,
        "model": model.text,
        "description": description.text,
        "color": color.text,
        "strap_material": strapMaterial.text,
        "strap_color": strapColor.text,
        "case_material": caseMaterial.text,
        "dial_color": dialColor.text,
        "movement_type": movementType.text,
        "water_resistance": waterResistance.text,
        "warranty_period": warrantyPeriod.text,
        "dimensions": dimensions.text,
        "price": _price,
        "currency_id": currencyId,
        "stock_quantity": int.parse(stockQuantity.text),
        "is_top_model": isTopModel,
        "product_images": productImages,
      };

      final response = await productsService.addProductData(body);
      Navigator.pop(context);
      if (response["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.products_setup,
          arguments: {
            if (from == 'shop') "shopId": shopId,
            if (from == 'shop') "shopName": shopName.text,
            "from": from,
          },
        );
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
    }
  }

  updateProduct() async {
    try {
      double _price = price.text.isEmpty
          ? 0.0
          : double.parse(price.text.replaceAll(',', ''));

      final body = {
        "shop_id": shopId,
        "category_id": categoryId,
        "brand_id": brandId,
        "model": model.text,
        "description": description.text,
        "color": color.text,
        "strap_material": strapMaterial.text,
        "strap_color": strapColor.text,
        "case_material": caseMaterial.text,
        "dial_color": dialColor.text,
        "movement_type": movementType.text,
        "water_resistance": waterResistance.text,
        "warranty_period": warrantyPeriod.text,
        "dimensions": dimensions.text,
        "price": _price,
        "currency_id": currencyId,
        "stock_quantity": int.parse(stockQuantity.text),
        "is_top_model": isTopModel,
        "product_images": productImages,
      };

      final response = await productsService.updateProductData(body, id);
      Navigator.pop(context);
      if (response["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.products_setup,
          arguments: {
            if (from == 'shop') "shopId": shopId,
            if (from == 'shop') "shopName": shopName.text,
            "from": from,
          },
        );
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
    }
  }

  deleteProduct() async {
    try {
      final response = await productsService.deleteProductData(id);
      Navigator.pop(context);
      if (response["code"] == 204) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.products_setup,
          arguments: {
            if (from == 'shop') "shopId": shopId,
            if (from == 'shop') "shopName": shopName.text,
            "from": from,
          },
        );
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
    }
  }

  Future<void> fetchCategoryData() async {
    var result = await Navigator.pushNamed(
      context,
      Routes.categories_setup,
      arguments: {
        "from": "product",
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        categoryId = result["category_id"] ?? 0;
        categoryName.text = result["name"] ?? "";
      });
    }
  }

  Future<void> fetchBrandData() async {
    var result = await Navigator.pushNamed(
      context,
      Routes.brands_setup,
      arguments: {
        "from": "product",
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        brandId = result["brand_id"] ?? 0;
        brandName.text = result["name"] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _modelFocusNode.unfocus();
        _descriptionFocusNode.unfocus();
        _colorFocusNode.unfocus();
        _strapMaterialFocusNode.unfocus();
        _strapColorFocusNode.unfocus();
        _caseMaterialFocusNode.unfocus();
        _dialColorFocusNode.unfocus();
        _movementTypeFocusNode.unfocus();
        _waterResistanceFocusNode.unfocus();
        _warrantyPeriodFocusNode.unfocus();
        _dimensionsFocusNode.unfocus();
        _priceFocusNode.unfocus();
        _stockQuantityFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            language["Product"] ?? "Product",
            style: FontConstants.title1,
          ),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                Routes.products_setup,
                arguments: {
                  if (from == 'shop') "shopId": shopId,
                  if (from == 'shop') "shopName": shopName.text,
                  "from": from,
                },
              );
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            Navigator.pushNamed(
              context,
              Routes.products_setup,
              arguments: {
                if (from == 'shop') "shopId": shopId,
                if (from == 'shop') "shopName": shopName.text,
                "from": from,
              },
            );
            return true;
          },
          child: SingleChildScrollView(
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
                    Container(
                      margin: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 4,
                      ),
                      child: productImages.isNotEmpty
                          ? GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 3,
                              children:
                                  List.generate(productImages.length, (index) {
                                return Image.network(
                                  '${ApiConstants.baseUrl}${productImages[index].toString()}',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );
                              }),
                            )
                          : pickedMultiFile.isNotEmpty
                              ? GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 3,
                                  children: List.generate(
                                      pickedMultiFile.length, (index) {
                                    return Image.file(
                                      File(pickedMultiFile[index]!.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    );
                                  }),
                                )
                              : Image.asset(
                                  'assets/images/logo.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _pickMultiImage,
                      child: Text(
                        language["Pick Images"] ?? "Pick Images",
                        style: FontConstants.button1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 4,
                        top: 24,
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
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        style: FontConstants.body2,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
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
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: TextFormField(
                        controller: categoryName,
                        readOnly: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        style: FontConstants.body2,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
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
                                Theme.of(context).primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
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
                          language["Brand"] ?? "Brand",
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
                        controller: brandName,
                        readOnly: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        style: FontConstants.body2,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
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
                                Theme.of(context).primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
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
                          language["Model"] ?? "Model",
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
                        controller: model,
                        focusNode: _modelFocusNode,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        style: FontConstants.body1,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return language["Enter Model"] ?? "Enter Model";
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
                          language["Description"] ?? "Description",
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
                        controller: description,
                        focusNode: _descriptionFocusNode,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        style: FontConstants.body1,
                        cursorColor: Colors.black,
                        maxLines: 2,
                        decoration: InputDecoration(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return language["Enter Description"] ??
                                "Enter Description";
                          }
                          return null;
                        },
                      ),
                    ),
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
                                    language["Color"] ?? "Color",
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
                                  controller: color,
                                  focusNode: _colorFocusNode,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: FontConstants.body1,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return language["Enter Color"] ??
                                          "Enter Color";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                    language["Movement Type"] ??
                                        "Movement Type",
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
                                  controller: movementType,
                                  focusNode: _movementTypeFocusNode,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: FontConstants.body1,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return language["Enter Movement Type"] ??
                                          "Enter Movement Type";
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
                                    language["Strap Material"] ??
                                        "Strap Material",
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
                                  controller: strapMaterial,
                                  focusNode: _strapMaterialFocusNode,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: FontConstants.body1,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return language["Enter Strap Material"] ??
                                          "Enter Strap Material";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                    language["Strap Color"] ?? "Strap Color",
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
                                  controller: strapColor,
                                  focusNode: _strapColorFocusNode,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: FontConstants.body1,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return language["Enter Strap Color"] ??
                                          "Enter Strap Color";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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
                                    language["Case Material"] ??
                                        "Case Material",
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
                                  controller: caseMaterial,
                                  focusNode: _caseMaterialFocusNode,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: FontConstants.body1,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return language["Enter Case Material"] ??
                                          "Enter Case Material";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                    language["Dial Color"] ?? "Dial Color",
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
                                  controller: dialColor,
                                  focusNode: _dialColorFocusNode,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: FontConstants.body1,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return language["Enter Dial Color"] ??
                                          "Enter Dial Color";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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
                                    language["Dimensions"] ?? "Dimensions",
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
                                  controller: dimensions,
                                  focusNode: _dimensionsFocusNode,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: FontConstants.body1,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return language["Enter Dimensions"] ??
                                          "Enter Dimensions";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                    language["Water Resistance"] ??
                                        "Water Resistance",
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
                                  controller: waterResistance,
                                  focusNode: _waterResistanceFocusNode,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: FontConstants.body1,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return language[
                                              "Enter Water Resistance"] ??
                                          "Enter Water Resistance";
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
                                    language["Stock Quantity"] ??
                                        "Stock Quantity",
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
                                  controller: stockQuantity,
                                  focusNode: _stockQuantityFocusNode,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  style: FontConstants.body1,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return language["Enter Stock Quantity"] ??
                                          "Enter Stock Quantity";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                    language["Warranty Period"] ??
                                        "Warranty Period",
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
                                  controller: warrantyPeriod,
                                  focusNode: _warrantyPeriodFocusNode,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  style: FontConstants.body1,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return language[
                                              "Enter Warranty Period"] ??
                                          "Enter Warranty Period";
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
                                    language["Currency"] ?? "Currency",
                                    style: FontConstants.caption1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 4,
                                  bottom: 4,
                                ),
                                child: CustomDropDown(
                                  value: currencyCode,
                                  fillColor: ColorConstants.fillcolor,
                                  onChanged: (newValue) {
                                    setState(() {
                                      currencyCode =
                                          newValue ?? currencycodes[0];
                                    });
                                    for (var data in currencies) {
                                      if (data["currency_code"] ==
                                          currencyCode) {
                                        currencyId = data["currency_id"];
                                      }
                                    }
                                  },
                                  items: currencycodes,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                    language["Price"] ?? "Price",
                                    style: FontConstants.caption1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  right: 16,
                                  bottom: 4,
                                ),
                                child: TextFormField(
                                  controller: price,
                                  focusNode: _priceFocusNode,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  style: FontConstants.body1,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return language["Enter Price"] ??
                                          "Enter Price";
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isTopModel,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (value) {
                            setState(() {
                              isTopModel = value ?? false;
                            });
                          },
                        ),
                        Text(
                          language["Top Model"] ?? "Top Model",
                          style: FontConstants.caption1,
                        ),
                      ],
                    ),
                  ],
                ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      showLoadingDialog(context);
                      if (pickedMultiFile.isNotEmpty) {
                        await uploadFile();
                      }
                      addProduct();
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: ColorConstants.redcolor,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              showLoadingDialog(context);
                              deleteProduct();
                            }
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              showLoadingDialog(context);
                              if (pickedMultiFile.isNotEmpty) {
                                await uploadFile();
                              }
                              updateProduct();
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
