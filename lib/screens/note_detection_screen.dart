import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NoteDetectionScreen extends StatefulWidget {
  const NoteDetectionScreen({super.key});

  @override
  State<NoteDetectionScreen> createState() => _NoteDetectionScreenState();
}

class _NoteDetectionScreenState extends State<NoteDetectionScreen> {
  String _status = 'Point your camera at a banknote.\n(Prototype mode)';
  bool _torch = false;

  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("en-IN"); // Indian English accent
    _flutterTts.setSpeechRate(0.45);  // slower for clarity
    _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop(); // stop if already speaking
    await _flutterTts.speak(text);
  }

  void _demoDetect() {
    setState(() {
      _status = 'Detected: ₹50 (confidence 0.91)\nSay: “Fifty Rupees”.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo detection triggered')),
    );

    // 👇 Speech output
    _speak("Fifty Rupees");
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
                    onPressed: _demoDetect,
                    icon: const Icon(Icons.currency_rupee_rounded),
                    label: const Text('Demo Detect'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _torch = !_torch),
                    icon: Icon(_torch ? Icons.flash_on : Icons.flash_off),
                    label: Text(_torch ? 'Torch ON' : 'Torch OFF'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: keep the note flat and well-lit.\n(Plug your model to replace demo.)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withOpacity(.6)),
            ),
          ],
        ),
      ),
    );
  }
}
