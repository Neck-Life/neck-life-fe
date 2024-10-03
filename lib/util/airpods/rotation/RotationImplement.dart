import 'package:flutter_airpods/models/device_motion_data.dart';

import '../../../service/status_provider.dart';

class RotationImplement{
  double _rotateDeg = 0;
  double _pitch = 0;
  double _prevPitch = 0;
  int _sameValueCnt = 0;
  bool _detectAvailable = false;
  int _minAlarmDelay = 0;
  int _stateTurtleNeck = 0;
  final List<double> _turtleThreshold = [0.3, 0.4, 0.5];
  List<double> positions = [0.0];

  double getPitch(){
    return _pitch;
  }
  bool isTurtleNeck() {
    if (DetectStatus.initialPitch - _pitch > _turtleThreshold[DetectStatus.sSensitivity]) {
      return true;
    } else {
      return false;
    }
  }
  //
  void process(DeviceMotionData data){
    _pitch = data.toJson()['pitch'];
    // print(_pitchTemp);
    DetectStatus.nowPitch = _pitch;
    if (_minAlarmDelay > 0) {
      _minAlarmDelay -= 1;
    }
    if (isTurtleNeck() && _stateTurtleNeck == 0 && DetectStatus.sNowDetecting) {
      _stateTurtleNeck = DateTime.now().millisecondsSinceEpoch;
    }
    if (!isTurtleNeck()) {
      _stateTurtleNeck = 0;
    }
  }

  void setMinAlarmDelay(int value){
    _minAlarmDelay = value;
  }

  void activePushAlarm(Future<void> Function() showPushAlarm) {
    if (DetectStatus.sNowDetecting
        && isTurtleNeck()
        && _minAlarmDelay == 0
        && DateTime.now().millisecondsSinceEpoch - _stateTurtleNeck >= DetectStatus.sAlarmGap * 1000) {
      showPushAlarm();
      _minAlarmDelay = 600;
      _stateTurtleNeck = 0;
    }
   {

  }}

}