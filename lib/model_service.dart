import 'package:tflite_flutter/tflite_flutter.dart';

class ModelService {
  late Interpreter _interpreter;
  final List<String> classLabels = [
    "Bacterial Blight",
    "Fungal Cercospora",
    "Fungal Scab",
    "Healthy",
  ];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      print('✅ Model loaded successfully');
    } catch (e) {
      print('❌ Error loading model: $e');
    }
  }

  Future<Map<String, dynamic>> runInference(List inputTensor) async {
    List<List<double>> output = List.filled(1, List.filled(4, 0.0));
    _interpreter.run(inputTensor, output);

    int predictedClass = output[0].indexOf(
      output[0].reduce((a, b) => a > b ? a : b),
    );
    double confidenceScore = output[0][predictedClass];

    return {'class': predictedClass, 'confidence': confidenceScore};
  }
}
