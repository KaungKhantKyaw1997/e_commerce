import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewScreen extends StatelessWidget {
  const ImagePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    var image_url = '';
    if (arguments != null) {
      image_url = arguments["image_url"] as String;
    }

    return Container(
        child: PhotoView(
      imageProvider: NetworkImage(image_url),
    ));
  }
}
