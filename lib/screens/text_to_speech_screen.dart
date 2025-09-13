import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vision_vox/services/tts_service.dart';
import 'package:vision_vox/services/ocr_service.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final _tts = TtsService();
  final _ocr = OcrService();
  final _ctrl = TextEditingController();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    // Speak welcome instructions
    _tts.speak(
      "Text to Speech. You can capture a photo, pick from gallery, "
      "or type text manually. Use the buttons below to get started."
    );
  }

  /// Pick from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await _processImage(File(picked.path));
      _tts.speak("Image selected from gallery. Extracting text.");
    } else {
      _tts.speak("No image selected.");
    }
  }

  /// Capture from camera
  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final captured = await picker.pickImage(source: ImageSource.camera);
    if (captured != null) {
      await _processImage(File(captured.path));
      _tts.speak("Image captured. Extracting text.");
    } else {
      _tts.speak("No image captured.");
    }
  }

  /// Shared method → OCR + Update text + Speak
  Future<void> _processImage(File file) async {
    setState(() => _pickedImage = file);
    final extracted = await _ocr.extractText(file);

    setState(() => _ctrl.text = extracted.isNotEmpty ? extracted : "No text found in image.");

    if (extracted.isNotEmpty) {
      await _tts.speak("Text detected. Reading now. $extracted");
    } else {
      await _tts.speak("No text found in the image.");
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _ocr.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Text to Speech')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Type, capture, or upload a picture to extract text and hear it.',
            style: TextStyle(color: Colors.black.withOpacity(.7)),
          ),
          const SizedBox(height: 12),

          // ✅ Buttons: Camera + Gallery
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _captureImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Capture"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Gallery"),
                ),
              ),
            ],
          ),

          if (_pickedImage != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_pickedImage!, height: 180, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 12),

          //  Text Field (Auto-filled by OCR)
          TextField(
            controller: _ctrl,
            minLines: 5,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Enter text or OCR result...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sliders
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _tts.rate,
                  onChanged: (v) => setState(() => _tts.update(rate: v)),
                  min: 0.2, max: 1.0,
                ),
              ),
              Text('Speed', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _tts.pitch,
                  onChanged: (v) => setState(() => _tts.update(pitch: v)),
                  min: 0.5, max: 2.0,
                ),
              ),
              Text('Pitch', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _tts.volume,
                  onChanged: (v) => setState(() => _tts.update(volume: v)),
                  min: 0.0, max: 1.0,
                ),
              ),
              Text('Volume', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700)),
            ],
          ),

          const SizedBox(height: 12),

          // Speak + Stop
          FilledButton.icon(
            onPressed: () {
              if (_ctrl.text.trim().isEmpty) {
                _tts.speak("No text to read. Please type or capture text.");
              } else {
                _tts.speak(_ctrl.text);
              }
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Speak'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _tts.stop,
            icon: const Icon(Icons.stop_rounded),
            label: const Text('Stop'),
          ),
        ],
      ),
    );
  }
}
