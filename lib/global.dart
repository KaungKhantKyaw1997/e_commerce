import 'package:flutter/material.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String routeName = '';

int selectedLangIndex = 0;
Map<String, String> language = {};
bool isConnectionTimeout = false;
