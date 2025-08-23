import 'package:flutter/material.dart';
import 'package:vision_vox/screens/note_detection_screen.dart';
import 'package:vision_vox/screens/text_to_speech_screen.dart';
import 'package:vision_vox/screens/vision_assistance_screen.dart';
import 'package:vision_vox/services/raspberry_service.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                        connected ? Icons.podcasts_rounded : Icons.podcasts_outlined,
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            // Header banner
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary.withOpacity(.12), cs.secondary.withOpacity(.12)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
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
            const SizedBox(height: 22),

            // Feature grid
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: .95),
              children: [
                FeatureCard(
                  title: 'Text to Speech',
                  caption: 'OCR → Voice',
                  icon: Icons.record_voice_over,
                  accentBlend: true,
                  onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const TextToSpeechScreen())),
                ),
                FeatureCard(
                  title: 'Note Detection',
                  caption: 'Currency helper',
                  icon: Icons.currency_rupee_rounded,
                  onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const NoteDetectionScreen())),
                ),
                FeatureCard(
                  title: 'Vision Assistance',
                  caption: 'Realtime cues',
                  icon: Icons.camera_alt_rounded,
                  onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const VisionAssistanceScreen())),
                ),
                FeatureCard(
                  title: 'Connect Pi',
                  caption: 'Wearable link',
                  icon: Icons.link_rounded,
                  onTap: () => _showConnectDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Big connect button (redundant for accessibility)
            ElevatedButton.icon(
              onPressed: () => _showConnectDialog(context),
              icon: const Icon(Icons.podcasts_rounded),
              label: const Text('Connect to Raspberry Pi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showConnectDialog(BuildContext context) async {
    final ctrl = TextEditingController(text: _raspberry.endpoint ?? 'ws://192.168.4.1:8080');
    final formKey = GlobalKey<FormState>();
    final cs = Theme.of(context).colorScheme;

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
            validator: (v) =>
                (v == null || v.isEmpty || !v.startsWith('ws://')) ? 'Enter a valid ws:// URL' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.secondary),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await _raspberry.connect(ctrl.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Connected to Raspberry Pi' : 'Failed to connect'),
                ));
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
