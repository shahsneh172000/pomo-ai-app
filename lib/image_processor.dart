// ...existing code...
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
    try {
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
    } catch (e) {
      // Plugin not registered / failed — fallback to returning original image so inference can proceed
      print('⚠️ ImageCropper failed or missing plugin; using original image. Error: $e');
      return imageFile;
    }
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

      final Map<String, int> modelInputSize = {
        'fruit': 224,
        'mobilenetv3': 224,
        'coatnet': 224,
        'leaf': 224,
      };
      final int size = modelInputSize[modelType.toLowerCase()] ?? 224;
      // Resize to model size (use computed size, not hardcoded 224)
      image = img.copyResize(image, width: size, height: size);

      final int hw = size * size;
      final inputData = Float32List(1 * 3 * hw); // NCHW

      // Fill NCHW: channel-major (RGB order)
      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          final dynamic px = image.getPixel(x, y);

          // Support both legacy int pixel and new Pixel class from package:image
          int rInt, gInt, bInt;
          if (px is int) {
            rInt = (px >> 16) & 0xFF;
            gInt = (px >> 8) & 0xFF;
            bInt = px & 0xFF;
          } else if (px is img.Pixel) {
            // Pixel.r/g/b may be num — convert to int
            rInt = px.r.toInt();
            gInt = px.g.toInt();
            bInt = px.b.toInt();
          } else {
            // Fallback: try to treat as int
            final int v = px as int;
            rInt = (v >> 16) & 0xFF;
            gInt = (v >> 8) & 0xFF;
            bInt = v & 0xFF;
          }

          final int base = y * size + x;
          inputData[0 * hw + base] = rInt.toDouble();
          inputData[1 * hw + base] = gInt.toDouble();
          inputData[2 * hw + base] = bInt.toDouble();
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