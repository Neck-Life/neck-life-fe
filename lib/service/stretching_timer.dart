import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../view/stretch/widgets/stretching_start_modal.dart';

class StretchingTimer {
  static final StretchingTimer _instance = StretchingTimer._internal();
  factory StretchingTimer() => _instance;
  StretchingTimer._internal();
  int stretchingInterval = 1800; // TODO : 추후에 옵션에서 바꿀수 있어야함
  Timer? _timer;

  void setTimer(BuildContext context) {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: stretchingInterval), () {
      showStretchingStartModal(context);
    });
  }
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}