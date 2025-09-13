import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RaspberryService extends ChangeNotifier {
  RaspberryService._();
  static final RaspberryService instance = RaspberryService._();

  WebSocketChannel? _channel;
  String? _endpoint;
  bool _isConnected = false;
  Timer? _heartbeat;
  Timer? _reconnectTimer;
  final FlutterTts _tts = FlutterTts();

  String? get endpoint => _endpoint;
  bool get isConnected => _isConnected;

  Future<void> loadSavedEndpoint() async {
    final sp = await SharedPreferences.getInstance();
    _endpoint = sp.getString('pi_endpoint');
    notifyListeners();
  }

  Future<bool> connect(String endpoint, {bool autoRetry = true}) async {
    await disconnect();
    try {
      _channel = WebSocketChannel.connect(Uri.parse(endpoint));
      _endpoint = endpoint;
      (await SharedPreferences.getInstance())
          .setString('pi_endpoint', endpoint);

      _channel!.stream.listen((event) {
        debugPrint('📡 Pi says: $event');
        _speak("Message from Pi: $event");
      }, onDone: () {
        _isConnected = false;
        notifyListeners();
        _speak("Disconnected from Raspberry Pi");
        if (autoRetry) _scheduleReconnect();
      }, onError: (e) {
        _isConnected = false;
        notifyListeners();
        _speak("Error connecting to Raspberry Pi");
        if (autoRetry) _scheduleReconnect();
      });

      _isConnected = true;
      _speak("Connected to Raspberry Pi");
      _startHeartbeat();
      notifyListeners();
      return true;
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      _speak("Failed to connect to Raspberry Pi");
      if (autoRetry) _scheduleReconnect();
      return false;
    }
  }

  Future<void> send(String message) async {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(message);
    } else {
      _speak("Not connected. Please connect to Raspberry Pi first.");
    }
  }

  Future<void> disconnect() async {
    _heartbeat?.cancel();
    _reconnectTimer?.cancel();
    _heartbeat = null;
    _reconnectTimer = null;
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _speak("Disconnected from Raspberry Pi");
    notifyListeners();
  }

  void _startHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_isConnected) {
        send('{"type":"ping"}');
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      if (!_isConnected && _endpoint != null) {
        connect(_endpoint!, autoRetry: true);
      }
    });
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }
}
