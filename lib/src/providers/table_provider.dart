import 'package:flutter/material.dart';

class TableProvider extends ChangeNotifier {
  int _tableId = 0;

  int get tableId => _tableId;

  void selectId(int id) {
    _tableId = id;
    notifyListeners();
  }
}
