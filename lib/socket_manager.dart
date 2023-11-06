import 'package:e_commerce/src/providers/socket_provider.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class SocketManager with WidgetsBindingObserver {
  final BuildContext context;
  SocketManager(this.context);
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final AuthService authService = AuthService();
    final storage = FlutterSecureStorage();
    var token = await storage.read(key: "token") ?? '';
    if (token.isNotEmpty && state == AppLifecycleState.resumed) {
      authService.initSocket(token, context);
    } else if (state == AppLifecycleState.paused) {
      SocketProvider socketProvider =
          Provider.of<SocketProvider>(context, listen: false);
      await socketProvider.socket!.disconnect();
    }
  }
}
