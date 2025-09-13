import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from an image file
  Future<String> extractText(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Trim extra whitespace
      final text = recognizedText.text.trim();

      if (text.isEmpty) {
        return "No text found in image.";
      }
      return text;
    } catch (e) {
      // Log and return friendly message
      print("❌ OCR failed: $e");
      return "Error reading text. Please try again.";
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
