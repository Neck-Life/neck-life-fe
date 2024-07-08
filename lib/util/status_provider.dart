import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DetectStatus with ChangeNotifier {

  static bool sNowDetecting = false;
  static bool sDetectAvailable = false;
  static bool sIsNowTurtle = false;
  bool _nowDetecting = false;
  bool _detectAvailable = false;
  bool _isNowTurtle = false;

  bool get nowDetecting => _nowDetecting;
  bool get detectAvailable => _detectAvailable;
  bool get isNowTurtle => _isNowTurtle;

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
    // _nowDetecting = true;
    // _detectAvailable = true;
    // final storage = FlutterSecureStorage();
    // String? nowRunning = await storage.read(key: 'nowRunning');
    // String? first = await storage.read(key: 'first');
    // if (nowRunning != null) {
    //   _nowDetecting = nowRunning == '1' ? true : false;
    //   sNowDetecting = _nowDetecting;
    // }
  }

  void startDetecting() async {
    _nowDetecting = true;
    sNowDetecting = true;
    notifyListeners();
    final storage = FlutterSecureStorage();
    await storage.write(key: 'nowRunning', value: '1');
  }

  void endDetecting() async {
    _nowDetecting = false;
    sNowDetecting = false;
    notifyListeners();
    final storage = FlutterSecureStorage();
    await storage.write(key: 'nowRunning', value: '0');
  }

  void availableDetect() {
    _detectAvailable = true;
    sDetectAvailable = true;
    notifyListeners();
  }

  void disavailableDetect() {
    _detectAvailable = false;
    sDetectAvailable = true;
    notifyListeners();
  }

  void toTurtle() {
    _isNowTurtle = true;
    notifyListeners();
  }

  void toNotTurtle() {
    _isNowTurtle = false;
    notifyListeners();
  }

}
