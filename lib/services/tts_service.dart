import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService with ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  double _rate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  String _language = 'en-IN';
  bool _isSpeaking = false;

  TtsService() {
    _init();
    _tts.awaitSpeakCompletion(true);
  }

  double get rate => _rate;
  double get pitch => _pitch;
  double get volume => _volume;
  String get language => _language;
  bool get isSpeaking => _isSpeaking;

  Future<void> _init() async {
    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(_pitch);
    await _tts.setVolume(_volume);
    try {
      await _tts.setLanguage(_language);
    } catch (_) {
      // fallback if device doesn't support en-IN
      await _tts.setLanguage('en-US');
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    _isSpeaking = true;
    notifyListeners();
    await _tts.speak(text);
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  void update({
    double? rate,
    double? pitch,
    double? volume,
    String? language,
  }) {
    if (rate != null) _rate = rate.clamp(0.2, 1.0);
    if (pitch != null) _pitch = pitch.clamp(0.5, 2.0);
    if (volume != null) _volume = volume.clamp(0.0, 1.0);
    if (language != null) _language = language;
    _init();
    notifyListeners();
  }
}
