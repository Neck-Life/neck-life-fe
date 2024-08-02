
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:mocksum_flutter/util/airpods/rotation/RotationImplement.dart';


/// 외부에 노출될 각도관련 인터페이스
class RotationDisplay{
  RotationImplement rotate = RotationImplement();

  ///pitch값 얻기
  double getPitch(){
    return rotate.getPitch();

  }
  ///타이머 작동
  void process(DeviceMotionData data){
    rotate.process(data);
  }

  ///푸쉬알람 활성화 (콜백함수를 파라미터로 넘겨줘야함)
  void activePushAlarm(Future<void> Function() func){
    rotate.activePushAlarm(func);
  }

  ///거북목 각도 체크
  bool isTurtleNeck(){
    return rotate.isTurtleNeck();
  }
}