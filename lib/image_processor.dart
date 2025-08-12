import 'dart:io';
import 'dart:typed_data';
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
    String modelType, // "Fruit" or "Leaf"
    Function(String) callback,
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

      // Convert to (1, 3, 224, 224) tensor and normalize (RGB order)
      final inputData = Float32List(1 * 3 * 224 * 224); // 150,528 elements
      int pixelIndex = 0;
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = image.getPixel(x, y);
          inputData[pixelIndex] = pixel.r / 255.0; // R channel
          inputData[pixelIndex + 224 * 224] = pixel.g / 255.0; // G channel
          inputData[pixelIndex + 2 * 224 * 224] = pixel.b / 255.0; // B channel
          pixelIndex++;
        }
      }

      // Run inference and get results
      final result = await _modelService.runInference(inputData, modelType);

      callback(_modelService.getLabel(result['class'], modelType));

      print(
        "✅ Prediction: ${_modelService.getLabel(result['class'], modelType)}",
      );
    } catch (e) {
      print("❌ Error running inference: $e");
    }
  }
}
