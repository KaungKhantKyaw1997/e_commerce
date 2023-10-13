import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/brands_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:number_paginator/number_paginator.dart';

class BrandsSetupScreen extends StatefulWidget {
  const BrandsSetupScreen({super.key});

  @override
  State<BrandsSetupScreen> createState() => _BrandsSetupScreenState();
}

class _BrandsSetupScreenState extends State<BrandsSetupScreen> {
  final brandsService = BrandsService();
  TextEditingController search = TextEditingController(text: '');
  final ScrollController _scrollController = ScrollController();
  List brands = [];
  int page = 1;
  int pageCounts = 0;
  int total = 0;

  @override
  void initState() {
    super.initState();
    getBrands();
  }

  @override
  void dispose() {
    brandsService.cancelRequest();
    _scrollController.dispose();
    super.dispose();
  }

  getBrands() async {
    try {
      final response =
          await brandsService.getBrandsData(page: page, search: search.text);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          brands = response["data"];
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

  brandCard(index) {
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
          bottomLeft: Radius.circular(index == brands.length - 1 ? 10 : 0),
          bottomRight: Radius.circular(index == brands.length - 1 ? 10 : 0),
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
              image: brands[index]["logo_url"] != ""
                  ? DecorationImage(
                      image: NetworkImage(
                          '${ApiConstants.baseUrl}${brands[index]["logo_url"].toString()}'),
                      fit: BoxFit.fill,
                    )
                  : DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        brands[index]["name"].toString(),
                        overflow: TextOverflow.ellipsis,
                        style: FontConstants.body1,
                      ),
                      Text(
                        Jiffy.parse(brands[index]["created_at"])
                            .format(pattern: 'dd/MM/yyyy'),
                        overflow: TextOverflow.ellipsis,
                        style: FontConstants.caption1,
                      ),
                    ],
                  ),
                  Text(
                    brands[index]["description"].toString(),
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
            getBrands();
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
              brands.isNotEmpty
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
                                getBrands();
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
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        Routes.brand_setup,
                        arguments: {
                          "id": brands[index]["brand_id"],
                        },
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brandCard(index),
                        index < brands.length - 1
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
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}
