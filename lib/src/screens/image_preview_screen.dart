import 'dart:async';

import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewScreen extends StatelessWidget {
  const ImagePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    var imageUrl = '';
    var defaultImageUrl = '';
    if (arguments != null) {
      defaultImageUrl = arguments["image_url"] as String;
      var imgParts =
          defaultImageUrl.replaceAll(ApiConstants.baseUrl, "").split(".");
      imageUrl =
          "${ApiConstants.baseUrl}${imgParts[0]}_original.${imgParts[1]}";
    }

    return FutureBuilder(
      future: _checkImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.error != null) {
          // If we run into an error, return the default image
          return Container(
            child: PhotoView(
              imageProvider: NetworkImage(defaultImageUrl),
            ),
          );
        } else {
          // If the image loads successfully, return it
          return Container(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
            ),
          );
        }
      },
    );
  }

  Future<void> _checkImage(String url) {
    final Completer<void> completer = Completer();

    final ImageStream stream = NetworkImage(url).resolve(ImageConfiguration());
    stream.addListener(
      ImageStreamListener(
        (info, call) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (exception, stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError('Image not found');
          }
        },
      ),
    );

    return completer.future;
  }
}
