import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'model_service.dart';

class ImageProcessor {
  final ModelService _modelService;

  ImageProcessor(this._modelService);

  Future<File?> cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Image', minimumAspectRatio: 1.0),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<void> runInference(
    File imageFile,
    Function(String, double) callback,
  ) async {
    try {
      // Decode image
      img.Image? image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) {
        print("❌ Error decoding image");
        return;
      }

      // Resize to 224x224
      image = img.copyResize(image, width: 224, height: 224);

      // Normalize and Convert RGB to BGR
      List<List<List<double>>> input = List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = image!.getPixel(x, y);
          return [pixel.b / 255.0, pixel.g / 255.0, pixel.r / 255.0];
        }),
      );

      // Run inference and get results
      final result = await _modelService.runInference([input]);

      callback(
        "Class: ${_modelService.classLabels[result['class']]}",
        result['confidence'],
      );

      print(
        "✅ Prediction: ${_modelService.classLabels[result['class']]}, "
        "Confidence: ${(result['confidence'] * 100).toStringAsFixed(2)}%",
      );
    } catch (e) {
      print("❌ Error running inference: $e");
    }
  }
}
