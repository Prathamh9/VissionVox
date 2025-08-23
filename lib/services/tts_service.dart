import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService with ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  double _rate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  String _language = 'en-IN';

  TtsService() {
    _init();
  }

  double get rate => _rate;
  double get pitch => _pitch;
  double get volume => _volume;
  String get language => _language;

  Future<void> _init() async {
    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(_pitch);
    await _tts.setVolume(_volume);
    await _tts.setLanguage(_language);
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();

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
