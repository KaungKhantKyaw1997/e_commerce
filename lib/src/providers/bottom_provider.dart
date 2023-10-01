import 'package:flutter/material.dart';

class BottomProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void selectIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
