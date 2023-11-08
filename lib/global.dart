import 'package:flutter/material.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String routeName = '';
String previousRouteName = '';

int selectedLangIndex = 0;
Map<String, String> language = {};
bool isConnectionTimeout = false;
