import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'image_processor.dart';
import 'model_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? filePath;
  String label = "Label";
  double confidence = 0.0;
  late ModelService _modelService;
  late ImageProcessor _imageProcessor;

  @override
  void initState() {
    super.initState();
    _modelService = ModelService();
    _imageProcessor = ImageProcessor(_modelService);
    _modelService.loadModel();
  }

  Future<void> pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File? croppedImage = await _imageProcessor.cropImage(File(image.path));
    if (croppedImage != null) {
      setState(() {
        filePath = croppedImage;
      });
      await _imageProcessor.runInference(croppedImage, (
        newLabel,
        newConfidence,
      ) {
        setState(() {
          label = newLabel;
          confidence = newConfidence;
        });
      });
    }
  }

  Future<void> pickImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    File? croppedImage = await _imageProcessor.cropImage(File(image.path));
    if (croppedImage != null) {
      setState(() {
        filePath = croppedImage;
      });
      await _imageProcessor.runInference(croppedImage, (
        newLabel,
        newConfidence,
      ) {
        setState(() {
          label = newLabel;
          confidence = newConfidence;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pomo AI")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Card(
                elevation: 20,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      Container(
                        height: 280,
                        width: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          image:
                              filePath == null
                                  ? const DecorationImage(
                                    image: AssetImage('assets/upload.png'),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            filePath == null
                                ? null
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    filePath!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Confidence: ${(confidence * 100).toStringAsFixed(2)}%",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: pickImageGallery,
                    child: const Text("Gallery"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: pickImageCamera,
                    child: const Text("Camera"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
