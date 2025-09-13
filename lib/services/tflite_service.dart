import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  // Helpers for image package
  double _r(img.Pixel p) => p.r.toDouble();
  double _g(img.Pixel p) => p.g.toDouble();
  double _b(img.Pixel p) => p.b.toDouble();

  Future<void> loadModel() async {
    try {
      // Load TFLite model ( path relative to pubspec.yaml)
      _interpreter = await Interpreter.fromAsset('assets/models/model_unquant.tflite');

      // Load labels (string assets keep "assets/" prefix)
      final raw = await rootBundle.loadString('assets/models/labels.txt');
      _labels = raw
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Log shapes
      final inShape = _interpreter!.getInputTensor(0).shape;
      final outShape = _interpreter!.getOutputTensor(0).shape;
      print(" Model loaded | labels=${_labels.length} | in=$inShape out=$outShape");
    } catch (e) {
      print(' Failed to load model: $e');
      rethrow;
    }
  }

  Future<String> runModelOnImage(File imageFile) async {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw Exception('Interpreter not initialized. Call loadModel() first.');
    }

    // Decode image
    final decoded = img.decodeImage(await imageFile.readAsBytes());
    if (decoded == null) throw Exception('Could not decode image');

    // Read expected input shape dynamically [1, H, W, C]
    final inputShape = interpreter.getInputTensor(0).shape;
    final height = inputShape[1];
    final width = inputShape[2];
    final channels = inputShape.length >= 4 ? inputShape[3] : 3;

    // Resize
    final resized = img.copyResize(decoded, width: width, height: height);

    // Build input tensor [1, H, W, C]
    final input = List.generate(
      1,
      (_) => List.generate(
        height,
        (y) => List.generate(
          width,
          (x) {
            final p = resized.getPixelSafe(x, y);
            if (channels == 3) {
              return [_r(p) / 255.0, _g(p) / 255.0, _b(p) / 255.0];
            } else {
              final gray =
                  (_r(p) * 0.299 + _g(p) * 0.587 + _b(p) * 0.114) / 255.0;
              return [gray];
            }
          },
        ),
      ),
    );

    // Prepare output buffer
    final outputShape = interpreter.getOutputTensor(0).shape; // e.g. [1, N]
    final numClasses = outputShape.last;
    final output = List.generate(1, (_) => List.filled(numClasses, 0.0));

    // Run inference
    interpreter.run(input, output);

    // Convert to double list
    final probs = output[0].cast<double>();

    // Argmax
    final maxIdx = probs.indexOf(probs.reduce((a, b) => a > b ? a : b));
    final label =
        (maxIdx >= 0 && maxIdx < _labels.length) ? _labels[maxIdx] : 'Unknown';

    print(' Prediction: $label (p=${probs[maxIdx]})');
    return label;
  }

  void close() => _interpreter?.close();
}
