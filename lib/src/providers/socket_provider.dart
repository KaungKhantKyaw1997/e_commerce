import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketProvider extends ChangeNotifier {
  IO.Socket? _socket = IO.io(ApiConstants.socketServerURL, <String, dynamic>{
    'autoConnect': false,
    'transports': ['websocket'],
  });

  IO.Socket? get socket => _socket;

  void setSocket(IO.Socket socket) {
    _socket = socket;
    notifyListeners();
  }
}
