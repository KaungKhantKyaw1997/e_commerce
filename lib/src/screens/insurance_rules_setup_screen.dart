import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/insurance_rules_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class insurance_rules_setup_screen extends StatefulWidget {
  const insurance_rules_setup_screen({super.key});

  @override
  State<insurance_rules_setup_screen> createState() => _insurance_rules_setup_screenState();
}

class _insurance_rules_setup_screenState extends State<insurance_rules_setup_screen> {
   String logoUrl = '';

  final  insurranceService=InsuranceRulesService();
  TextEditingController name = TextEditingController(text: '');
  TextEditingController description = TextEditingController(text: '');
   TextEditingController search = TextEditingController(text: '');
    final crashlytic = new CrashlyticsService();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
       List insurrances = [];
     int page = 1;
  String from = "";
  
    @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        from = arguments["from"];
      }
    });
    getInsurrances();
  }

  getInsurrances() async {
    try {
      final response =
          await insurranceService.getInsuranceRulesDataList(page: page, search: search.text);
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          insurrances += response["data"];
          page++;
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      // if (e is DioException &&
      //     e.error is SocketException &&
      //     !isConnectionTimeout) {
      //   isConnectionTimeout = true;
      //   Navigator.pushNamed(
      //     context,
      //     Routes().connection_timeout,
      //   );
      //   return;
      // }
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
        title: TextField(
          controller: search,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
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
            page = 1;
            insurrances = [];
            getInsurrances();
          },
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SmartRefresher(
        header: WaterDropMaterialHeader(
          backgroundColor: Theme.of(context).primaryColor,
          color: Colors.white,
        ),
        footer: ClassicFooter(),
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: () async {
          page = 1;
          insurrances = [];
          await getInsurrances();
        },
        onLoading: () async {
          await getInsurrances();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            width: double.infinity,
            child: Column(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: insurrances.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (from != "product") {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            Routes.brand_setup,
                            arguments: {
                              "id": insurrances[index]["insurrance_id"],
                            },
                          );
                        } else {
                          Navigator.of(context).pop(insurrances[index]);
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          insurranceCard(index),
                          index < insurrances.length - 1
                              ? Container(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                  ),
                                  child: const Divider(
                                    height: 0,
                                    color: Colors.grey,
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: from != "product"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  Routes.brand_setup,
                  arguments: {
                    "id": 0,
                  },
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.add,
              ),
            )
          : null,
    );
  }

  insurranceCard(index) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(index == 0 ? 10 : 0),
          topRight: Radius.circular(index == 0 ? 10 : 0),
          bottomLeft: Radius.circular(index == insurrances.length - 1 ? 10 : 0),
          bottomRight: Radius.circular(index == insurrances.length - 1 ? 10 : 0),
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                left: 15,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          insurrances[index]["description"].toString(),
                          overflow: TextOverflow.ellipsis,
                          style: FontConstants.body1,
                        ),
                      ),
                      Text(
                        Jiffy.parseFromDateTime(DateTime.parse(
                                    insurrances[index]["effective_from"] + "Z")
                                .toLocal())
                            .format(pattern: 'dd/MM/yyyy'),
                        overflow: TextOverflow.ellipsis,
                        style: FontConstants.caption1,
                      ),
                       Text(
                        Jiffy.parseFromDateTime(DateTime.parse(
                                    insurrances[index]["effective_to"] + "Z")
                                .toLocal())
                            .format(pattern: 'dd/MM/yyyy'),
                        overflow: TextOverflow.ellipsis,
                        style: FontConstants.caption1,
                      ),
                    ],
                  ),
                  Text(
                    insurrances[index]["commission_percentage"].toString(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: FontConstants.caption1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}