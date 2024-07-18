import 'package:flutter_airpods/models/device_motion_data.dart';

abstract class PositionDisplay{
  double getPosition();

  /**
   * FlutterAirpods.getAirPodsDeviceMotionUpdates.listen의 콜백함수 내부에서 호출
   * 매개변수 data 넘겨주면 됨
   * */
  void processSensorData(DeviceMotionData data);
}