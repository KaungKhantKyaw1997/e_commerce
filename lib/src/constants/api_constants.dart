class ApiConstants {
  static const String baseUrl = 'http://150.95.82.125:8001';
  static const String loginUrl = '$baseUrl/api/auth/login';
  static const String registerUrl = '$baseUrl/api/auth/register';
  static const String changepasswordUrl = '$baseUrl/api/auth/change-password';
  static const String verifyTokenUrl = '$baseUrl/api/auth/verify-token';
  static const String fcmUrl = '$baseUrl/api/fcm/token';
  static const String imageUploadUrl = '$baseUrl/api/image/upload';
  static const String shopsUrl = '$baseUrl/api/shops';
  static const String categoriesUrl = '$baseUrl/api/categories';
  static const String brandsUrl = '$baseUrl/api/brands';
  static const String modelsUrl = '$baseUrl/api/models';
  static const String productsUrl = '$baseUrl/api/products';
  static const String getProductsUrl = '$baseUrl/api/get-products';
  static const String addressUrl = '$baseUrl/api/address';
  static const String ordersUrl = '$baseUrl/api/orders';
  static const String orderUrl = '$baseUrl/api/order-items';
  static const String profleUrl = '$baseUrl/api/profile';
  static const String getNotificationsUrl = '$baseUrl/api/get-notifications';
  static const String unreadNotificationsUrl =
      '$baseUrl/api/unread-notifications';
  static const String notificationsUrl = '$baseUrl/api/notifications';
  static const String usersUrl = '$baseUrl/api/users';
  static const String vectorsUrl = '$baseUrl/api/vectors';
  static const String termsAndConditionsUrl =
      '$baseUrl/api/terms-and-conditions';
  static const String insuranceRulesUrl = '$baseUrl/api/insurance-rules';
  static const String deleteAccountUrl = '$baseUrl/api/delete-account';
  static const String currenciesUrl = '$baseUrl/api/currencies';
}
