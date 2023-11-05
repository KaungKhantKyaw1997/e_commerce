import 'package:flutter/material.dart';

class ChatScrollProvider extends ChangeNotifier {
  ScrollController _chatScrollController = ScrollController();

  ScrollController get chatScrollController => _chatScrollController;

  void setChatScrollController(ScrollController chatScrollController) {
    _chatScrollController = chatScrollController;
    notifyListeners();
  }
}
