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

  Future<void> _pickAndProcessImage(ImageSource source) async {
    if (_isLoadingModels) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait, models are loading...")),
      );
      return;
    }
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      label = "Processing...";
    });

    File? croppedImage = await _imageProcessor.cropImage(File(image.path));
    if (croppedImage != null) {
      setState(() {
        filePath = croppedImage;
      });
      await _imageProcessor.runInference(
          croppedImage, _selectedModel, (newLabel) {
        setState(() {
          label = newLabel;
        });
      });
    } else {
      setState(() {
        label = "Could not process image.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    // Futuristic Color Palette with Light/Dark Mode support
    final Color primaryAccent =
        isDarkMode ? const Color(0xFF00BFFF) : const Color(0xFF007BFF); // DeepSkyBlue vs. Strong Blue
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final Color surfaceColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color headingColor = isDarkMode ? Colors.white : Colors.grey.shade800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pomo AI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: headingColor,
            letterSpacing: 1.2, // Add a futuristic touch
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: _isLoadingModels
          ? Center(
              child: CircularProgressIndicator(
              color: primaryAccent,
            ))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildImageDisplay(
                          headingColor, surfaceColor, primaryAccent),
                      const SizedBox(height: 24),
                      _buildModelSelector(primaryAccent, surfaceColor),
                      const SizedBox(height: 24),
                      _buildActionButtons(primaryAccent, surfaceColor),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildImageDisplay(
      Color headingColor, Color surfaceColor, Color primaryAccent) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: filePath == null
              ? const SizedBox(
                  key: ValueKey('placeholder'),
                  height: 300,
                  width: 300,
                ) // Maintain space to avoid layout jumps
              : Container(
                  key: ValueKey(filePath), // Essential for AnimatedSwitcher
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryAccent.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(filePath!, fit: BoxFit.cover),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            label,
            key: ValueKey(label), // Essential for AnimatedSwitcher
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModelSelector(Color primaryAccent, Color surfaceColor) {
    return ToggleButtons(
      isSelected: [_selectedModel == 'Fruit', _selectedModel == 'Leaf'],
      onPressed: (int index) {
        setState(() {
          _selectedModel = index == 0 ? 'Fruit' : 'Leaf';
          label = "Label"; // Reset label
          filePath = null; // Reset image
        });
      },
      borderRadius: BorderRadius.circular(30.0),
      selectedBorderColor: primaryAccent,
      selectedColor: surfaceColor,
      fillColor: primaryAccent,
      color: primaryAccent,
      constraints: const BoxConstraints(minHeight: 40.0, minWidth: 120.0),
      children: const <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Fruit Model'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Leaf Model'),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color primaryAccent, Color surfaceColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickAndProcessImage(ImageSource.gallery),
          icon: const Icon(Icons.image_outlined),
          label: const Text("Gallery"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryAccent,
            foregroundColor: surfaceColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: const StadiumBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _pickAndProcessImage(ImageSource.camera),
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text("Camera"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryAccent,
            foregroundColor: surfaceColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: const StadiumBorder(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _modelService.dispose(); // Release models when the page is closed
    super.dispose();
  }
}
