import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tflite_service.dart';

class NoteDetectionScreen extends StatefulWidget {
  const NoteDetectionScreen({super.key});

  @override
  State<NoteDetectionScreen> createState() => _NoteDetectionScreenState();
}

class _NoteDetectionScreenState extends State<NoteDetectionScreen> {
  String _status = 'Point your camera at a banknote.';
  bool _modelLoaded = false;

  final FlutterTts _flutterTts = FlutterTts();
  final TFLiteService _tfliteService = TFLiteService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Configure TTS voice
    _flutterTts.setLanguage("en-IN"); // Indian English
    _flutterTts.setSpeechRate(0.45);  // slower for clarity
    _flutterTts.setPitch(1.0);

    // Speak when screen opens
    _speak("Note Detection. Please point your camera at an Indian banknote.");
    _speak("Click on note dectect button at the bottom screen to detect note.");


    _initModel();
    
  }

  Future<void> _initModel() async {
    setState(() {
      _status = "Loading AI model...";
    });
    _speak("Loading  model, please wait.");
    try {
      await _tfliteService.loadModel();
      setState(() {
        _status = "Model ready! Point your camera at a banknote.";
        _modelLoaded = true;
      });
      _speak("Model is ready. Tap Detect Note button to start.");
    } catch (e) {
      setState(() {
        _status = "Error loading model: ${e.toString()}";
      });
      _speak("Error loading model. Please restart the app.");
    }
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> _detectNote() async {
    if (!_modelLoaded) {
      setState(() {
        _status = "Model not ready. Please wait...";
      });
      _speak("Model not ready. Please wait.");
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) {
      _speak("No image captured.");
      return;
    }

    final image = File(pickedFile.path);

    setState(() {
      _status = "Processing...";
    });
    _speak("Processing the note, please wait.");

    try {
      final result = await _tfliteService.runModelOnImage(image);

      setState(() {
        _status = 'Detected: $result';
      });

      _speak("Detected. $result rupees note.");
    } catch (e) {
      setState(() {
        _status = "Error: ${e.toString()}";
      });
      _speak("Error detecting the note.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Note Detection')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cs.primary.withOpacity(.1)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black.withOpacity(.7)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _detectNote,
                    icon: const Icon(Icons.currency_rupee_rounded),
                    label: const Text('Detect Note'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: keep the note flat and well-lit.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withOpacity(.6)),
            ),
          ],
        ),
      ),
    );
  }
}
