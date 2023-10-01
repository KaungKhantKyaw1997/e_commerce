import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  List navItems = [
    {"index": 0, "icon": "assets/icons/home.svg", "label": "Home"},
    {"index": 1, "icon": "assets/icons/cart.svg", "label": "Cart"},
    // {"index": 2, "icon": "assets/icons/favourite.svg", "label": "Favourite"},
    // {"index": 3, "icon": "assets/icons/history.svg", "label": "History"},
    {"index": 4, "icon": "assets/icons/setting.svg", "label": "Setting"}
  ];

  Future<void> _onTabSelected(int index) async {
    BottomProvider bottomProvider =
        Provider.of<BottomProvider>(context, listen: false);

    bottomProvider.selectIndex(index);

    var data = navItems[index];
    if (data["label"] == 'Home') {
      Navigator.pushNamed(context, Routes.home);
    } else if (data["label"] == 'Cart') {
      Navigator.pushNamed(context, Routes.cart);
    } else if (data["label"] == 'Favourite') {
      Navigator.pushNamed(context, Routes.cart);
    } else if (data["label"] == 'History') {
      Navigator.pushNamed(context, Routes.history);
    } else if (data["label"] == 'Setting') {
      Navigator.pushNamed(context, Routes.setting);
    }
  }

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: true);

    return Consumer<BottomProvider>(builder: (context, bottomProvider, child) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
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
              icon: cartProvider.count > 0 && navItem["index"] == 1
                  ? Stack(
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
                              navItem["index"] == bottomProvider.currentIndex
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3200F),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cartProvider.count}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: FontConstants.bottom,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Padding(
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
                    ),
              label: language[navItem["label"]] ?? navItem["label"],
            );
          }).toList(),
        ),
      );
    });
  }
}
