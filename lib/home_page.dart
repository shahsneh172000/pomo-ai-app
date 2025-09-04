// ...existing code...
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
  String _selectedModel = 'mobilenetv3'; // default model key
  bool _isLoadingModels = true;
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _modelService = ModelService();
    _imageProcessor = ImageProcessor(_modelService);
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      await _modelService.loadModels();
    } catch (e) {
      print('❌ Error loading models: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Model load failed: $e')));
    } finally {
      setState(() {
        _isLoadingModels = false;
      });
    }
  }

  Future<void> pickImageGallery() async {
    if (_isLoadingModels) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please wait, models are loading...")));
      return;
    }
    if (_isProcessingImage) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File croppedImage;
    try {
      final File? maybe = await _imageProcessor.cropImage(File(image.path));
      croppedImage = maybe ?? File(image.path);
    } catch (e) {
      print('⚠️ cropImage failed, using original image: $e');
      croppedImage = File(image.path);
    }

    setState(() {
      filePath = croppedImage;
      _isProcessingImage = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Running inference...")));

    try {
      await _imageProcessor.runInference(croppedImage, _selectedModel, (newLabel) {
        setState(() {
          label = newLabel;
        });
      });
    } catch (e) {
      print('❌ Inference error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inference failed: $e')));
    } finally {
      setState(() {
        _isProcessingImage = false;
      });
    }
  }

  Future<void> pickImageCamera() async {
    if (_isLoadingModels) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please wait, models are loading...")));
      return;
    }
    if (_isProcessingImage) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    File croppedImage;
    try {
      final File? maybe = await _imageProcessor.cropImage(File(image.path));
      croppedImage = maybe ?? File(image.path);
    } catch (e) {
      print('⚠️ cropImage failed, using original image: $e');
      croppedImage = File(image.path);
    }

    setState(() {
      filePath = croppedImage;
      _isProcessingImage = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Running inference...")));

    try {
      await _imageProcessor.runInference(croppedImage, _selectedModel, (newLabel) {
        setState(() {
          label = newLabel;
        });
      });
    } catch (e) {
      print('❌ Inference error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inference failed: $e')));
    } finally {
      setState(() {
        _isProcessingImage = false;
      });
    }
  }

  @override
  void dispose() {
    _modelService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pomo AI")),
      body: _isLoadingModels
          ? const Center(child: CircularProgressIndicator())
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
                                image: filePath == null
                                    ? const DecorationImage(
                                        image: AssetImage('assets/upload.png'),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: filePath == null
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
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // model selection UI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {

                              _selectedModel = 'mobilenetv3';
                              label = "Label";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedModel == 'mobilenetv3' ? Colors.deepPurple : null,
                          ),
                          child: const Text('MobileNetV3'),
                        ),

                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedModel = 'leaf';
                              label = "Label";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedModel == 'leaf' ? Colors.deepPurple : null,
                          ),
                          child: const Text('Leaf Model'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: (_isLoadingModels || _isProcessingImage) ? null : pickImageGallery,
                          child: const Text("Gallery"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: (_isLoadingModels || _isProcessingImage) ? null : pickImageCamera,
                          child: const Text("Camera"),
                        ),
                      ],
                    ),
                    if (_isProcessingImage)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: CircularProgressIndicator(),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}