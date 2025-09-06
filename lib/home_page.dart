import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'image_processor.dart';
import 'model_service.dart';

class MyHomePage extends StatefulWidget {
  final void Function(bool)? onThemeToggle;
  final bool isDarkMode;

  const MyHomePage({super.key, this.onThemeToggle, this.isDarkMode = false});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? filePath;
  String label = "Pomogrenete App";
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
      appBar: AppBar(
        title: const Text("Pomogrenete App"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: (val) {
              if (widget.onThemeToggle != null) {
                widget.onThemeToggle!(val);
              }
            },
            activeColor: Colors.yellow,
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
      body: _isLoadingModels
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    const Text(
                      "Identify Pomogrenate Fruit & Leaf",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(thickness: 1, indent: 40, endIndent: 40),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 16,
                      color: Colors.deepPurple.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: 320,
                        child: Column(
                          children: [
                            const SizedBox(height: 18),
                            Container(
                              height: 260,
                              width: 260,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                image: filePath == null
                                    ? const DecorationImage(
                                        image: AssetImage(
                                          'assets/upload.png',
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: filePath == null
                                  ? null
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        filePath!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 14),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedModel = 'Fruit';
                              label = "Label";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedModel == 'Fruit'
                                ? Colors.deepPurple
                                : Colors.grey[300],
                            foregroundColor: _selectedModel == 'Fruit'
                                ? Colors.white
                                : Colors.black,
                          ),
                          child: const Text("Fruit Model"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedModel = 'Leaf';
                              label = "Label";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedModel == 'Leaf'
                                ? Colors.deepPurple
                                : Colors.grey[300],
                            foregroundColor: _selectedModel == 'Leaf'
                                ? Colors.white
                                : Colors.black,
                          ),
                          child: const Text("Leaf Model"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: pickImageGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Gallery"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: pickImageCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Camera"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
