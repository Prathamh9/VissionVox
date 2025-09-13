import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vision_vox/screens/note_detection_screen.dart';
import 'package:vision_vox/screens/text_to_speech_screen.dart';
import 'package:vision_vox/services/raspberry_service.dart';
import 'package:vision_vox/services/tts_service.dart';
import 'package:vision_vox/widgets/feature_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RaspberryService _raspberry = RaspberryService.instance;

  @override
  void initState() {
    super.initState();
    _raspberry.loadSavedEndpoint();

    // 🔊 Speak welcome message when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tts = Provider.of<TtsService>(context, listen: false);
      tts.speak(
        "Welcome to Vision Vox. You have three options. "
        "Text to Speech for reading text aloud. "
        "Note Detection for recognizing Indian currency. "
        "Or Connect Pi to link with Raspberry Pi device."
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tts = Provider.of<TtsService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Vox'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: AnimatedBuilder(
                animation: _raspberry,
                builder: (_, __) {
                  final connected = _raspberry.isConnected;
                  return Row(
                    children: [
                      Icon(
                        connected
                            ? Icons.podcasts_rounded
                            : Icons.podcasts_outlined,
                        color: connected ? cs.secondary : cs.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        connected ? 'Connected' : 'Offline',
                        style: TextStyle(
                          color: connected ? cs.secondary : cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              // Header banner
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withOpacity(.12),
                      cs.secondary.withOpacity(.12)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 40, color: cs.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Assistive AI for everyday independence',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height:22),

              // 🔥 Expanded GridView
              Expanded(
                child: GridView.count(
                  crossAxisCount: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2,
                  children: [
                    FeatureCard(
                      title: 'Text to Speech',
                      caption: 'OCR → Voice',
                      icon: Icons.record_voice_over,
                      accentBlend: true,
                      onTap: () {
                        tts.speak("Opening Text to Speech");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TextToSpeechScreen(),
                          ),
                        );
                      },
                    ),
                    FeatureCard(
                      title: 'Note Detection',
                      caption: 'Currency helper',
                      icon: Icons.currency_rupee_rounded,
                      onTap: () {
                        tts.speak("Opening Note Detection");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NoteDetectionScreen(),
                          ),
                        );
                      },
                    ),
                    FeatureCard(
                      title: 'Connect Pi',
                      caption: 'Wearable link',
                      icon: Icons.link_rounded,
                      onTap: () {
                        tts.speak("Opening Raspberry Pi connection settings");
                        _showConnectDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Big connect button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    tts.speak("Connect to Raspberry Pi");
                    _showConnectDialog(context);
                  },
                  icon: const Icon(Icons.podcasts_rounded),
                  label: const Text('Connect to Raspberry Pi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConnectDialog(BuildContext context) async {
    final ctrl = TextEditingController(
        text: _raspberry.endpoint ?? 'ws://192.168.4.1:8080');
    final formKey = GlobalKey<FormState>();
    final cs = Theme.of(context).colorScheme;
    final tts = Provider.of<TtsService>(context, listen: false);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Connect to Raspberry Pi'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'WebSocket URL',
              hintText: 'ws://<ip>:<port>',
            ),
            validator: (v) => (v == null ||
                    v.isEmpty ||
                    !v.startsWith('ws://'))
                ? 'Enter a valid ws:// URL'
                : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                tts.speak("Cancelled");
                Navigator.pop(context);
              },
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.secondary),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await _raspberry.connect(ctrl.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                final msg = ok
                    ? 'Connected to Raspberry Pi'
                    : 'Failed to connect';
                tts.speak(msg);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
                setState(() {});
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
