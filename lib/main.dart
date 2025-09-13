import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vision_vox/screens/home_screen.dart';
import 'package:vision_vox/theme.dart';
import 'package:vision_vox/services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VisionVoxApp());
}

class VisionVoxApp extends StatelessWidget {
  const VisionVoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = buildVisionVoxTheme();
    return ChangeNotifierProvider(
      create: (_) => TtsService(),
      child: MaterialApp(
        title: 'VisionVox',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const HomeScreen(),
      ),
    );
  }
}
