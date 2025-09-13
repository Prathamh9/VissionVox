// import 'package:flutter/material.dart';
// import 'package:vision_vox/services/tts_service.dart';

// class VisionAssistanceScreen extends StatefulWidget {
//   const VisionAssistanceScreen({super.key});
//   @override
//   State<VisionAssistanceScreen> createState() => _VisionAssistanceScreenState();
// }

// class _VisionAssistanceScreenState extends State<VisionAssistanceScreen> {
//   final _tts = TtsService();
//   bool _running = false;
//   String _hint = 'Start assistance to receive audio cues.\n(Prototype mode)';

//   @override
//   void dispose() {
//     _tts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Vision Assistance')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(.04),
//                   border: Border.all(color: cs.primary.withOpacity(.1)),
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   _hint,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.black.withOpacity(.7)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             FilledButton.icon(
//               onPressed: () async {
//                 setState(() => _running = !_running);
//                 if (_running) {
//                   setState(() => _hint = 'Obstacle ahead at 2 meters.\nCrosswalk to your right.');
//                   await _tts.speak('Obstacle ahead at two meters. Crosswalk to your right.');
//                 } else {
//                   setState(() => _hint = 'Assistance paused.');
//                   await _tts.stop();
//                 }
//               },
//               icon: Icon(_running ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
//               label: Text(_running ? 'Pause Assistance' : 'Start Assistance'),
//             ),
//             const SizedBox(height: 8),
//             OutlinedButton.icon(
//               onPressed: () => _tts.speak('Battery 78 percent. Connection stable.'),
//               icon: const Icon(Icons.volume_up_rounded),
//               label: const Text('Speak Status'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
