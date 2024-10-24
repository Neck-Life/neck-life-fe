import 'package:flutter/material.dart';

class StretchAlertProvider with ChangeNotifier {
  bool _isDetecting = false;
  bool _isAlertActive = false;

  bool get isDetecting => _isDetecting;
  bool get isAlertActive => _isAlertActive;

  void startDetection() {
    _isDetecting = true;
    notifyListeners();
  }

  void stopDetection() {
    _isDetecting = false;
    _isAlertActive = false;
    notifyListeners();
  }

  void activateAlert() {
    _isAlertActive = true;
    print("activateAlert");
    notifyListeners();
  }

  void deactivateAlert() {
    _isAlertActive = false;
    notifyListeners();
  }
}