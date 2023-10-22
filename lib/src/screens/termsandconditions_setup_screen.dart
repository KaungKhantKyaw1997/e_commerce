import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/termsandconditions_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsSetUpScreen extends StatefulWidget {
  const TermsAndConditionsSetUpScreen({super.key});

  @override
  State<TermsAndConditionsSetUpScreen> createState() =>
      _TermsAndConditionsSetUpScreenState();
}

class _TermsAndConditionsSetUpScreenState
    extends State<TermsAndConditionsSetUpScreen> {
  final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  final termsAndConditionsService = TermsAndConditionsService();
  final _formKey = GlobalKey<FormState>();
  TextEditingController content = TextEditingController(text: '');
  FocusNode _contentFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    getTermsAndConditions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getTermsAndConditions() async {
    try {
      final response =
          await termsAndConditionsService.getTermsAndConditionsData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          setState(() {
            content.text = response["data"];
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
      if (e is DioException && e.response?.statusCode == 401) {
        Navigator.pushNamed(
          context,
          Routes.unauthorized,
        );
      }
    }
  }

  addTermsAndConditions() async {
    try {
      final body = {
        "content": content.text,
      };

      final response =
          await termsAndConditionsService.addTermsAndConditionsData(body);
      Navigator.pop(context);
      if (response!["code"] == 201) {
        ToastUtil.showToast(response["code"], response["message"]);
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
      if (e is DioException && e.response?.statusCode == 401) {
        Navigator.pushNamed(
          context,
          Routes.unauthorized,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _contentFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            language["Terms & Conditions"] ?? "Terms & Conditions",
            style: FontConstants.title1,
          ),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            return true;
          },
          child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: TextFormField(
                controller: content,
                focusNode: _contentFocusNode,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                style: FontConstants.body1,
                cursorColor: Colors.black,
                maxLines: null,
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
                    return language["Enter Content"] ?? "Enter Content";
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
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
                addTermsAndConditions();
              }
            },
            child: Text(
              language["Save"] ?? "Save",
              style: FontConstants.button1,
            ),
          ),
        ),
      ),
    );
  }
}
