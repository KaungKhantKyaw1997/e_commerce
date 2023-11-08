import 'package:e_commerce/src/screens/bank_account_setup_screen.dart';
import 'package:e_commerce/src/screens/bank_accounts_setup_screen.dart';
import 'package:e_commerce/src/screens/brand_setup_screen.dart';
import 'package:e_commerce/src/screens/brands_screen.dart';
import 'package:e_commerce/src/screens/brands_setup_screen.dart';
import 'package:e_commerce/src/screens/buyer_protection_setup_screen.dart';
import 'package:e_commerce/src/screens/buyer_protections_setup_screen.dart';
import 'package:e_commerce/src/screens/cart_screen.dart';
import 'package:e_commerce/src/screens/categories_screen.dart';
import 'package:e_commerce/src/screens/categories_setup_screen.dart';
import 'package:e_commerce/src/screens/category_setup_screen.dart';
import 'package:e_commerce/src/screens/change_password_screen.dart';
import 'package:e_commerce/src/screens/chat_history_screen.dart';
import 'package:e_commerce/src/screens/chat_screen.dart';
import 'package:e_commerce/src/screens/connection_timeout_screen.dart';
import 'package:e_commerce/src/screens/contactus_screen.dart';
import 'package:e_commerce/src/screens/forgot_password_screen.dart';
import 'package:e_commerce/src/screens/history_details_screen.dart';
import 'package:e_commerce/src/screens/history_screen.dart';
import 'package:e_commerce/src/screens/home_screen.dart';
import 'package:e_commerce/src/screens/image_preview_screen.dart';
import 'package:e_commerce/src/screens/language_screen.dart';
import 'package:e_commerce/src/screens/login_screen.dart';
import 'package:e_commerce/src/screens/notification_screen.dart';
import 'package:e_commerce/src/screens/order_confirm_screen.dart';
import 'package:e_commerce/src/screens/order_screen.dart';
import 'package:e_commerce/src/screens/product_filter_screen.dart';
import 'package:e_commerce/src/screens/product_screen.dart';
import 'package:e_commerce/src/screens/product_setup_screen.dart';
import 'package:e_commerce/src/screens/products_screen.dart';
import 'package:e_commerce/src/screens/products_setup_screen.dart';
import 'package:e_commerce/src/screens/profile_screen.dart';
import 'package:e_commerce/src/screens/register_screen.dart';
import 'package:e_commerce/src/screens/reviews_screen.dart';
import 'package:e_commerce/src/screens/search_screen.dart';
import 'package:e_commerce/src/screens/setting_screen.dart';
import 'package:e_commerce/src/screens/shop_screen.dart';
import 'package:e_commerce/src/screens/shop_setup_screen.dart';
import 'package:e_commerce/src/screens/shops_setup_screen.dart';
import 'package:e_commerce/src/screens/splash_screen.dart';
import 'package:e_commerce/src/screens/success_screen.dart';
import 'package:e_commerce/src/screens/switch_user.dart';
import 'package:e_commerce/src/screens/termsandconditions_screen.dart';
import 'package:e_commerce/src/screens/termsandconditions_setup_screen.dart';
import 'package:e_commerce/src/screens/unauthorized_screen.dart';
import 'package:e_commerce/src/screens/user_setup_screen.dart';
import 'package:e_commerce/src/screens/users_setup_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgot_password = '/forgot_password';
  static const String home = '/home';
  static const String products = '/products';
  static const String product = '/product';
  static const String categories = '/categories';
  static const String brands = '/brands';
  static const String cart = '/cart';
  static const String success = '/success';
  static const String history = '/history';
  static const String history_details = '/history_details';
  static const String noti = '/noti';
  static const String setting = '/setting';
  static const String profile = '/profile';
  static const String termsandconditions = '/termsandconditions';
  static const String termsandconditions_setup = '/termsandconditions_setup';
  static const String language = '/language';
  static const String change_password = '/change_password';
  static const String user_setup = '/user_setup';
  static const String users_setup = '/users_setup';
  static const String shop_setup = '/shop_setup';
  static const String shops_setup = '/shops_setup';
  static const String product_setup = '/product_setup';
  static const String products_setup = '/products_setup';
  static const String brand_setup = '/brand_setup';
  static const String brands_setup = '/brands_setup';
  static const String category_setup = '/category_setup';
  static const String categories_setup = '/categories_setup';
  static const String order = '/order';
  static const String order_confirm = '/order_confirm';
  static const String products_filter = '/products_filter';
  static const String search = '/search';
  static const String shop = "/shop";
  static const String reviews = "/reviews";
  static const String scan = "/scan";
  static const String image_preview = "/image_preview";
  static const String connection_timeout = "/connection_timeout";
  static const String unauthorized = "/unauthorized";
  static const String insurrance_rules_setup = "/insurrance_rules";
  static const String buyer_protections_setup = "/buyer_protections_setup";
  static const String buyer_protection_setup = "/buyer_protection_setup";
  static const String bank_accounts_setup = "/bank_accounts_setup";
  static const String bank_account_setup = "/bank_account_setup";
  static const String switch_user = "/switch_user";
  static const String chat = "/chat";
  static const String chat_history = "/chat_history";
  static const String contact_us = "/contact_us";

  static final Map<String, WidgetBuilder> routes = {
    splash: (BuildContext context) => const SplashScreen(),
    login: (BuildContext context) => const LogInScreen(),
    register: (BuildContext context) => const RegisterScreen(),
    forgot_password: (BuildContext context) => const ForgotPasswordScreen(),
    home: (BuildContext context) => const HomeScreen(),
    products: (BuildContext context) => const ProductsScreen(),
    product: (BuildContext context) => const ProductScreen(),
    categories: (BuildContext context) => const CategoriesScreen(),
    brands: (BuildContext context) => const BrandsScreen(),
    cart: (BuildContext context) => const CartScreen(),
    success: (BuildContext context) => const SuccessScreen(),
    history: (BuildContext context) => const HistoryScreen(),
    history_details: (BuildContext context) => const HistoryDetailsScreen(),
    noti: (BuildContext context) => const NotificationScreen(),
    setting: (BuildContext context) => const SettingScreen(),
    profile: (BuildContext context) => const ProfileScreen(),
    termsandconditions: (BuildContext context) =>
        const TermsAndConditionsScreen(),
    termsandconditions_setup: (BuildContext context) =>
        const TermsAndConditionsSetUpScreen(),
    language: (BuildContext context) => const LanguageScreen(),
    change_password: (BuildContext context) => const ChangePasswordScreen(),
    user_setup: (BuildContext context) => const UserSetupScreen(),
    users_setup: (BuildContext context) => const UsersSetupScreen(),
    shop_setup: (BuildContext context) => const ShopSetupScreen(),
    shops_setup: (BuildContext context) => const ShopsSetupScreen(),
    product_setup: (BuildContext context) => const ProductSetupScreen(),
    products_setup: (BuildContext context) => const ProductsSetupScreen(),
    brand_setup: (BuildContext context) => const BrandSetupScreen(),
    brands_setup: (BuildContext context) => const BrandsSetupScreen(),
    category_setup: (BuildContext context) => const CategorySetupScreen(),
    categories_setup: (BuildContext context) => const CategoriesSetupScreen(),
    order: (BuildContext context) => const OrderScreen(),
    order_confirm: (BuildContext context) => const OrderConfirmScreen(),
    products_filter: (BuildContext context) => const ProductsFilterScreen(),
    search: (BuildContext context) => const SearchScreen(),
    shop: (BuildContext context) => const ShopScreen(),
    reviews: (BuildContext context) => const ReviewsScreen(),
    image_preview: (BuildContext context) => const ImagePreviewScreen(),
    connection_timeout: (BuildContext context) =>
        const ConnectionTimeoutScreen(),
    unauthorized: (BuildContext context) => const UnauthorizedScreen(),
    buyer_protections_setup: (BuildContext context) =>
        const BuyerProtectionsSetupScreen(),
    buyer_protection_setup: (BuildContext context) =>
        const BuyerProtectionSetupScreen(),
    bank_accounts_setup: (BuildContext context) =>
        const BankAccountsSetupScreen(),
    bank_account_setup: (BuildContext context) =>
        const BankAccountSetupScreen(),
    switch_user: (BuildContext context) => const SwitchUserScreen(),
    chat: (BuildContext context) => const ChatScreen(),
    chat_history: (BuildContext context) => const ChatHistoryScreen(),
    contact_us: (BuildContext context) => const ContactUsScreen(),
  };
}
