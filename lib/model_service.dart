// ...existing code...
import 'package:onnxruntime/onnxruntime.dart' as ort;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class ModelService {
  ort.OrtSessionOptions? _sessionOptions;
  ort.OrtRunOptions? _runOptions;


  // sessions keyed by lowercase model key: 'mobilenetv3','leaf'
  final Map<String, ort.OrtSession?> _sessions = {};

  final List<String> fruitLabels = [
    "Bacterial Blight",
    "Calyx Rot",
    "Fungal Cercospora",
    "Fruit Rot",
    "Healthy",
    "Fungal Scab",
  ];

  final List<String> leafLabels = ["Bacterial", "Fungal", "Healthy"];

  // Map of asset paths (must match pubspec.yaml)
  final Map<String, String> _assetMap = {
    'fruitnet': 'assets/App_ResNet.onnx',
    'leaf': 'assets/LeafModel.onnx',
  };

  Future<void> loadModels() async {
    try {
      // Initialize ONNX Runtime environment
      ort.OrtEnv.instance.init();

      // Session options
      _sessionOptions = ort.OrtSessionOptions();

      // Load all models defined in _assetMap
      for (final entry in _assetMap.entries) {
        final key = entry.key; // lowercase key
        final raw = await rootBundle.load(entry.value);
        final bytes = raw.buffer.asUint8List();
        final session = ort.OrtSession.fromBuffer(bytes, _sessionOptions!);
        _sessions[key] = session;
        print('✅ Loaded model for key: $key');
      }

      // Run options
      _runOptions = ort.OrtRunOptions();

      print('✅ All ONNX models loaded successfully');
    } catch (e) {
      print('❌ Error loading ONNX models: $e');
      rethrow;
    }
  }

  // inputData is Float32List in NCHW order (1,3,224,224)
  Future<Map<String, dynamic>> runInference(
    Float32List inputData,
    String modelType,
  ) async {
    final key = modelType.toLowerCase();
    final session = _sessions[key];
    if (session == null || _runOptions == null) {
      throw Exception("Model not loaded or runtime not initialized for key: $key");
    }

    // Create tensor with preprocessed image data
    final inputOrt = ort.OrtValueTensor.createTensorWithDataList(
      inputData,
      [1, 3, 224, 224],
    );

    // NOTE: using input name 'input' as before; if your model uses a different input name,
    // adjust this to the actual input name expected by that ONNX model.
    final inputs = {'input': inputOrt};

    final outputs = session.run(
      _runOptions!,
      inputs,
    );

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
      inputOrt.release();
      throw Exception("Unexpected output format: $outputTensor");
    }

    final predictedClass = probabilities.indexOf(
      probabilities.reduce((a, b) => a > b ? a : b),
    );

    // cleanup
    inputOrt.release();

    return {'class': predictedClass};
  }

  String getLabel(int classIndex, String modelType) {
    final key = modelType.toLowerCase();
    if (key == 'leaf') {
      return leafLabels[classIndex];
    }
    // default to fruit model labels
    return fruitLabels[classIndex];
  }

  void dispose() {
    try {
      _runOptions?.release();
      for (final s in _sessions.values) {
        s?.release();
      }
      _sessions.clear();
      _sessionOptions?.release();
      ort.OrtEnv.instance.release();
      print('✅ ONNX Models released');
    } catch (e) {
      print('❌ Error releasing ONNX resources: $e');
    }
  }
}
// ...existing code...