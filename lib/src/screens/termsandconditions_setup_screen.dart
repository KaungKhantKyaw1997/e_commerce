import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/termsandconditions_service.dart';
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
  final ScrollController _scrollController = ScrollController();
  final termsAndConditionsService = TermsAndConditionsService();
  String data = '';
    final _formKey = GlobalKey<FormState>();
  TextEditingController description = TextEditingController(text: '');
   FocusNode _descriptionFocusNode = FocusNode();
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
            data = response["data"];
          });
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

    addTermsAndConditionsData() async {
    try {
      final body = {
        "content": description.text,
      };

      final response = await termsAndConditionsService.addTermsAndConditionsData(body);
      Navigator.pop(context);
      if (response["code"] == 201) {
        ToastUtil.showToast(response["code"], response["message"]);
        Navigator.pop(context);
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Form(
          key: _formKey,
          child:Container(
                   child: Padding(
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
          )
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
            
          },
          child: Text(
            data.isEmpty
                ? language["Save"] ?? "Save"
                : language["Update"] ?? "Update",
            style: FontConstants.button1,
          ),
        ),
      ),
    );
  }
}
