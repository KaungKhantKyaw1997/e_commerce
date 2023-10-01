import 'dart:io';

import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _itemController = ScrollController();
  late TabController _tabController;
  List items = [
    {
      "image_url": "assets/images/gshock1.png",
      "name": "G-SHOCK",
      "brand": "Casio",
      "model": "GMW-B5000BPC-1",
      "price": "100000",
      "qty": "0",
    },
    {
      "image_url": "assets/images/gshock2.png",
      "name": "G-SHOCK",
      "brand": "Casio",
      "model": "GM-B2100LL-1A",
      "price": "200000",
      "qty": "0",
    },
    {
      "image_url": "assets/images/gshock3.png",
      "name": "G-SHOCK",
      "brand": "Casio",
      "model": "GA-700NC-5A",
      "price": "300000",
      "qty": "0",
    },
    {
      "image_url": "assets/images/gshock4.png",
      "name": "G-SHOCK",
      "brand": "Casio",
      "model": "GA-2100P-1A",
      "price": "400000",
      "qty": "0",
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  itemCard(index) {
    return Container(
      padding: EdgeInsets.only(
        top: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(items[index]["image_url"]),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
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
                items[index]["name"].toString(),
                style: FontConstants.caption2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                items[index]["model"].toString(),
                style: FontConstants.body1,
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          language["Home"] ?? "Home",
          style: FontConstants.title1,
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorConstants.fillcolor,
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                "assets/icons/search.svg",
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, Routes.search);
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorPadding: EdgeInsets.symmetric(
            horizontal: 30,
          ),
          tabs: [
            Tab(
              child: Text(
                "Shop",
                style: FontConstants.subtitle1,
              ),
            ),
            Tab(
              child: Text(
                "Categories",
                style: FontConstants.subtitle1,
              ),
            ),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
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
                GridView.builder(
                  controller: _itemController,
                  shrinkWrap: true,
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 230,
                    childAspectRatio: 2 / 1,
                    crossAxisSpacing: 15,
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.item_details,
                          arguments: items[index],
                        );
                      },
                      child: itemCard(index),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
