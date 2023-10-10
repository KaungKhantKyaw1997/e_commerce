import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {
  String _paymentType = 'Preorder';

  String get paymentType => _paymentType;

  void selectPayment(String type) {
    _paymentType = type;
    notifyListeners();
  }
}
