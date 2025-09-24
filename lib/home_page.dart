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
//         title: const Text("Anar Rakshak"),
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
import 'image_processor.dart';
import 'management_page.dart';
import 'management_service.dart';
import 'model_service.dart';
import 'app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyHomePage extends StatefulWidget {

  final String languageCode;
  final Function(String) onLanguageChanged;
  final ModelService modelService;
  final ManagementService managementService;

  const MyHomePage({
    super.key,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.modelService,
    required this.managementService,
  });


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? filePath;

  late String label;
  String? _englishLabel; // To store the original English label from the model
  double? _confidence; // To store the prediction confidence

  Map<String, dynamic>? _currentManagementTechniques; // To store fetched techniques

  late ModelService _modelService;
  late ImageProcessor _imageProcessor;
  late ManagementService _managementService;
  late AppLocalizations _localizations;
  String _selectedModel = 'fruitnet';
  bool _isLoadingModels = false; // Models are pre-loaded by SplashScreen
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _localizations = AppLocalizations(widget.languageCode);
    label = _localizations.get('selectModelAndImage');
    _modelService = widget.modelService;
    _imageProcessor = ImageProcessor(_modelService);
    _managementService = widget.managementService;
  }

  void _applyLanguageChange(String newLanguageCode) {
    setState(() {
      _localizations = AppLocalizations(newLanguageCode);
      if (_isProcessingImage) {
        label = _localizations.get('runningInference');
      } else if (_englishLabel != null) {
        label = _localizations.get(_englishLabel!);
        // Re-fetch management techniques for the new language
        if (_englishLabel != 'Healthy' && _englishLabel != 'inferenceError') {
          _currentManagementTechniques = _managementService.getTechnique(_englishLabel!, newLanguageCode);
        } else {
          _currentManagementTechniques = null;
        }
      } else {
        label = _localizations.get('selectModelAndImage');
        _currentManagementTechniques = null;
        _confidence = null;
      }
    });
  }

  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageCode != widget.languageCode) {
      _applyLanguageChange(widget.languageCode);
    }
  }

  void _onLanguageSelected(String newLanguageCode) {
    widget.onLanguageChanged(newLanguageCode);
    _applyLanguageChange(newLanguageCode);
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
      _confidence = null;
      _currentManagementTechniques = null; // Clear previous techniques
      label = _localizations.get('runningInference');
    });

    try {
      await _imageProcessor.runInference(imageFile, _selectedModel, (englishLabel, confidence) {
        if (mounted) {
          setState(() {
            _englishLabel = englishLabel;
            label = _localizations.get(englishLabel);
            _confidence = confidence;
            // Fetch management techniques after successful prediction
            if (englishLabel != 'Healthy' && englishLabel != 'inferenceError') {
              _currentManagementTechniques = _managementService.getTechnique(englishLabel, widget.languageCode);
            } else {
              _currentManagementTechniques = null;
            }
          });
        }
      });
    } catch (e) {
      print('❌ Inference error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_localizations.getWithParam('inferenceFailed', {'error': e.toString()}))));
        setState(() {
          _englishLabel = 'inferenceError';
          _confidence = null;
          _currentManagementTechniques = null; // Clear techniques on error
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

  Future<void> _selectModelAndPickImage(String modelKey) async {
    if (_isProcessingImage) return;

    final isImplemented = modelKey == 'fruitnet' || modelKey == 'leaf';
    if (!isImplemented) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_localizations.get('featureComingSoon'))),
        );
      }
      return;
    }

    // Set the model for the upcoming inference.
    setState(() {
      _selectedModel = modelKey;
    });

    if (!mounted) return;

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localizations.get('selectImageSource')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.photo_library_outlined, size: 28),
            label: Text(_localizations.get('gallery')),
            onPressed: () {
              Navigator.of(context).pop(ImageSource.gallery);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.camera_alt_outlined, size: 28),
            label: Text(_localizations.get('camera')),
            onPressed: () {
              Navigator.of(context).pop(ImageSource.camera);
            },
          ),
        ],
      ),
    );

    if (source != null) {
      await _pickAndProcessImage(source);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 40.0, bottom: 12.0, right: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryButton({
    required String svgPath,
    required String label,
    String? description,
    required String modelKey,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade800.withOpacity(0.7), Colors.green.shade600.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: _isProcessingImage ? null : () => _selectModelAndPickImage(modelKey), // Use the passed modelKey
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 20),
            minimumSize: const Size(0, 100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(svgPath, width: 36, height: 36, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToManagementPage() {
    if (_currentManagementTechniques == null || _currentManagementTechniques!['description'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_localizations.get('noManagementInfo'))),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagementPage(
          diseaseKey: _englishLabel!,
          managementService: _managementService,
          languageCode: widget.languageCode,
          onLanguageChanged: widget.onLanguageChanged,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _modelService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Logo
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/app_icon.png'),
                radius: 22,
              ),
            ),
            // Title and Tagline
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _localizations.get('appTitle'),
                  style: const TextStyle(
                    fontSize: 24, // Bigger font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(_localizations.get('appTagline'), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onLanguageSelected,
            icon: const Icon(Icons.language),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'en', child: Text('English')),
              const PopupMenuItem<String>(value: 'hi', child: Text('हिन्दी')),
              const PopupMenuItem<String>(value: 'gu', child: Text('ગુજરાતી')),
              const PopupMenuItem<String>(value: 'mr', child: Text('मराठी')),
              const PopupMenuItem<String>(value: 'kn', child: Text('ಕನ್ನಡ')),
              const PopupMenuItem<String>(value: 'te', child: Text('తెలుగు')),
            ],

          ),
        ],
      ),
      body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // Unified dark green gradient for both light and dark themes
                  colors: [const Color(0xFF1B5E20), const Color(0xFF103c1b)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
                        const SizedBox(height: 12),
                      ],
                      if (filePath != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Column(
                                  key: ValueKey(label + (_confidence?.toString() ?? '')),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      label,
                                      style: Theme.of(context)
                                          .textTheme
                                        .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_confidence != null &&
                                        _englishLabel != null &&
                                        _englishLabel != 'inferenceError' &&
                                        _englishLabel != 'Healthy')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          _localizations.getWithParam('confidence', {'score': (_confidence! * 100).toStringAsFixed(2)}),
                                          style: Theme.of(context)
                                              .textTheme.bodyLarge
                                              ?.copyWith(color: Colors.white.withOpacity(0.8)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ),
                        ),
                      if (_englishLabel != null &&
                          _englishLabel != 'Healthy' &&
                          _englishLabel != 'inferenceError' &&
                          _currentManagementTechniques != null &&
                          _currentManagementTechniques!['description'] != _localizations.get('noManagementInfo'))
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade800.withOpacity(0.7),
                                  Colors.green.shade600.withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.info_outline),
                              label: Text(
                                _localizations.get('showManagementTechniques'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 15),
                              ),
                              onPressed: _navigateToManagementPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                        ),
                      if (filePath != null)
                        const SizedBox(height: 16),
                      // Diseases Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildSectionHeader(_localizations.get('diseaseCategory')),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            _buildCategoryButton(
                              svgPath: 'assets/icons/fruit.svg',
                              label: _localizations.get('fruit'),
                              modelKey: 'fruitnet',
                            ),
                            const SizedBox(width: 12),
                            _buildCategoryButton(
                              svgPath: 'assets/icons/leaf.svg',
                              label: _localizations.get('leaf'),
                              modelKey: 'leaf',
                            ),
                            const SizedBox(width: 12),
                            _buildCategoryButton(
                              svgPath: 'assets/icons/root.svg',
                              label: _localizations.get('root'),
                              modelKey: 'root_model',
                            ),
                          ],
                        ),
                      ),
                      // Pests Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildSectionHeader(_localizations.get('pestsCategory')),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            _buildCategoryButton(
                              svgPath: 'assets/icons/insects.svg',
                              label: _localizations.get('insects'),
                              description: _localizations.get('insectsDescription'),
                              modelKey: 'insects_model',
                            ),
                            const SizedBox(width: 12),
                            _buildCategoryButton(
                              svgPath: 'assets/icons/mix.svg',
                              label: _localizations.get('flowers'), // Assuming 'flowers' is a valid key
                              modelKey: 'flowers_model',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
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
