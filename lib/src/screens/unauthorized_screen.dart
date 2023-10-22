import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:flutter/material.dart';

class UnauthorizedScreen extends StatefulWidget {
  const UnauthorizedScreen({super.key});

  @override
  State<UnauthorizedScreen> createState() => _UnauthorizedScreenState();
}

class _UnauthorizedScreenState extends State<UnauthorizedScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/unauthorized.png'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 10,
              ),
              child: Text(
                "Connection Timed Out",
                textAlign: TextAlign.center,
                style: FontConstants.title2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
              ),
              child: Text(
                "Please check your internet connection and try again.",
                textAlign: TextAlign.center,
                style: FontConstants.subheadline2,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 24,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
          child: Text(
            language["Log In"] ?? "Log In",
            style: FontConstants.button1,
          ),
        ),
      ),
    );
  }
}
