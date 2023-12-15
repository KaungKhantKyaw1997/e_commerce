import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/seller_agreement_contract_service.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
  final _formKey = GlobalKey<FormState>();
  TextEditingController file = TextEditingController(text: '');
  File? pickedFile;
  String filePath = "";
  bool existFile = false;

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
        if (response["data"].isNotEmpty) {
          setState(() {
            existFile = true;
            filePath = response["data"];
            file.text = response["data"];
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
        }
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        existFile = false;
        file.text = result.files.single.name;
        pickedFile = File(result.files.single.path!);
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile() async {
    try {
      var response = await AuthService.uploadFile(File(pickedFile!.path));
      var res = jsonDecode(response.body);
      if (res["code"] == 200) {
        filePath = res["url"];
      }
    } catch (error) {
      print('Error uploading file: $error');
    }
  }

  addSellerAgreementContract() async {
    try {
      final body = {
        "file_path": filePath,
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
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    language["File"] ?? "File",
                    style: FontConstants.caption1,
                  ),
                ),
              ),
              TextFormField(
                controller: file,
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
                      _pickFile();
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/pdf.svg",
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
                    return language["Enter File"] ?? "Enter File";
                  }
                  return null;
                },
              ),
            ],
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
              if (!existFile) {
                await uploadFile();
              }
              addSellerAgreementContract();
            }
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
