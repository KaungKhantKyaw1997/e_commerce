import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotiProvider extends ChangeNotifier {
  int _count;

  NotiProvider(this._count);

  int get count => _count;

  Future<void> addCount(int count) async {
    _count = count;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notiCount', _count);
  }
}
