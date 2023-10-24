import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/buyer_protections_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BuyerProtectionSetupScreen extends StatefulWidget {
  const BuyerProtectionSetupScreen({super.key});

  @override
  State<BuyerProtectionSetupScreen> createState() =>
      _buyer_protections_screenState();
}

class _buyer_protections_screenState extends State<BuyerProtectionSetupScreen> {
  final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final buyerProtectionsService = BuyerProtectionsService();
  FocusNode _descriptionFocusNode = FocusNode();
  TextEditingController description = TextEditingController(text: '');

  int id = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        id = arguments["id"] ?? 0;
        if (id != 0) {
          getBuyerProtectionData();
        }
      }
    });
  }

  getBuyerProtectionData() async {
    try {
      final response = await buyerProtectionsService.getBuyerProtectionData(id);
      if (response!["code"] == 200) {
        setState(() {
          description.text = response["data"]["description"] ?? "";
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

  addBuyerProtection() async {
    try {
      final body = {
        "description": description.text,
      };
      final response =
          await buyerProtectionsService.addBuyerProtectionData(body);
      Navigator.pop(context);
      if (response!["code"] == 201) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.buyer_protections_setup,
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

  updateBuyerProtection() async {
    try {
      final body = {
        "description": description.text,
      };
      final response =
          await buyerProtectionsService.updateBuyerProtectionData(body, id);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.buyer_protections_setup,
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

  deleteBuyerProtection() async {
    try {
      final response =
          await buyerProtectionsService.deleteBuyerProtectionData(id);
      Navigator.pop(context);
      if (response!["code"] == 204) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.buyer_protections_setup,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _descriptionFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            language["Buyer Protection"] ?? "Buyer Protection",
            style: FontConstants.title1,
          ),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                Routes.buyer_protections_setup,
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
              Routes.buyer_protections_setup,
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
                      ),
                      child: TextFormField(
                        controller: description,
                        focusNode: _descriptionFocusNode,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
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
                      addBuyerProtection();
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
                              deleteBuyerProtection();
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
                              updateBuyerProtection();
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
