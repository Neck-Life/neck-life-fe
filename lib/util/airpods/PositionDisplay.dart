import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:mocksum_flutter/util/airpods/airpods_cal_movingAvg_ZUPT.dart';

// PositionDisplay AAAA = AirpodsCalMovingAvgZupt();로 생성
abstract class PositionDisplay{
  double getPosition(double limitValue);
  ///FlutterAirpods.getAirPodsDeviceMotionUpdates.listen의 콜백함수 내부에서 호출
  ///매개변수 data 넘겨주면 됨
  void processSensorData(DeviceMotionData data);
}