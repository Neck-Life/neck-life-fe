
import 'package:flutter_airpods/models/device_motion_data.dart';


/// 외부에 노출될 각도관련 인터페이스
class RotationDisplay{
  double getPitch(DeviceMotionData data){
    return data.attitude.pitch.toDouble();
  }

/// 각도관련 메소드 구현 필수


}