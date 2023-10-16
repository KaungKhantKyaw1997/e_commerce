import 'dart:convert';
import 'dart:io';

import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/services/vector_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../services/auth_service.dart';

class ScanScreen extends StatefulWidget {
  final CameraDescription camera;
  const ScanScreen({
    super.key,
    required this.camera,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final vectorService = VectorService();
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  getVector(url) async {
    try {
      final body = {
        "image_path": url.replaceAll("/images", "images"),
      };
      final response = await vectorService.getVectorsData(body);
      if (response!["code"] == 200) {
        Navigator.pushNamed(
          context,
          Routes.products,
          arguments: {
            "productIds": (response["data"] as List).cast<int>(),
          },
        );
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: <Widget>[
                // AspectRatio(
                //   aspectRatio: _controller.value.aspectRatio * 0.5,
                //   child: CameraPreview(_controller),
                // ),
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.previewSize!.height,
                      height: _controller.value.previewSize!.width,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                // Positioned(
                //   bottom: 50,
                //   left: 50,
                //   child: ElevatedButton(
                //     onPressed: () async {
                //       // You can use this to capture the image and get the path
                //       final image = await _controller.takePicture();
                //       // TODO: Handle the captured image
                //       print(image);
                //     },
                //     child: Text('Scan The QR Code'),
                //   ),
                // ),
                // Positioned(
                //   bottom: 50,
                //   right: 50,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       // TODO: Handle manual code entry
                //     },
                //     child: Text('Enter Code Manually'),
                //   ),
                // ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // You can use this to capture the image and get the path
          final image = await _controller.takePicture();
          // TODO: Handle the captured image
          print(image);
          try {
            var response = await AuthService.uploadFile(File(image.path));
            var res = jsonDecode(response.body);
            if (res["code"] == 200) {
              getVector(res["url"]);
            }
          } catch (error) {
            print('Error uploading file: $error');
          }
        },
        child: Icon(Icons.camera_alt),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Icon color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // To place button at the center bottom
    );
  }
}
