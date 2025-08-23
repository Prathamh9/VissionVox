import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vision_vox/screens/home_screen.dart';
import 'package:vision_vox/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VisionVoxApp());
}

class VisionVoxApp extends StatelessWidget {
  const VisionVoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = buildVisionVoxTheme();
    return MaterialApp(
      title: 'Vision Vox',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomeScreen(),
    );
  }
}
