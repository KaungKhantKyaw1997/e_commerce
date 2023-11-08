import 'package:e_commerce/global.dart';
import 'package:flutter/material.dart';

class RouteObserverService extends NavigatorObserver {
  static final RouteObserverService _instance =
      RouteObserverService._internal();

  factory RouteObserverService() {
    return _instance;
  }

  RouteObserverService._internal();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Handle route changes here
    if (route is PageRoute && route.settings.name != null) {
      routeName = route.settings.name!;
    }
  }
}
