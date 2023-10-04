import 'package:e_commerce/src/screens/brands_screen.dart';
import 'package:e_commerce/src/screens/categories_screen.dart';
import 'package:e_commerce/src/screens/product_screen.dart';
import 'package:e_commerce/src/screens/products_screen.dart';
import 'package:e_commerce/src/screens/language_screen.dart';
import 'package:e_commerce/src/screens/personal_info_screen.dart';
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
  static const String personalinfo = '/personalinfo';
  static const String home = '/home';
  static const String search = '/search';
  static const String shop = '/shop';
  static const String products = '/products';
  static const String product = '/product';
  static const String categories = '/categories';
  static const String brands = '/brands';
  static const String models = '/models';
  static const String cart = '/cart';
  static const String setting = '/setting';
  static const String profile = '/profile';
  static const String language = '/language';

  static final Map<String, WidgetBuilder> routes = {
    signin: (BuildContext context) => const SignInScreen(),
    signup: (BuildContext context) => const SignUpScreen(),
    personalinfo: (BuildContext context) => const PersonalInfoScreen(),
    home: (BuildContext context) => const HomeScreen(),
    search: (BuildContext context) => const SearchScreen(),
    products: (BuildContext context) => const ProductsScreen(),
    product: (BuildContext context) => const ProductScreen(),
    categories: (BuildContext context) => const CategoriesScreen(),
    brands: (BuildContext context) => const BrandsScreen(),
    cart: (BuildContext context) => const CartScreen(),
    setting: (BuildContext context) => const SettingScreen(),
    profile: (BuildContext context) => const ProfileScreen(),
    language: (BuildContext context) => const LanguageScreen(),
  };
}
