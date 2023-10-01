import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void addCount(int count) {
    _count = count;
    notifyListeners();
  }
}
