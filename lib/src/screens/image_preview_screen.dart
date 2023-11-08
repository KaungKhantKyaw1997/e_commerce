import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
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

    return Scaffold(
      body: FutureBuilder(
        future: _checkImage(imageUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            // If we run into an error, return the default image
            return Container(
              child: PhotoView(
                imageProvider: NetworkImage(defaultImageUrl),
                filterQuality: FilterQuality.high,
              ),
            );
          } else {
            // If the image loads successfully, return it
            return Container(
              child: PhotoView(
                imageProvider: NetworkImage(imageUrl),
                filterQuality: FilterQuality.high,
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveImage(imageUrl, context), // Pass context here
        child: Icon(Icons.save_alt),
        tooltip: 'Save Image',
      ),
    );
  }

  Future<void> _saveImage(String url, BuildContext context) async {
    try {
      var response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,
        name: url.split("/")[url.split("/").length - 1],
      );
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to gallery!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    }
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
