import 'package:flutter/material.dart';

class ChatHistoriesProvider extends ChangeNotifier {
  List _chatHistories = [];

  List get chatHistories => _chatHistories;

  void setChatHistories(List chatHistories) {
    _chatHistories = chatHistories;
    notifyListeners();
  }
}
