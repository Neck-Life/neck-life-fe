import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:mocksum_flutter/util/airpods/position/airpods_cal_movingAvg_ZUPT.dart';

/// Filter AAAA = AirpodsCalMovingAvgZupt();로 생성
/// 수평이동의 경우 구현체가 빈번하게 바뀔수 있움 -> strategy패턴 채택
/// strategy패턴의 interface컴포넌트
abstract class Filter{
  double getPosition(double limitValue);
  ///FlutterAirpods.getAirPodsDeviceMotionUpdates.listen의 콜백함수 내부에서 호출
  ///매개변수 data 넘겨주면 됨
  void processSensorData(DeviceMotionData data);
}


/// strategy패턴의 context컴포넌트
/// 외부에서는 PositionDisplay 클래스만 사용할 것
class PositionDisplay{
  AirpodsCalMovingAvgZupt filter = AirpodsCalMovingAvgZupt();
  ///현재 y축 위치 리턴
  ///limitValue : 최댓값 스케일링 계수
  double getPosition(double limitValue){
    return filter.getPosition(limitValue);
  }
  void processSensorData(DeviceMotionData data){
    filter.processSensorData(data);
  }

  // bool getMoved2Forward() {
  //   return filter.moved2Forward;
  // }
  //
  // bool getMoved2Backward() {
  //   return filter.moved2Backward;
  // }
}