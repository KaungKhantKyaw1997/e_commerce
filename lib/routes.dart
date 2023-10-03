import 'package:e_commerce/src/screens/item_details.dart';
import 'package:e_commerce/src/screens/language_screen.dart';
import 'package:e_commerce/src/screens/profile_screen.dart';
import 'package:e_commerce/src/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/src/screens/cart_screen.dart';
import 'package:e_commerce/src/screens/home_screen.dart';
import 'package:e_commerce/src/screens/signin_screen.dart';
import 'package:e_commerce/src/screens/search_screen.dart';
import 'package:e_commerce/src/screens/setting_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String search = '/search';
  static const String item_details = '/item_details';
  static const String cart = '/cart';
  static const String setting = '/setting';
  static const String profile = '/profile';
  static const String language = '/language';

  static final Map<String, WidgetBuilder> routes = {
    signin: (BuildContext context) => const SignInScreen(),
    signup: (BuildContext context) => const SignUpScreen(),
    home: (BuildContext context) => const HomeScreen(),
    search: (BuildContext context) => const SearchScreen(),
    item_details: (BuildContext context) => const ItemDetails(),
    cart: (BuildContext context) => const CartScreen(),
    setting: (BuildContext context) => const SettingScreen(),
    profile: (BuildContext context) => const ProfileScreen(),
    language: (BuildContext context) => const LanguageScreen(),
  };
}
