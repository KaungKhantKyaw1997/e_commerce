import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Center(
          child: LoadingAnimationWidget.newtonCradle(
            color: Color(0xffd3d6d7),
            size: 200,
          ),
        ),
      );
    },
  );
}
