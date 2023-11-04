import 'package:flutter/material.dart';

class ChatsProvider extends ChangeNotifier {
  List _chats = [];

  List get chats => _chats;

  void setChats(List chats) {
    _chats = chats;
    notifyListeners();
  }
}
