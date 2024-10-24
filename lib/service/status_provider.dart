import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DetectStatus with ChangeNotifier {

  static String lanCode = 'ko';

  static bool sNowDetecting = false;
  static bool sDetectAvailable = false;
  static bool sIsNowTurtle = false;
  static int sSensitivity = 1;
  static int sAlarmGap = 5;

  static bool isLabMode = true;

  static double initialPitch = 0;
  static double nowPosition = 0;
  static double nowPitch = 0;
  static double nowRoll = 0;
  static double nowYaw = 0;
  static int moveDirection = 0;
  static int tickCount = 0;
  static bool sBgSoundActive = false;
  static bool hasWroteReview = false;
  static int reviewRequestCount = 5;

  bool _nowDetecting = false;
  bool _detectAvailable = false;
  bool _isNowTurtle = false;
  int _sensitivity = 1;
  int _alarmGap = 5;
  bool _bgSoungActive = false;

  bool get nowDetecting => _nowDetecting;
  bool get detectAvailable => _detectAvailable;
  bool get isNowTurtle => _isNowTurtle;
  int get sensitivity => _sensitivity;
  int get alarmGap => _alarmGap;
  bool get bgSoundActive => _bgSoungActive;

  static final _detectAvailableEventController = StreamController<dynamic>.broadcast();
  static Stream<dynamic> get detectAvailableEventStream => _detectAvailableEventController.stream;


  DetectStatus() {
    init();
  }

  Future<void> emitDetectableEvent(dynamic event) async {
    _detectAvailableEventController.add(event);
  }

  void init() async {
    // _nowDetecting = true;
    // _detectAvailable = true;
    const storage = FlutterSecureStorage();
    String? sensitivitySetting = await storage.read(key: 'sensitivity');
    String? alarmSetting = await storage.read(key: 'alarm');
    String? bgSoundSetting = await storage.read(key: 'isBgActive');
    String? rawHasWroteReview = await storage.read(key: 'hasWroteReview');
    if (sensitivitySetting != null) {
      _sensitivity = int.parse(sensitivitySetting);
      sSensitivity = _sensitivity;
    }
    if (alarmSetting != null) {
      _alarmGap = int.parse(alarmSetting);
      sAlarmGap = _alarmGap;
    }
    if (bgSoundSetting != null) {
      _bgSoungActive = bgSoundSetting == '1';
      sBgSoundActive = _bgSoungActive;
    }
    if (rawHasWroteReview != null) {
      hasWroteReview = rawHasWroteReview == '1' ? true : false;
      reviewRequestCount = 30;
    }
  }

  void startDetecting() async {
    _nowDetecting = true;
    sNowDetecting = true;
    notifyListeners();
    const storage = FlutterSecureStorage();
    await storage.write(key: 'nowRunning', value: '1');
  }

  Future<void> endDetecting() async {
    _nowDetecting = false;
    sNowDetecting = false;
    notifyListeners();
    const storage = FlutterSecureStorage();
    await storage.write(key: 'nowRunning', value: '0');
  }

  void availableDetect() {
    if (!_detectAvailable) emitDetectableEvent(true);
    _detectAvailable = true;
    sDetectAvailable = true;
    notifyListeners();
  }

  void setSensitivity(double sensitivityVal) async {
    _sensitivity = sensitivityVal.toInt();
    sSensitivity = _sensitivity;
    notifyListeners();
    const storage = FlutterSecureStorage();
    await storage.write(key: 'sensitivity', value: _sensitivity.toString());
  }

  void setAlarmGap(int alarmGapVal) async {
    _alarmGap = alarmGapVal;
    sAlarmGap = alarmGapVal;
    notifyListeners();
    const storage = FlutterSecureStorage();
    await storage.write(key: 'alarm', value: alarmGapVal.toString());
  }

  void setBgSoundActive(bool isActive) async {
    _bgSoungActive = isActive;
    sBgSoundActive = _bgSoungActive;
    notifyListeners();
    const storage = FlutterSecureStorage();
    await storage.write(key: 'isBgActive', value: isActive ? '1' : '0');
  }

  static void setHasWroteReview(bool hasWrote) async {
    print('haswrote $hasWrote');
    hasWroteReview = hasWrote;
    if (!hasWrote) {
      reviewRequestCount = 30;
    }
    const storage = FlutterSecureStorage();
    await storage.write(key: 'hasWroteReview', value: hasWrote ? '1' : '0');
  }

  void disavailableDetect() {
    if (_detectAvailable) emitDetectableEvent(false);
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
