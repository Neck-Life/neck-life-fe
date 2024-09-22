import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mocksum_flutter/util/airpods/PositionDisplay.dart';
import 'package:mocksum_flutter/util/status_provider.dart';

///측정로직 클래스
class AirpodsCalMovingAvgZupt extends Filter{
  double lastTimestamp = 0.0;
  List<double> accelometers = [0.0];
  List<double> velocities = [0.0];
  List<double> positions = [0.0];
  List<double> pastY = [0.0]; //가속도Y 히스토리
  // List<double> pastZ = [0.0]; //가속도Z 히스토리
  static const double threshold = 0.015; //변위 최댓값 설정
  bool isRotated = false;
  double last_zero_position = 0.0;
  double last_zero_velocity = 0.0;
  static double last_pitch = 0.0;
  static double last_roll = 0.0;
  static double last_yaw = 0.0;
  List<double> stablePositions = [0.0];
  bool stopFlag = false;
  double stablePosition = 0.0;


  /// position값을 [0,limitValue]범위로 리턴, 비워두면 기존값그대로 리턴
  @override
  double getPosition([double limitValue=threshold]){
    return stablePosition * (limitValue / threshold);
  }

  /// <- processSensorData : 측정 1틱 진입점
  ///compensatePosition : 비정상 속도히스토리,위치 보상 알고리즘
  /// <- applyZUPT : 영속도 보정 알고리즘
  @override
  void processSensorData(DeviceMotionData data) {
    double currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    double deltaTime = positions.length==1 ? 0 : currentTime - lastTimestamp;
    lastTimestamp = currentTime;

    if(!DetectStatus.isLabMode){
      return;
    }

    double currentAccelY = data.userAcceleration.y.toDouble();
    double currentAccelZ = data.userAcceleration.z.toDouble();
    pastY.add(currentAccelY);
    // pastZ.add(currentAccelZ);
    int len = 6;
    if(pastY.length > len) pastY.removeAt(0);
    // if(pastZ.length > len) pastZ.removeAt(0);

    double cal_acc_y = 0.0;
    double cal_acc_z = 0.0;
    List<double> sortedY = List.from(pastY);
    // List<double> sortedZ = List.from(pastZ);
    sortedY.sort();
    // sortedZ.sort();

    //절사평균 : 추가 조정 필수
    for(int i = 1; i < sortedY.length-1;i++){
      cal_acc_y += sortedY[i];
      // cal_acc_z += sortedZ[i];
    }
    cal_acc_y /= len-2;
    // cal_acc_z /= len-2;

    //가속도의 편차 줄이기
    // double cal_acc = -cal_acc_y + cal_acc_z; //y,z축 둘다 고려하기
    double cal_acc = -cal_acc_y; //y축만 고려하기
    double offset = 0.01;
    if(cal_acc.abs() < offset) cal_acc = 0;



    double velocity = velocities.last + cal_acc * deltaTime;
    double position = positions.last + velocity * deltaTime;

    if(velocities.last * velocity < 0) stopFlag = true;

    //         임시 움직임 없애기 시작


    // 회전 하고 정지 , 처음 아님
    if (isRotated  && stopFlag && position != last_zero_position) {

      // 현재 속도와 위치를 체크포인트 값으로 복구
      velocity = last_zero_velocity;
      position = last_zero_position;
      isRotated = false;  // 롤백 완료 후 회전 상태 해제
      stablePosition = position;
      print("회전제거");
    }

    // 가속도가 0이고 속도도 0일 때 체크포인트 설정
    else if (!isRotated && stopFlag && velocity == 0) {
      // print(2);
      if (position != last_zero_position && last_zero_position != 0) {
        last_zero_velocity = velocity;
        last_zero_position = position;
      }


    } else if (hasRotated(data.attitude.pitch.toDouble(), data.attitude.roll.toDouble(), data.attitude.yaw.toDouble())) {
      isRotated = true;

    }
    //         임시 움직임 없애기 끝

    //ZUPT : 영속도 업데이트
    [velocity, position] = applyZUPT(velocity, position);


    if(!stopFlag) stablePosition = position;
    if(stablePosition > threshold) stablePosition = threshold;
    else if(stablePosition < -threshold/3) stablePosition = -threshold/3;
    stablePositions.add(stablePosition);

    // print("position : ${stablePosition}");
    // print("veloticy : ${velocity}");



    //화면상에서 100개 정보만 출력
    accelometers.add(cal_acc);
    velocities.add(velocity);
    positions.add(position);
    if(accelometers.length > 20) accelometers.removeAt(0);
    if(velocities.length > 100) velocities.removeAt(0);
    if(positions.length > 100) positions.removeAt(0);
    if(stablePositions.length > 100) stablePositions.removeAt(0);

    last_pitch = data.attitude.pitch.toDouble();
    last_roll = data.attitude.roll.toDouble();
    last_yaw = data.attitude.yaw.toDouble();


  }

  //[velocity, postion] => [개선된 velocity, position] 제공
  List<double> applyZUPT(double velocity, double position){
    double deviation = 0.0;
    int windowSIZE = 10;
    if(accelometers.length < windowSIZE) return [velocity, position];

    for(int i=accelometers.length - windowSIZE;i<accelometers.length;i++){
      deviation += accelometers[i].abs();
    }
    deviation /= windowSIZE;
    // print(deviation);
    //편차 임계치 설정 추가 로직 필요 : 시간에 따라 가속도raw 측정값 자체의 오차가 커지는 현상 발견
    if(deviation > 0.0015) return [velocity, position];
    //위치 보상 알고리즘
    //속도가 비정상으로 뒤집힌 구간만큼 롤백


    position = compensatePosition(velocity, position);
    velocity = 0;
    stopFlag = false;
    stablePosition = position;
    return [velocity, position];

  }

  ///위치 보상 알고리즘
  ///속도가 비정상으로 뒤집힌 구간만큼 롤백
  double compensatePosition(double velocity, double position){

    bool compensationFlag = false;
    int idx = velocities.length -1;

    while(idx>=0 && velocity * velocities[idx] > 0){
      idx--;
    }
    while(idx>=0 && velocity * velocities[idx] < 0) {
      if(velocities[idx].abs() > 0.001){
        compensationFlag = true;
        break;
      }
      idx--;
    }
    if(compensationFlag){
      idx = velocities.length - 1;
      while(idx>=0 && velocity * velocities[idx] > 0){
        velocities[idx] = 0;
        idx--;
      }
      position = positions[idx];
      print("거리보상 보상 알고리즘 발동!");
    }

    if(position > threshold) position = threshold;
    else if(position < -threshold/3) position = -threshold/3;



    ///위치 오차 보정 : 과도하게 커지거나 작아지면, limit값으로 강제 변경
    return position;
  }

}

bool hasRotated(double currentPitch, double currentRoll, double currentYaw) {
  // 변화량 계산
  double deltaPitch = (currentPitch - AirpodsCalMovingAvgZupt.last_pitch).abs();
  double deltaRoll = (currentRoll - AirpodsCalMovingAvgZupt.last_roll).abs();
  double deltaYaw = (currentYaw - AirpodsCalMovingAvgZupt.last_yaw).abs();

  // print("deltaPitch : $deltaPitch");
  // print("deltaRoll : $deltaRoll");
  // print("deltaYaw : $deltaYaw");



  // 회전 여부 판단
  bool rotated = deltaPitch > 0.1 || deltaYaw > 0.08;

  // 이전 값을 현재 값으로 업데이트


  return rotated;
}

