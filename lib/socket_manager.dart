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
    final authService = new AuthService();
    final storage = FlutterSecureStorage();
    SocketProvider socketProvider =
        Provider.of<SocketProvider>(context, listen: false);
    var token = await storage.read(key: "token") ?? '';

    await socketProvider.socket!.disconnect();
    if (token.isNotEmpty && state == AppLifecycleState.resumed) {
      authService.initSocket(token, context);
    }
  }
}
