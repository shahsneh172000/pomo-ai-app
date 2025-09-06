// // ...existing code...
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'image_processor.dart';
// import 'model_service.dart';

// class MyHomePage extends StatefulWidget {
//   final ThemeMode currentThemeMode;
//   final Function(ThemeMode) onThemeModeChanged;

//   const MyHomePage({
//     super.key,
//     required this.currentThemeMode,
//     required this.onThemeModeChanged,
//   });

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   File? filePath;
//   String label = "Select model and pick an image";
//   late ModelService _modelService;
//   late ImageProcessor _imageProcessor;
//   String _selectedModel = 'mobilenetv3'; // default model key
//   bool _isLoadingModels = true;
//   bool _isProcessingImage = false;

//   @override
//   void initState() {
//     super.initState();
//     _modelService = ModelService();
//     _imageProcessor = ImageProcessor(_modelService);
//     _loadModels();
//   }

//   Future<void> _loadModels() async {
//     try {
//       await _modelService.loadModels();
//     } catch (e) {
//       print('❌ Error loading models: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Model load failed: $e')));
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingModels = false;
//         });
//       }
//     }
//   }

//   Future<void> _pickAndProcessImage(ImageSource source) async {
//     if (_isLoadingModels) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Please wait, models are loading...")));
//       return;
//     }
//     if (_isProcessingImage) return;

//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: source);
//     if (image == null) return;

//     File imageFile = File(image.path);
//     try {
//       final File? cropped = await _imageProcessor.cropImage(imageFile);
//       imageFile = cropped ?? imageFile;
//     } catch (e) {
//       print('⚠️ cropImage failed, using original image: $e');
//     }

//     await _processImage(imageFile);
//   }

//   Future<void> _processImage(File imageFile) async {
//     setState(() {
//       filePath = imageFile;
//       _isProcessingImage = true;
//       label = "Running inference...";
//     });

//     try {
//       await _imageProcessor.runInference(imageFile, _selectedModel, (newLabel) {
//         if (mounted) {
//           setState(() {
//             label = newLabel;
//           });
//         }
//       });
//     } catch (e) {
//       print('❌ Inference error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Inference failed: $e')));
//         setState(() {
//           label = "Inference Error";
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isProcessingImage = false;
//         });
//       }
//     }
//   }

//   Future<void> pickImageGallery() async {
//     await _pickAndProcessImage(ImageSource.gallery);
//   }

//   Future<void> pickImageCamera() async {
//     await _pickAndProcessImage(ImageSource.camera);
//   }

//   void _onModelSelected(String modelKey) {
//     if (_selectedModel == modelKey || _isProcessingImage) return;

//     setState(() {
//       _selectedModel = modelKey;
//     });

//     if (filePath != null) {
//       _processImage(filePath!);
//     } else {
//       setState(() {
//         label = "Select model and pick an image";
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _modelService.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Pomo AI"),
//         actions: [
//           IconButton(
//             icon: Icon(widget.currentThemeMode == ThemeMode.dark
//                 ? Icons.dark_mode
//                 : Icons.light_mode),
//             onPressed: () {
//               widget.onThemeModeChanged(widget.currentThemeMode == ThemeMode.light
//                   ? ThemeMode.dark
//                   : ThemeMode.light);
//             },
//           ),
//         ],
//       ),
//       body: _isLoadingModels
//           ? const Center(child: CircularProgressIndicator())
//           : Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     if (filePath != null) ...[
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.file(
//                           filePath!,
//                           width: 300,
//                           height: 300,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                     ],
//                     Text(
//                       label,
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineSmall
//                           ?.copyWith(fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 32),

//                     // model selection UI
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ElevatedButton(
//                           onPressed: _isProcessingImage
//                               ? null
//                               : () => _onModelSelected('mobilenetv3'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _selectedModel == 'mobilenetv3'
//                                 ? Colors.deepPurple
//                                 : null,
//                             foregroundColor:
//                                 _selectedModel == 'mobilenetv3' ? Colors.white : null,
//                           ),
//                           child: const Text('Fruit Model'),
//                         ),
//                         const SizedBox(width: 16),
//                         ElevatedButton(
//                           onPressed: _isProcessingImage
//                               ? null
//                               : () => _onModelSelected('leaf'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 _selectedModel == 'leaf' ? Colors.deepPurple : null,
//                             foregroundColor:
//                                 _selectedModel == 'leaf' ? Colors.white : null,
//                           ),
//                           child: const Text('Leaf Model'),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 24),
//                     const Divider(),
//                     const SizedBox(height: 24),

//                     // Image picker buttons
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.photo_library),
//                           onPressed: (_isLoadingModels || _isProcessingImage)
//                               ? null
//                               : pickImageGallery,
//                           label: const Text("Gallery"),
//                         ),
//                         const SizedBox(width: 16),
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.camera_alt),
//                           onPressed: (_isLoadingModels || _isProcessingImage)
//                               ? null
//                               : pickImageCamera,
//                           label: const Text("Camera"),
//                         ),
//                       ],
//                     ),
//                     if (_isProcessingImage)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 20),
//                         child: CircularProgressIndicator(),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'image_processor.dart';
import 'model_service.dart';
import 'app_localizations.dart';

class MyHomePage extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeModeChanged;
  final String languageCode;
  final Function(String) onLanguageChanged;

  const MyHomePage({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    required this.languageCode,
    required this.onLanguageChanged,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? filePath;
  late String label;
  String? _englishLabel; // To store the original English label from the model
  late ModelService _modelService;
  late ImageProcessor _imageProcessor;
  late AppLocalizations _localizations;
  String _selectedModel = 'mobilenetv3'; // default model key
  bool _isLoadingModels = true;
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _localizations = AppLocalizations(widget.languageCode);
    label = _localizations.get('selectModelAndImage');
    _modelService = ModelService();
    _imageProcessor = ImageProcessor(_modelService);
    _loadModels();
  }

  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageCode != widget.languageCode) {
      setState(() {
        _localizations = AppLocalizations(widget.languageCode);
        if (_isProcessingImage) {
          label = _localizations.get('runningInference');
        } else if (_englishLabel != null) {
          label = _localizations.get(_englishLabel!);
        } else {
          label = _localizations.get('selectModelAndImage');
        }
      });
    }
  }

  Future<void> _loadModels() async {
    try {
      await _modelService.loadModels();
    } catch (e) {
      print('❌ Error loading models: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_localizations.getWithParam(
                'modelLoadFailed', {'error': e.toString()}))));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingModels = false;
        });
      }
    }
  }

  Future<void> _pickAndProcessImage(ImageSource source) async {
    if (_isLoadingModels) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_localizations.get('modelsLoading'))));
      return;
    }
    if (_isProcessingImage) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;

    File imageFile = File(image.path);
    try {
      final File? cropped = await _imageProcessor.cropImage(imageFile);
      imageFile = cropped ?? imageFile;
    } catch (e) {
      print('⚠️ cropImage failed, using original image: $e');
    }

    await _processImage(imageFile);
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      filePath = imageFile;
      _isProcessingImage = true;
      _englishLabel = null;
      label = _localizations.get('runningInference');
    });

    try {
      await _imageProcessor.runInference(imageFile, _selectedModel, (englishLabel) {
        if (mounted) {
          setState(() {
            _englishLabel = englishLabel;
            label = _localizations.get(englishLabel);
          });
        }
      });
    } catch (e) {
      print('❌ Inference error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_localizations.getWithParam('inferenceFailed', {'error': e.toString()}))));
        setState(() {
          _englishLabel = 'inferenceError';
          label = _localizations.get('inferenceError');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

<<<<<<< HEAD
  Future<void> pickImageGallery() async {
    await _pickAndProcessImage(ImageSource.gallery);
=======
  Future<void> _pickAndProcessImage(ImageSource source) async {
    if (_isLoadingModels) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please wait, models are loading...")));
      return;
    }
<<<<<<< HEAD
=======
    if (_isProcessingImage) return;

>>>>>>> 8af1154d6e460739b5c4133173996910028e209a
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;

<<<<<<< HEAD
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
=======
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
>>>>>>> 8af1154d6e460739b5c4133173996910028e209a
        setState(() {
          label = newLabel;
        });
      });
<<<<<<< HEAD
    } else {
      setState(() {
        label = "Could not process image.";
=======
    } catch (e) {
      print('❌ Inference error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inference failed: $e')));
    } finally {
      setState(() {
        _isProcessingImage = false;
>>>>>>> 8af1154d6e460739b5c4133173996910028e209a
      });
    }
>>>>>>> 4cdf5830b7a57d2dead4880d2848052a3eeddfe8
  }

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
=======
  Future<void> pickImageCamera() async {
<<<<<<< HEAD
    await _pickAndProcessImage(ImageSource.camera);
  }

  void _onModelSelected(String modelKey) {
    if (_selectedModel == modelKey || _isProcessingImage) return;
=======
    if (_isLoadingModels) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please wait, models are loading...")));
      return;
    }
    if (_isProcessingImage) return;
>>>>>>> 8af1154d6e460739b5c4133173996910028e209a

    // Futuristic Color Palette with Light/Dark Mode support
    final Color primaryAccent =
        isDarkMode ? const Color(0xFF00BFFF) : const Color(0xFF007BFF); // DeepSkyBlue vs. Strong Blue
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final Color surfaceColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color headingColor = isDarkMode ? Colors.white : Colors.grey.shade800;

<<<<<<< HEAD
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
=======
    File croppedImage;
    try {
      final File? maybe = await _imageProcessor.cropImage(File(image.path));
      croppedImage = maybe ?? File(image.path);
    } catch (e) {
      print('⚠️ cropImage failed, using original image: $e');
      croppedImage = File(image.path);
    }
>>>>>>> 4cdf5830b7a57d2dead4880d2848052a3eeddfe8

    setState(() {
      _selectedModel = modelKey;
    });

<<<<<<< HEAD
    if (filePath != null) {
      _processImage(filePath!);
    } else {
=======
    try {
      await _imageProcessor.runInference(croppedImage, _selectedModel, (newLabel) {
>>>>>>> 8af1154d6e460739b5c4133173996910028e209a
        setState(() {
          _selectedModel = index == 0 ? 'Fruit' : 'Leaf';
          label = "Label"; // Reset label
          filePath = null; // Reset image
        });
<<<<<<< HEAD
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
=======
      });
    } catch (e) {
      print('❌ Inference error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inference failed: $e')));
    } finally {
>>>>>>> 4cdf5830b7a57d2dead4880d2848052a3eeddfe8
      setState(() {
        _englishLabel = null;
        label = _localizations.get('selectModelAndImage');
      });
    }
>>>>>>> 8af1154d6e460739b5c4133173996910028e209a
  }

  @override
  void dispose() {
    _modelService.dispose();
    super.dispose();
  }
<<<<<<< HEAD
}
=======

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_localizations.get('appTitle')),
        actions: [
          IconButton(
            icon: Icon(widget.currentThemeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: () {
              widget.onThemeModeChanged(widget.currentThemeMode == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light);
            },
          ),
          PopupMenuButton<String>(
            onSelected: widget.onLanguageChanged,
            icon: const Icon(Icons.language),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'en', child: Text('English')),
              const PopupMenuItem<String>(value: 'hi', child: Text('हिन्दी')),
            ],
          ),
        ],
      ),
      body: _isLoadingModels
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [Colors.grey.shade900, Colors.grey.shade800]
                      : [Colors.blue.shade50, Colors.purple.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (filePath != null) ...[
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              filePath!,
                              width: 320,
                              height: 320,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              label,
                              key: ValueKey(label),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text(
                                'Choose AI Model',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              Row(
                    children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.local_florist, size: 28),
                                  onPressed: _isProcessingImage ? null : () => _onModelSelected('mobilenetv3'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedModel == 'mobilenetv3' ? Colors.deepPurple : Colors.grey.shade300,
                                    foregroundColor: _selectedModel == 'mobilenetv3' ? Colors.white : Colors.black87,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  label: Text(_localizations.get('fruitModel')),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.eco, size: 28),
                                  onPressed: _isProcessingImage ? null : () => _onModelSelected('leaf'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedModel == 'leaf' ? Colors.deepPurple : Colors.grey.shade300,
                                    foregroundColor: _selectedModel == 'leaf' ? Colors.white : Colors.black87,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  label: Text(_localizations.get('leafModel')),
                                ),
                              ),
                            ],
),

                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Text(
                                'Select Image Source',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                             Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.photo_library_outlined, size: 28),
                                        onPressed: (_isLoadingModels || _isProcessingImage) ? null : pickImageGallery,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        label: Text(_localizations.get('gallery')),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.camera_alt_outlined, size: 28),
                                        onPressed: (_isLoadingModels || _isProcessingImage) ? null : pickImageCamera,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        label: Text(_localizations.get('camera')),
                                      ),
                                    ),
                                  ],
                                ),

                            ],
                          ),
                        ),
                      ),
                      if (_isProcessingImage)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
<<<<<<< HEAD
=======
>>>>>>> 8af1154d6e460739b5c4133173996910028e209a
>>>>>>> 4cdf5830b7a57d2dead4880d2848052a3eeddfe8
