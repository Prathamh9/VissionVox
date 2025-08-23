import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RaspberryService extends ChangeNotifier {
  RaspberryService._();
  static final RaspberryService instance = RaspberryService._();

  WebSocketChannel? _channel;
  String? _endpoint;
  bool _isConnected = false;
  Timer? _heartbeat;

  String? get endpoint => _endpoint;
  bool get isConnected => _isConnected;

  Future<void> loadSavedEndpoint() async {
    final sp = await SharedPreferences.getInstance();
    _endpoint = sp.getString('pi_endpoint');
    notifyListeners();
  }

  Future<bool> connect(String endpoint) async {
    await disconnect();
    try {
      _channel = WebSocketChannel.connect(Uri.parse(endpoint));
      _endpoint = endpoint;
      (await SharedPreferences.getInstance()).setString('pi_endpoint', endpoint);

      _channel!.stream.listen((event) {
        // Handle messages from Pi here
        debugPrint('Pi: $event');
      }, onDone: () {
        _isConnected = false;
        notifyListeners();
      }, onError: (e) {
        _isConnected = false;
        notifyListeners();
      });

      _isConnected = true;
      _startHeartbeat();
      notifyListeners();
      return true;
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> send(String message) async {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(message);
    }
  }

  Future<void> disconnect() async {
    _heartbeat?.cancel();
    _heartbeat = null;
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false;
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
}
