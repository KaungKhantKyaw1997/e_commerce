import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/categories_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final categoriesService = CategoriesService();
  TextEditingController search = TextEditingController(text: '');
  final ScrollController _categoriesController = ScrollController();
  List categories = [];
  int page = 1;
  int pageCounts = 0;
  int total = 0;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  @override
  void dispose() {
    categoriesService.cancelRequest();
    _categoriesController.dispose();
    super.dispose();
  }

  getCategories() async {
    try {
      final response = await categoriesService.getCategoriesData(
          page: page, search: search.text);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          categories = response["data"];
          page = response["page"];
          pageCounts = response["page_counts"];
          total = response["total"];
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  categoryCard(index) {
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
          bottomLeft: Radius.circular(index == categories.length - 1 ? 10 : 0),
          bottomRight: Radius.circular(index == categories.length - 1 ? 10 : 0),
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              image: DecorationImage(
                // image: NetworkImage(
                //     '${ApiConstants.baseUrl}${categories[index]["cover_image"].toString()}'),
                image: AssetImage("assets/images/logo.png"),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.transparent,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                left: 4,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categories[index]["name"].toString(),
                    overflow: TextOverflow.ellipsis,
                    style: FontConstants.body1,
                  ),
                  Text(
                    categories[index]["description"].toString(),
                    maxLines: 2,
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
          autofocus: true,
          style: FontConstants.body1,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: language["Search Category"] ?? "Search Category",
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
            getCategories();
          },
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 24,
          ),
          width: double.infinity,
          child: Column(
            children: [
              categories.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.only(
                        top: 4,
                        bottom: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Total ${total.toString()}',
                            style: FontConstants.caption1,
                          ),
                          NumberPaginator(
                            numberPages: pageCounts,
                            onPageChange: (int index) {
                              setState(() {
                                page = index + 1;
                                getCategories();
                              });
                            },
                            config: const NumberPaginatorUIConfig(
                              mode: ContentDisplayMode.hidden,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              ListView.builder(
                controller: _categoriesController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.products,
                        arguments: categories[index],
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        categoryCard(index),
                        index < categories.length - 1
                            ? Container(
                                padding: const EdgeInsets.only(
                                  left: 100,
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
    );
  }
}
