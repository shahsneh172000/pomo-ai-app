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
  late ModelService _modelService;
  late ImageProcessor _imageProcessor;
  String _selectedModel = 'Fruit'; // Default to Fruit Model
  bool _isLoadingModels = true; // Track model loading state

  @override
  void initState() {
    super.initState();
    _modelService = ModelService();
    _imageProcessor = ImageProcessor(_modelService);
    _loadModels();
  }

  Future<void> _loadModels() async {
    await _modelService.loadModels();
    setState(() {
      _isLoadingModels = false; // Models are loaded, enable UI
    });
  }

  Future<void> pickImageGallery() async {
    if (_isLoadingModels) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait, models are loading...")),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File? croppedImage = await _imageProcessor.cropImage(File(image.path));
    if (croppedImage != null) {
      setState(() {
        filePath = croppedImage;
      });
      await _imageProcessor.runInference(croppedImage, _selectedModel, (
        newLabel,
      ) {
        setState(() {
          label = newLabel;
        });
      });
    }
  }

  Future<void> pickImageCamera() async {
    if (_isLoadingModels) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait, models are loading...")),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    File? croppedImage = await _imageProcessor.cropImage(File(image.path));
    if (croppedImage != null) {
      setState(() {
        filePath = croppedImage;
      });
      await _imageProcessor.runInference(croppedImage, _selectedModel, (
        newLabel,
      ) {
        setState(() {
          label = newLabel;
        });
      });
    }
  }

  @override
  void dispose() {
    _modelService.dispose(); // Release models when the page is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pomo AI")),
      body:
          _isLoadingModels
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : SingleChildScrollView(
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
                                            image: AssetImage(
                                              'assets/upload.png',
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                ),
                                child:
                                    filePath == null
                                        ? null
                                        : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.file(
                                            filePath!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Model selection buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedModel = 'Fruit';
                                label = "Label"; // Reset label when switching
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _selectedModel == 'Fruit'
                                      ? Colors.deepPurple
                                      : null,
                            ),
                            child: const Text("Fruit Model"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedModel = 'Leaf';
                                label = "Label"; // Reset label when switching
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _selectedModel == 'Leaf'
                                      ? Colors.deepPurple
                                      : null,
                            ),
                            child: const Text("Leaf Model"),
                          ),
                        ],
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
