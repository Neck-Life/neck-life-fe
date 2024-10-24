// stretch_alert_service.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'stretch_alert_provider.dart';

class StretchAlertService extends ChangeNotifier{
  final StretchAlertProvider _alertProvider;
  Timer? _timer;

  StretchAlertService(this._alertProvider);

  // 타이머를 시작하는 메서드
  void startStretchAlertTimer() {
    _alertProvider.startDetection();

    print("startStretchAlertTimer");
    // n분마다 알림 활성화
    _timer = Timer.periodic(Duration(seconds: 10), (_) { // 일단 5분마다 스트레칭
      _alertProvider.activateAlert();
    });
  }

  // 타이머를 중지하는 메서드
  void stopStretchAlertTimer() {
    _timer?.cancel();
    _alertProvider.stopDetection();
  }
}