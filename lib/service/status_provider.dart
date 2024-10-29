import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../util/amplitude.dart';

class DetectStatus with ChangeNotifier {

  static String lanCode = 'ko';

  static bool sNowDetecting = false;
  static bool sDetectAvailable = false;
  static bool sIsNowTurtle = false;
  static int sSensitivity = 1;
  static int sAlarmGap = 5;
  static double sSoundVolume = 0.4;
  static bool sPushNotiAvtive = true;

  static bool isLabMode = true;

  static double initialPitch = 0;
  static double initialRoll = 0;
  static double initialYaw = 0;
  static double nowYaw = 0;
  static double nowPosition = 0;
  static double nowPitch = 0;
  static double nowRoll = 0;
  static int moveDirection = 0;
  static int tickCount = 0;
  static bool sBgSoundActive = true;
  static bool hasWroteReview = false;
  static int reviewRequestCount = 5;

  bool _nowDetecting = false;
  bool _detectAvailable = false;
  bool _isNowTurtle = false;
  int _sensitivity = 1;
  int _alarmGap = 5;

  bool _bgSoungActive = true;
  double _soundVolume = 0.4;
  bool _pushNotiAvtive = true;

  bool isBackward = false;

  bool get nowDetecting => _nowDetecting;
  bool get detectAvailable => _detectAvailable;
  bool get isNowTurtle => _isNowTurtle;
  int get sensitivity => _sensitivity;
  int get alarmGap => _alarmGap;
  bool get bgSoundActive => _bgSoungActive;
  double get soundVolume => _soundVolume;
  bool get pushNotiAvtive => _pushNotiAvtive;
  final AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();

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
    String? soundVolumeStr = await storage.read(key: 'soundVolume');
    String? pushNotiAcTiveStr = await storage.read(key: 'pushNotiActive');

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
    if (soundVolumeStr != null) {
      _soundVolume = double.parse(soundVolumeStr);
      sSoundVolume = _soundVolume;
    }
    if (pushNotiAcTiveStr != null) {
      _pushNotiAvtive = pushNotiAcTiveStr == '1' ? true : false;
      sSoundVolume = _soundVolume;
    }
  }

  void startDetecting() async {
    _nowDetecting = true;
    sNowDetecting = true;
    notifyListeners();
    log('noti-startDetecting');
    const storage = FlutterSecureStorage();
    await storage.write(key: 'nowRunning', value: '1');
  }

  Future<void> endDetecting() async {
    _nowDetecting = false;
    sNowDetecting = false;
    notifyListeners();
    log('noti-endDetecting');

    const storage = FlutterSecureStorage();
    await storage.write(key: 'nowRunning', value: '0');
  }

  void availableDetect() {
    bool prevVal = _detectAvailable;
    if (!_detectAvailable) emitDetectableEvent(true);
    _detectAvailable = true;
    sDetectAvailable = true;
    if (prevVal != true) {
      notifyListeners();
      _amplitudeEventManager.actionEvent('mainpage', 'connectairpods');
    }
    // log('noti-availableDetect');

  }

  void setSensitivity(double sensitivityVal) async {
    _sensitivity = sensitivityVal.toInt();
    sSensitivity = _sensitivity;
    notifyListeners();
    const storage = FlutterSecureStorage();
    await storage.write(key: 'sensitivity', value: _sensitivity.toString());
  }

  void setSoundVolume(double volume) async {
    _soundVolume = volume;
    sSoundVolume = volume;
    notifyListeners();
    const storage = FlutterSecureStorage();
    await storage.write(key: 'soundVolume', value: _soundVolume.toString());
  }

  void setPushNotiActive(bool value) async {
    _pushNotiAvtive = value;
    sPushNotiAvtive = value;
    notifyListeners();
    const storage = FlutterSecureStorage();
    await storage.write(key: 'pushNotiActive', value: value ? "1" : "0");
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
