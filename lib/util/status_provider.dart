import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DetectStatus with ChangeNotifier {
  bool _nowDetecting = false;
  bool _detectAvailable = false;

  bool get nowDetecting => _nowDetecting;
  bool get detectAvailable => _detectAvailable;

  double nowGyroX = 0;
  double nowGyroY = 0;
  double nowGyroZ = 0;
  double nowAccX = 0;
  double nowAccY = 0;
  double nowAccZ = 0;

  DetectStatus() {
    init();
  }

  void init() async {
    final storage = FlutterSecureStorage();
    String? nowRunning = await storage.read(key: 'nowRunning');
    if (nowRunning != null) {
      _nowDetecting = nowRunning == '1' ? true : false;
    }
  }

  void startDetecting() async {
    _nowDetecting = true;
    notifyListeners();
    final storage = FlutterSecureStorage();
    await storage.write(key: 'nowRunning', value: '1');
  }

  void endDetecting() async {
    _nowDetecting = false;
    notifyListeners();
    final storage = FlutterSecureStorage();
    await storage.write(key: 'nowRunning', value: '0');
  }

  void availableDetect() {
    _detectAvailable = true;
    notifyListeners();
  }

  void disavailableDetect() {
    _detectAvailable = false;
    notifyListeners();
  }

}
