import 'package:onnxruntime/onnxruntime.dart' as ort;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class ModelService {
  ort.OrtSession? _fruitSession; // For model.onnx (fruit)
  ort.OrtSession? _leafSession; // For LeafModel.onnx (leaf)
  ort.OrtSessionOptions? _sessionOptions;
  ort.OrtRunOptions? _runOptions;

  final List<String> fruitLabels = [
    "Bacterial Blight",
    "Calyx Rot",
    "Fungal Cercospora",
    "Fruit Rot",
    "Healthy",
    "Fungal Scab",
  ];

  final List<String> leafLabels = ["Bacterial", "Fungal", "Healthy"];

  Future<void> loadModels() async {
    try {
      // Initialize ONNX Runtime environment
      ort.OrtEnv.instance.init();

      // Load session options
      _sessionOptions = ort.OrtSessionOptions();

      // Load the Fruit model (model.onnx)
      final fruitRawAssetFile = await rootBundle.load("assets/FruitModel.onnx");
      final fruitBytes = fruitRawAssetFile.buffer.asUint8List();
      _fruitSession = ort.OrtSession.fromBuffer(fruitBytes, _sessionOptions!);

      // Load the Leaf model (LeafModel.onnx)
      final leafRawAssetFile = await rootBundle.load("assets/LeafModel.onnx");
      final leafBytes = leafRawAssetFile.buffer.asUint8List();
      _leafSession = ort.OrtSession.fromBuffer(leafBytes, _sessionOptions!);

      // Initialize run options
      _runOptions = ort.OrtRunOptions();

      print('✅ Both ONNX Models loaded successfully');
    } catch (e) {
      print('❌ Error loading ONNX models: $e');
      rethrow; // Rethrow to ensure caller knows loading failed
    }
  }

  Future<Map<String, dynamic>> runInference(
    Float32List inputData,
    String modelType,
  ) async {
    if (_fruitSession == null || _leafSession == null || _runOptions == null) {
      throw Exception("Models not loaded yet");
    }

    // Create tensor with preprocessed image data
    final inputOrt = ort.OrtValueTensor.createTensorWithDataList(
      inputData,
      [1, 3, 224, 224], // Shape: (1, 3, 224, 224)
    );

    // Define inputs (assuming both models expect an input named "input")
    final inputs = {'input': inputOrt};

    // Run inference with the selected model
    final outputs = (modelType == 'Fruit' ? _fruitSession! : _leafSession!).run(
      _runOptions!,
      inputs,
    );

    // Process output
    final outputTensor = outputs[0]?.value;
    List<double> probabilities;
    if (outputTensor is List && outputTensor.isNotEmpty) {
      if (outputTensor[0] is List) {
        probabilities =
            (outputTensor[0] as List).map((e) => e as double).toList();
      } else {
        probabilities = outputTensor.map((e) => e as double).toList();
      }
    } else {
      throw Exception("Unexpected output format: $outputTensor");
    }

    // Get predicted class
    final predictedClass = probabilities.indexOf(
      probabilities.reduce((a, b) => a > b ? a : b),
    );

    // Clean up input tensor
    inputOrt.release();

    return {'class': predictedClass};
  }

  String getLabel(int classIndex, String modelType) {
    return modelType == 'Fruit'
        ? fruitLabels[classIndex]
        : leafLabels[classIndex];
  }

  void dispose() {
    _runOptions?.release();
    _fruitSession?.release();
    _leafSession?.release();
    _sessionOptions?.release();
    ort.OrtEnv.instance.release();
    print('✅ ONNX Models released');
  }
}
