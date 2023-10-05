import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: LoadingAnimationWidget.newtonCradle(
            color: Colors.white,
            size: 200,
          ),
        ),
      );
    },
  );
}
