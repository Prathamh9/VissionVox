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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
      final extracted = await _ocr.extractText(File(picked.path));
      setState(() => _ctrl.text = extracted.isNotEmpty ? extracted : "No text found in image.");
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
          Text('Type, paste, or upload a picture to extract text and hear it.',
              style: TextStyle(color: Colors.black.withOpacity(.7))),
          const SizedBox(height: 12),

          // ✅ Upload Button
          FilledButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text("Upload Picture"),
          ),
          if (_pickedImage != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_pickedImage!, height: 180, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 12),

          // ✅ Text Field (Auto-filled by OCR)
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

          // ✅ Speak + Stop
          FilledButton.icon(
            onPressed: () => _tts.speak(_ctrl.text),
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
