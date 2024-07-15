import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DetectStatus with ChangeNotifier {

  static bool sNowDetecting = false;
  static bool sDetectAvailable = false;
  static bool sIsNowTurtle = false;
  static int sSensitivity = 1;
  static int sAlarmGap = 15;

  static double initialPitch = 0;
  static double nowPitch = 0;

  bool _nowDetecting = false;
  bool _detectAvailable = false;
  bool _isNowTurtle = false;
  int _sensitivity = 1;
  int _alarmGap = 15;

  bool get nowDetecting => _nowDetecting;
  bool get detectAvailable => _detectAvailable;
  bool get isNowTurtle => _isNowTurtle;
  int get sensitivity => _sensitivity;
  int get alarmGap => _alarmGap;

  DetectStatus() {
    init();
  }

  void init() async {
    // _nowDetecting = true;
    // _detectAvailable = true;
    final storage = FlutterSecureStorage();
    String? sensitivitySetting = await storage.read(key: 'sensitivity');
    String? alarmSetting = await storage.read(key: 'alarm');
    if (sensitivitySetting != null) {
      _sensitivity = int.parse(sensitivitySetting);
      sSensitivity = _sensitivity;
    }
    if (alarmSetting != null) {
      _alarmGap = int.parse(alarmSetting);
      sAlarmGap = _alarmGap;
    }
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

  void setSensitivity(double sensitivityVal) async {
    _sensitivity = sensitivityVal.toInt();
    sSensitivity = _sensitivity;
    notifyListeners();
    final storage = FlutterSecureStorage();
    await storage.write(key: 'sensitivity', value: _sensitivity.toString());
  }

  void setAlarmGap(int alarmGapVal) async {
    _alarmGap = alarmGapVal;
    sAlarmGap = alarmGapVal;
    notifyListeners();
    final storage = FlutterSecureStorage();
    await storage.write(key: 'alarm', value: alarmGapVal.toString());
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
