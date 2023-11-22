import 'dart:convert';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  changeLanguage(lang) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("language", lang).toString();

    try {
      final response =
          await rootBundle.loadString('assets/languages/$lang.json');
      final dynamic data = json.decode(response);
      if (data is Map<String, dynamic>) {
        setState(() {
          language = data.cast<String, String>();
        });
      }
    } catch (e) {
      print('Error loading language data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          language["Language"] ?? "Language",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  language["English"] ?? "English",
                  style: FontConstants.caption2,
                ),
                trailing: Icon(
                  Icons.done,
                  color: selectedLangIndex == 0
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  size: 20,
                ),
                onTap: () async {
                  selectedLangIndex = 0;
                  changeLanguage("eng");
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Divider(
                  height: 0,
                  thickness: 0.2,
                  color: Colors.grey,
                ),
              ),
              ListTile(
                title: Text(
                  language["Myanmar"] ?? "Myanmar",
                  style: FontConstants.caption2,
                ),
                trailing: Icon(
                  Icons.done,
                  color: selectedLangIndex == 1
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  size: 20,
                ),
                onTap: () async {
                  selectedLangIndex = 1;
                  changeLanguage("mm");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
