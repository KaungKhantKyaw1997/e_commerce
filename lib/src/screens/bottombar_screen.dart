import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/providers/noti_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  List navItems = [];
  String role = "";

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "";
      navItems = [];
      if (role == 'admin' || role == 'agent') {
        navItems = [
          {"index": 0, "icon": "assets/icons/order.svg", "label": "Order"},
          {
            "index": 1,
            "icon": "assets/icons/noti.svg",
            "label": "Notification"
          },
          {"index": 2, "icon": "assets/icons/setting.svg", "label": "Settings"}
        ];
      } else if (role == 'user') {
        navItems = [
          {"index": 0, "icon": "assets/icons/home.svg", "label": "Home"},
          {"index": 1, "icon": "assets/icons/cart.svg", "label": "Cart"},
          {"index": 2, "icon": "assets/icons/history.svg", "label": "History"},
          {
            "index": 3,
            "icon": "assets/icons/noti.svg",
            "label": "Notification"
          },
          {"index": 4, "icon": "assets/icons/setting.svg", "label": "Settings"}
        ];
      } else {
        navItems = [
          {"index": 0, "icon": "assets/icons/home.svg", "label": "Home"},
          {"index": 1, "icon": "assets/icons/cart.svg", "label": "Cart"},
          {"index": 2, "icon": "assets/icons/setting.svg", "label": "Settings"}
        ];
      }
    });
  }

  Future<void> _onTabSelected(int index) async {
    BottomProvider bottomProvider =
        Provider.of<BottomProvider>(context, listen: false);

    if (bottomProvider.currentIndex != index) {
      bottomProvider.selectIndex(index);

      var data = navItems[index];
      if (data["label"] == 'Home') {
        Navigator.pushNamed(context, Routes.home);
      } else if (data["label"] == 'Cart') {
        Navigator.pushNamed(context, Routes.cart);
      } else if (data["label"] == 'History' || data["label"] == 'Order') {
        Navigator.pushNamed(context, Routes.history);
      } else if (data["label"] == 'Notification') {
        Navigator.pushNamed(context, Routes.noti);
      } else if (data["label"] == 'Settings') {
        Navigator.pushNamed(context, Routes.setting);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getData();

    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: true);
    NotiProvider notiProvider =
        Provider.of<NotiProvider>(context, listen: true);

    return Consumer<BottomProvider>(builder: (context, bottomProvider, child) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: navItems.isNotEmpty
            ? BottomNavigationBar(
                currentIndex: bottomProvider.currentIndex,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: Theme.of(context).primaryColor,
                unselectedItemColor: Colors.grey,
                selectedFontSize: FontConstants.bottom,
                unselectedFontSize: FontConstants.bottom,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                ),
                onTap: _onTabSelected,
                items: navItems.map((navItem) {
                  return BottomNavigationBarItem(
                    icon: navItem["label"] != 'Cart' &&
                            navItem["label"] != 'Notification'
                        ? Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              top: 8,
                              right: 8,
                            ),
                            child: SvgPicture.asset(
                              navItem["icon"],
                              colorFilter: ColorFilter.mode(
                                navItem["index"] == bottomProvider.currentIndex
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                BlendMode.srcIn,
                              ),
                              width: 24,
                              height: 24,
                            ),
                          )
                        : Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  top: 8,
                                  right: 8,
                                ),
                                child: SvgPicture.asset(
                                  navItem["icon"],
                                  colorFilter: ColorFilter.mode(
                                    navItem["index"] ==
                                            bottomProvider.currentIndex
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                    BlendMode.srcIn,
                                  ),
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              navItem["label"] == 'Cart' &&
                                      cartProvider.count > 0
                                  ? Positioned(
                                      right: 2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: ColorConstants.redcolor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          '${cartProvider.count}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: FontConstants.bottom,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : navItem["label"] == 'Notification' &&
                                          notiProvider.count > 0
                                      ? Positioned(
                                          right: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: ColorConstants.redcolor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 16,
                                              minHeight: 16,
                                            ),
                                            child: Text(
                                              '${notiProvider.count}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: FontConstants.bottom,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      : Text(''),
                            ],
                          ),
                    label: language[navItem["label"]] ?? navItem["label"],
                  );
                }).toList(),
              )
            : Container(),
      );
    });
  }
}
