import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/seller_agreement_contract_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';

class SellerAgreementContractSetupScreen extends StatefulWidget {
  const SellerAgreementContractSetupScreen({super.key});

  @override
  State<SellerAgreementContractSetupScreen> createState() =>
      _SellerAgreementContractSetupScreenState();
}

class _SellerAgreementContractSetupScreenState
    extends State<SellerAgreementContractSetupScreen> {
  final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  final sellerAgreementContractService = SellerAgreementContractService();

  @override
  void initState() {
    super.initState();
    getSellerAgreementContract();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getSellerAgreementContract() async {
    try {
      final response =
          await sellerAgreementContractService.getSellerAgreementContractData();
      if (response!["code"] == 200) {
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

  addSellerAgreementContract() async {
    try {
      final body = {
        "file_path": "",
      };

      final response = await sellerAgreementContractService
          .addSellerAgreementContractData(body);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          language["Seller Agreement Contract"] ?? "Seller Agreement Contract",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
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
            showLoadingDialog(context);
            addSellerAgreementContract();
          },
          child: Text(
            language["Save"] ?? "Save",
            style: FontConstants.button1,
          ),
        ),
      ),
    );
  }
}
