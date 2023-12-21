import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/currency_service.dart';
import 'package:e_commerce/src/services/gender_service.dart';
import 'package:e_commerce/src/services/product_service.dart';
import 'package:e_commerce/src/services/user_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/range_text_input_formatter.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:e_commerce/src/widgets/custom_autocomplete.dart';
import 'package:e_commerce/src/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_extend/share_extend.dart';

class ProductSetupScreen extends StatefulWidget {
  const ProductSetupScreen({super.key});

  @override
  State<ProductSetupScreen> createState() => _ProductSetupScreenState();
}

class _ProductSetupScreenState extends State<ProductSetupScreen> {
  final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final productService = ProductService();
  final currencyService = CurrencyService();
  final userService = UserService();
  final genderService = GenderService();

  FocusNode _modelFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _colorFocusNode = FocusNode();
  FocusNode _strapColorFocusNode = FocusNode();
  FocusNode _dialColorFocusNode = FocusNode();
  FocusNode _movementCaliberFocusNode = FocusNode();
  FocusNode _priceFocusNode = FocusNode();
  FocusNode _warrantyPeriodFocusNode = FocusNode();
  FocusNode _waitingTimeFocusNode = FocusNode();
  FocusNode _discountPriceFocusNode = FocusNode();
  FocusNode _discountPercentFocusNode = FocusNode();
  FocusNode _discountReasonFocusNode = FocusNode();

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
  TextEditingController caseDiameter = TextEditingController(text: '');
  TextEditingController caseDepth = TextEditingController(text: '');
  TextEditingController caseWidth = TextEditingController(text: '');
  TextEditingController dialGlassTypeDesc = TextEditingController(text: '');
  int dialGlassTypeId = 0;
  TextEditingController dialColor = TextEditingController(text: '');
  TextEditingController movementType = TextEditingController(text: '');
  TextEditingController movementCountry = TextEditingController(text: '');
  TextEditingController movementCaliber = TextEditingController(text: '');
  TextEditingController currencyCode = TextEditingController(text: '');
  int currencyId = 0;
  TextEditingController stockQuantity = TextEditingController(text: '0');
  TextEditingController price = TextEditingController(text: '');
  TextEditingController waterResistance = TextEditingController(text: '');
  TextEditingController warrantyPeriod = TextEditingController(text: '');
  TextEditingController waitingTime = TextEditingController(text: '');
  TextEditingController discountType = TextEditingController(text: '');
  TextEditingController discountPercent = TextEditingController(text: '');
  TextEditingController discountPrice = TextEditingController(text: '');
  TextEditingController discountExpiration = TextEditingController(text: '');
  TextEditingController discountReason = TextEditingController(text: '');
  bool isTopModel = false;
  bool isPreorder = false;
  List productImages = [];
  List<XFile> pickedMultiFile = <XFile>[];

  List currencies = [];
  List<String> currencyCodes = [];

  List warrantyTypes = [];
  List<String> warrantyTypesDesc = [];
  int warrantyTypeId = 0;
  String warrantyTypeDesc = '';

  List dialglassTypes = [];
  List<String> dialglassTypesDesc = [];

  List conditions = [];
  List<String> conditionsDesc = [];
  String conditionDesc = '';

  List otherAccessoriesTypes = [];
  List<String> otherAccessoriesTypesDesc = [];
  int otherAccessoriesTypeId = 0;
  String otherAccessoriesTypeDesc = '';

  List genders = [];
  List<String> gendersDesc = [];
  int genderId = 0;
  String genderDesc = '';

  List<String> strapMaterials = [];
  List<String> caseMaterials = [];
  List<String> caseDiameters = [];
  List<String> caseDepths = [];
  List<String> caseWidths = [];
  List<String> movementTypes = [];
  List<String> movementCountries = [];
  List<String> stockQuantities = [];
  List<String> waterResistances = [];
  List<String> discountTypes = [];
  // double discountPercent = 0.0;

  int id = 0;
  String from = '';

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      getGenders();
      getStrapMaterials();
      getCaseMaterials();
      getCaseDiameters();
      getCaseDepths();
      getCaseWidths();
      getDialGlassTypes();
      getConditions();
      getMovementTypes();
      getMovementCountries();
      getCurrencies();
      getStockQuantities();
      getDiscountTypes();
      getWaterResistances();
      getWarrantyTypes();
      getOtherAccessoriesTypes();

      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        id = arguments["id"] ?? 0;
        from = arguments["from"] ?? '';
        if (from == 'shop') {
          shopId = arguments["shopId"] ?? 0;
          shopName.text = arguments["shopName"] ?? '';
        }
        if (id != 0) {
          showLoadingDialog(context);
          await Future.delayed(Duration(milliseconds: 200));
          getProduct();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getGenders() async {
    try {
      final response = await genderService.getGendersData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          genders = response["data"];

          for (var data in response["data"]) {
            if (data["description"] != null) {
              gendersDesc.add(data["description"]);
            }
          }
          genderId = genders[0]["gender_id"];
          genderDesc = genders[0]["description"];
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

  getStrapMaterials() async {
    try {
      final response = await productService.getStrapMaterialsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List<dynamic> dynamicList = response["data"];
          strapMaterials = dynamicList.map((item) => item.toString()).toList();
          strapMaterial.text = strapMaterials[0];
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

  getCaseMaterials() async {
    try {
      final response = await productService.getCaseMaterialsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List<dynamic> dynamicList = response["data"];
          caseMaterials = dynamicList.map((item) => item.toString()).toList();
          caseMaterial.text = caseMaterials[0];
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

  getCaseDiameters() async {
    try {
      final response = await productService.getCaseDiametersData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List<dynamic> dynamicList = response["data"];
          caseDiameters = dynamicList.map((item) => item.toString()).toList();
          caseDiameter.text = caseDiameters[0];
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

  getCaseDepths() async {
    try {
      final response = await productService.getCaseDepthsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List<dynamic> dynamicList = response["data"];
          caseDepths = dynamicList.map((item) => item.toString()).toList();
          caseDepth.text = caseDepths[0];
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

  getCaseWidths() async {
    try {
      final response = await productService.getCaseWidthsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List<dynamic> dynamicList = response["data"];
          caseWidths = dynamicList.map((item) => item.toString()).toList();
          caseWidth.text = caseWidths[0];
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

  getDialGlassTypes() async {
    try {
      final response = await productService.getDialGlassTypesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          dialglassTypes = response["data"];

          for (var data in response["data"]) {
            if (data["description"] != null) {
              dialglassTypesDesc.add(data["description"]);
            }
          }
          dialGlassTypeId = dialglassTypes[0]["dial_glass_type_id"];
          dialGlassTypeDesc.text = dialglassTypes[0]["description"];
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

  getConditions() async {
    try {
      final response = await productService.getConditionsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          conditions = response["data"];

          for (var data in response["data"]) {
            if (data["description"] != null) {
              conditionsDesc.add(data["description"]);
            }
          }
          conditionDesc = conditions[0]["description"];
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

  getMovementTypes() async {
    try {
      final response = await productService.getMovementTypesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List<dynamic> dynamicList = response["data"];
          movementTypes = dynamicList.map((item) => item.toString()).toList();
          movementType.text = movementTypes[0];
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

  getMovementCountries() async {
    try {
      final response = await productService.getMovementCountriesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List<dynamic> dynamicList = response["data"];
          movementCountries =
              dynamicList.map((item) => item.toString()).toList();
          movementCountry.text = movementCountries[0];
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

  getCurrencies() async {
    try {
      final response = await currencyService.getCurrenciesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          currencies = response["data"];

          for (var data in response["data"]) {
            if (data["currency_code"] != null) {
              currencyCodes.add(data["currency_code"]);
            }
          }
          currencyId = currencies[0]["currency_id"];
          currencyCode.text = currencies[0]["currency_code"];
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

  getStockQuantities() async {
    try {
      final response = await productService.getStockQuantitiesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List<dynamic> dynamicList = response["data"];
          stockQuantities = dynamicList.map((item) => item.toString()).toList();
          stockQuantity.text = stockQuantities[0];
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

  getDiscountTypes() async {
    try {
      final response = await productService.getDiscountTypesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List<dynamic> dynamicList = response["data"];
          discountTypes = dynamicList.map((item) => item.toString()).toList();
          waterResistance.text = discountTypes[0];
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

  getWaterResistances() async {
    try {
      final response = await productService.getWaterResistancesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List<dynamic> dynamicList = response["data"];
          waterResistances =
              dynamicList.map((item) => item.toString()).toList();
          waterResistance.text = waterResistances[0];
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

  getWarrantyTypes() async {
    try {
      final response = await productService.getWarrantyTypesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          warrantyTypes = response["data"];

          for (var data in response["data"]) {
            if (data["description"] != null) {
              warrantyTypesDesc.add(data["description"]);
            }
          }
          warrantyTypeId = warrantyTypes[0]["warranty_type_id"];
          warrantyTypeDesc = warrantyTypes[0]["description"];
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

  getOtherAccessoriesTypes() async {
    try {
      final response = await productService.getOtherAccessoriesTypesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          otherAccessoriesTypes = response["data"];

          for (var data in response["data"]) {
            if (data["description"] != null) {
              otherAccessoriesTypesDesc.add(data["description"]);
            }
          }
          otherAccessoriesTypeId =
              otherAccessoriesTypes[0]["other_accessories_type_id"];
          otherAccessoriesTypeDesc = otherAccessoriesTypes[0]["description"];
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

  getProduct() async {
    try {
      final response = await productService.getProductData(id);
      if (response!["code"] == 200) {
        setState(() {
          productImages = response["data"]["product_images"] ?? [];
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
          genderDesc = response["data"]["gender_description"] ?? "";
          genderId = response["data"]["gender_id"] ?? 0;
          color.text = response["data"]["color"] ?? "";
          strapMaterial.text = response["data"]["strap_material"] ?? "";
          strapColor.text = response["data"]["strap_color"] ?? "";
          caseMaterial.text = response["data"]["case_material"] ?? "";
          caseDiameter.text = response["data"]["case_diameter"] ?? "";
          caseDepth.text = response["data"]["case_depth"] ?? "";
          caseWidth.text = response["data"]["case_width"] ?? "";
          dialGlassTypeDesc.text =
              response["data"]["dial_glass_type_description"] ?? "";
          dialGlassTypeId = response["data"]["dial_glass_type_id"] ?? 0;
          dialColor.text = response["data"]["dial_color"] ?? "";
          conditionDesc = response["data"]["condition"] ?? "";
          movementType.text = response["data"]["movement_type"] ?? "";
          movementCountry.text = response["data"]["movement_country"] ?? "";
          movementCaliber.text = response["data"]["movement_caliber"] ?? "";
          currencyCode.text = response["data"]["currency_code"] ?? "";
          currencyId = response["data"]["currency_id"] ?? 0;
          stockQuantity.text = response["data"]["stock_quantity"] != 0
              ? response["data"]["stock_quantity"].toString()
              : "0";
          price.text = response["data"]["price"] != 0.0
              ? response["data"]["price"].toString()
              : "";
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
          waterResistance.text = response["data"]["water_resistance"] ?? "";
          warrantyPeriod.text = response["data"]["warranty_period"] ?? "";
          warrantyTypeDesc =
              response["data"]["warranty_type_description"] ?? "";
          warrantyTypeId = response["data"]["warranty_type_id"] ?? 0;
          otherAccessoriesTypeDesc =
              response["data"]["other_accessories_type_description"] ?? "";
          otherAccessoriesTypeId =
              response["data"]["other_accessories_type_id"] ?? 0;
          isTopModel = response["data"]["is_top_model"] ?? false;
          isPreorder = response["data"]["is_preorder"] ?? false;
          waitingTime.text = response["data"]["waiting_time"] ?? "";
        });
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
      Navigator.pop(context);
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
            resolution: "800x800");
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
        "movement_country": movementCountry.text,
        "movement_caliber": movementCaliber.text,
        "water_resistance": waterResistance.text,
        "warranty_period": warrantyPeriod.text,
        "dimensions": "",
        "price": _price,
        "stock_quantity": int.parse(stockQuantity.text),
        "is_top_model": isTopModel,
        "product_images": productImages,
        "currency_id": currencyId,
        "condition": conditionDesc,
        "warranty_type_id": warrantyTypeId,
        "dial_glass_type_id": dialGlassTypeId,
        "other_accessories_type_id": otherAccessoriesTypeId,
        "gender_id": genderId,
        "is_preorder": isPreorder,
        "waiting_time": waitingTime.text,
        "case_diameter": caseDiameter.text,
        "case_depth": caseDepth.text,
        "case_width": caseWidth.text,
        "discount_type": discountType.text,
      };

      if (discountType.text != 'No Discount') {
        if (discountExpiration.text.isNotEmpty) {
          body["discount_expiration"] = DateFormat("yyyy-MM-dd")
              .format(DateFormat("dd/MM/yyyy").parse(discountExpiration.text))
              .toString();
        }
        if (discountPrice.text.isNotEmpty) {
          body["discounted_price"] =
              double.parse(discountPrice.text.replaceAll(',', ''));
        }
        if (discountPercent.text.isNotEmpty) {
          body["discount_percent"] =
              double.parse(discountPercent.text.replaceAll(',', ''));
        }
        body["discount_reason"] = discountReason.text;
      }

      final response = await productService.addProductData(body);
      Navigator.pop(context);
      if (response!["code"] == 201) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
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
        "movement_country": movementCountry.text,
        "movement_caliber": movementCaliber.text,
        "water_resistance": waterResistance.text,
        "warranty_period": warrantyPeriod.text,
        "dimensions": "",
        "price": _price,
        "currency_id": currencyId,
        "stock_quantity": int.parse(stockQuantity.text),
        "is_top_model": isTopModel,
        "product_images": productImages,
        "condition": conditionDesc,
        "warranty_type_id": warrantyTypeId,
        "dial_glass_type_id": dialGlassTypeId,
        "other_accessories_type_id": otherAccessoriesTypeId,
        "gender_id": genderId,
        "is_preorder": isPreorder,
        "waiting_time": waitingTime.text,
        "case_diameter": caseDiameter.text,
        "case_depth": caseDepth.text,
        "case_width": caseWidth.text,
        "discount_type": discountType.text,
      };

      if (discountType.text != 'No Discount') {
        if (discountExpiration.text.isNotEmpty) {
          body["discount_expiration"] = DateFormat("yyyy-MM-dd")
              .format(DateFormat("dd/MM/yyyy").parse(discountExpiration.text))
              .toString();
        }
        if (discountPrice.text.isNotEmpty) {
          body["discounted_price"] =
              double.parse(discountPrice.text.replaceAll(',', ''));
        }
        if (discountPercent.text.isNotEmpty) {
          body["discount_percent"] =
              double.parse(discountPercent.text.replaceAll(',', ''));
        }
        body["discount_reason"] = discountReason.text;
      }

      final response = await productService.updateProductData(body, id);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
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

  deleteProduct() async {
    try {
      final response = await productService.deleteProductData(id);
      Navigator.pop(context);
      if (response!["code"] == 204) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
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

  Future<void> fetchCategoryData() async {
    var result = await Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.categories_setup,
      arguments: {
        "from": "product",
      },
      (route) => true,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        categoryId = result["category_id"] ?? 0;
        categoryName.text = result["name"] ?? "";
      });
    }
  }

  Future<void> fetchBrandData() async {
    var result = await Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.brands_setup,
      arguments: {
        "from": "product",
      },
      (route) => true,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        brandId = result["brand_id"] ?? 0;
        brandName.text = result["name"] ?? "";
      });
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
        _modelFocusNode.unfocus();
        _descriptionFocusNode.unfocus();
        _colorFocusNode.unfocus();
        _strapColorFocusNode.unfocus();
        _dialColorFocusNode.unfocus();
        _warrantyPeriodFocusNode.unfocus();
        _movementCaliberFocusNode.unfocus();
        _priceFocusNode.unfocus();
        _waitingTimeFocusNode.unfocus();
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
            language["Product"] ?? "Product",
            style: FontConstants.title1,
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          actions: [
            if (id != 0)
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/share.svg",
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  var url = ('${brandName.text} ${model.text} ${id}.html')
                      .toLowerCase()
                      .replaceAll(" ", "-");
                  ShareExtend.share(
                    'http://www.watchvaultbydiggie.com/products/$url',
                    "text",
                  );
                },
              ),
          ],
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
                                children: List.generate(pickedMultiFile.length,
                                    (index) {
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
                    onPressed: _pickMultiImage,
                    child: Text(
                      language["Pick Images"] ?? "Pick Images",
                      style: FontConstants.button1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
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
                                  language["Gender"] ?? "Gender",
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
                              child: CustomDropDown(
                                value: genderDesc,
                                fillColor: ColorConstants.fillColor,
                                onChanged: (newValue) {
                                  setState(() {
                                    genderDesc = newValue ?? gendersDesc[0];
                                  });
                                  for (var data in genders) {
                                    if (data["description"] == genderDesc) {
                                      genderId = data["gender_id"];
                                    }
                                  }
                                },
                                items: gendersDesc,
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
                                  language["Color"] ?? "Color",
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
                                controller: color,
                                focusNode: _colorFocusNode,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                style: FontConstants.body1,
                                cursorColor: Colors.black,
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
                              child: CustomAutocomplete(
                                datalist: strapMaterials,
                                textController: strapMaterial,
                                onSelected: (String selection) {
                                  strapMaterial.text = selection;
                                },
                                onChanged: (String value) {
                                  strapMaterial.text = value;
                                },
                                maxWidth: 176,
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
                                  language["Case Material"] ?? "Case Material",
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
                              child: CustomAutocomplete(
                                datalist: caseMaterials,
                                textController: caseMaterial,
                                onSelected: (String selection) {
                                  caseMaterial.text = selection;
                                },
                                onChanged: (String value) {
                                  caseMaterial.text = value;
                                },
                                maxWidth: 176,
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
                                  language["Case Diameter"] ?? "Case Diameter",
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
                              child: CustomAutocomplete(
                                datalist: caseDiameters,
                                textController: caseDiameter,
                                onSelected: (String selection) {
                                  caseDiameter.text = selection;
                                },
                                onChanged: (String value) {
                                  caseDiameter.text = value;
                                },
                                maxWidth: 176,
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
                                  language["Case Depth"] ?? "Case Depth",
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
                              child: CustomAutocomplete(
                                datalist: caseDepths,
                                textController: caseDepth,
                                onSelected: (String selection) {
                                  caseDepth.text = selection;
                                },
                                onChanged: (String value) {
                                  caseDepth.text = value;
                                },
                                maxWidth: 176,
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
                                  language["Case Width"] ?? "Case Width",
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
                              child: CustomAutocomplete(
                                datalist: caseWidths,
                                textController: caseWidth,
                                onSelected: (String selection) {
                                  caseWidth.text = selection;
                                },
                                onChanged: (String value) {
                                  caseWidth.text = value;
                                },
                                maxWidth: 176,
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
                                  language["Dial Glass Type"] ??
                                      "Dial Glass Type",
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
                              child: CustomAutocomplete(
                                datalist: dialglassTypesDesc,
                                textController: dialGlassTypeDesc,
                                onSelected: (String selection) {
                                  dialGlassTypeDesc.text = selection;

                                  for (var data in dialglassTypes) {
                                    if (data["description"] ==
                                        dialGlassTypeDesc.text) {
                                      dialGlassTypeId =
                                          data["dial_glass_type_id"];
                                    }
                                  }
                                },
                                onChanged: (String value) {
                                  dialGlassTypeDesc.text = value;

                                  for (var data in dialglassTypes) {
                                    if (data["description"] ==
                                        dialGlassTypeDesc.text) {
                                      dialGlassTypeId =
                                          data["dial_glass_type_id"];
                                    }
                                  }
                                },
                                maxWidth: 176,
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
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language["Condition"] ?? "Condition",
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
                      value: conditionDesc,
                      fillColor: ColorConstants.fillColor,
                      onChanged: (newValue) {
                        setState(() {
                          conditionDesc = newValue ?? conditionsDesc[0];
                        });
                      },
                      items: conditionsDesc,
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
                                  language["Movement Country"] ??
                                      "Movement Country",
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
                              child: CustomAutocomplete(
                                datalist: movementCountries,
                                textController: movementCountry,
                                onSelected: (String selection) {
                                  movementCountry.text = selection;
                                },
                                onChanged: (String value) {
                                  movementCountry.text = value;
                                },
                                maxWidth: 176,
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
                                  language["Movement Type"] ?? "Movement Type",
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
                              child: CustomAutocomplete(
                                datalist: movementTypes,
                                textController: movementType,
                                onSelected: (String selection) {
                                  movementType.text = selection;
                                },
                                onChanged: (String value) {
                                  movementType.text = value;
                                },
                                maxWidth: 176,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
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
                        language["Movement Caliber"] ?? "Movement Caliber",
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
                      controller: movementCaliber,
                      focusNode: _movementCaliberFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      style: FontConstants.body1,
                      cursorColor: Colors.black,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return language["Enter Movement Caliber"] ??
                              "Enter Movement Caliber";
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
                                  language["Currency"] ?? "Currency",
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
                              child: CustomAutocomplete(
                                datalist: currencyCodes,
                                textController: currencyCode,
                                onSelected: (String selection) {
                                  currencyCode.text = selection;

                                  for (var data in currencies) {
                                    if (data["currency_code"] ==
                                        currencyCode.text) {
                                      currencyId = data["currency_id"];
                                    }
                                  }
                                },
                                onChanged: (String value) {
                                  currencyCode.text = value;

                                  for (var data in currencies) {
                                    if (data["currency_code"] ==
                                        currencyCode.text) {
                                      currencyId = data["currency_id"];
                                    }
                                  }
                                },
                                maxWidth: 176,
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
                                bottom: 16,
                              ),
                              child: CustomAutocomplete(
                                datalist: stockQuantities,
                                textController: stockQuantity,
                                onSelected: (String selection) {
                                  stockQuantity.text = selection;
                                },
                                onChanged: (String value) {
                                  stockQuantity.text = value;
                                },
                                maxWidth: 130,
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
                                bottom: 16,
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
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //     left: 16,
                  //     right: 16,
                  //     bottom: 4,
                  //   ),
                  //   child: Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Text(
                  //       "${language["Discount Percent"] ?? "Discount Percent"}: ${discountPercent}%",
                  //       style: FontConstants.caption1,
                  //     ),
                  //   ),
                  // ),
                  // Slider(
                  //   value: discountPercent * 10,
                  //   max: 1000,
                  //   divisions: 1000,
                  //   label: (discountPercent * 10 / 10).toString(),
                  //   thumbColor: Theme.of(context).primaryColorLight,
                  //   activeColor: Theme.of(context).primaryColor,
                  //   inactiveColor: ColorConstants.borderColor,
                  //   onChanged: (double value) {
                  //     setState(() {
                  //       discountPercent = value / 10;
                  //     });
                  //   },
                  // ),
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
                                  language["Water Resistance"] ??
                                      "Water Resistance",
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
                              child: CustomAutocomplete(
                                datalist: waterResistances,
                                textController: waterResistance,
                                onSelected: (String selection) {
                                  waterResistance.text = selection;
                                },
                                onChanged: (String value) {
                                  waterResistance.text = value;
                                },
                                maxWidth: 130,
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return language["Enter Warranty Period"] ??
                                        "Enter Warranty Period";
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
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language["Warranty Type"] ?? "Warranty Type",
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
                      value: warrantyTypeDesc,
                      fillColor: ColorConstants.fillColor,
                      onChanged: (newValue) {
                        setState(() {
                          warrantyTypeDesc = newValue ?? warrantyTypesDesc[0];
                        });
                        for (var data in warrantyTypes) {
                          if (data["description"] == warrantyTypeDesc) {
                            warrantyTypeId = data["warranty_type_id"];
                          }
                        }
                      },
                      items: warrantyTypesDesc,
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
                        language["Other Accessories"] ?? "Other Accessories",
                        style: FontConstants.caption1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 4,
                    ),
                    child: CustomDropDown(
                      value: otherAccessoriesTypeDesc,
                      fillColor: ColorConstants.fillColor,
                      onChanged: (newValue) {
                        setState(() {
                          otherAccessoriesTypeDesc =
                              newValue ?? otherAccessoriesTypesDesc[0];
                        });
                        for (var data in otherAccessoriesTypes) {
                          if (data["description"] == otherAccessoriesTypeDesc) {
                            otherAccessoriesTypeId =
                                data["other_accessories_type_id"];
                          }
                        }
                      },
                      items: otherAccessoriesTypesDesc,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 16,
                          ),
                          child: Row(
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
                              Expanded(
                                child: Text(
                                  language["Top Model"] ?? "Top Model",
                                  style: FontConstants.caption1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: isPreorder,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    isPreorder = value ?? false;
                                    if (!isPreorder) {
                                      waitingTime.text = "";
                                    }
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  language["Preorder"] ?? "Preorder",
                                  style: FontConstants.caption1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  isPreorder
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 4,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              language["Waiting Time"] ?? "Waiting Time",
                              style: FontConstants.caption1,
                            ),
                          ),
                        )
                      : Container(),
                  isPreorder
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                          child: TextFormField(
                            controller: waitingTime,
                            focusNode: _waitingTimeFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: FontConstants.body1,
                            cursorColor: Colors.black,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return language["Enter Waiting Time"] ??
                                    "Enter Waiting Time";
                              }
                              return null;
                            },
                          ),
                        )
                      : Container(),
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
                            deleteProduct();
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
