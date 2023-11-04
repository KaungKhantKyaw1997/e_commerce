import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  List _chatData = [];

  List get chatData => _chatData;

  void setChatData(List chatData) {
    _chatData = chatData;
    notifyListeners();
  }
}
