import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_airpods/models/gravity.dart';
import 'package:flutter_airpods/models/user_acceleration.dart';
import 'package:mocksum_flutter/mac/flutter_airpods_mac.dart';
import 'package:mocksum_flutter/util/airpods/PositionDisplay.dart';


///측정로직 클래스
class AirpodsCalMovingAvgZupt extends Filter{
  double lastTimestamp = 0.0;
  List<double> rawY = [0.0];
  List<double> rawZ = [0.0,0.0];
  double acc_offset = 0.0;

  List<double> pitches = [0.0];
  List<double> rolls = [0.0];
  List<double> yaws = [0.0];
  List<double> degrees = [0.0];


  List<double> accelometersNotSmooth = [0.0];
  List<double> accelometers = [0.0];
  List<double> finalAccelometers = [0.0];

  List<double> velocities = [0.0];
  List<double> NotZUPTvelocities = [0.0];


  List<double> beforepositions = [0.0];
  List<double> positions = [0.0];
  double stablePosition = 0.0;
  List<double> stablePositions = [0.0];
  List<bool> isZUPT = [false];
  List<double> pastY = [0.0]; //가속도Y 히스토리
  List<double> pastZ = [0.0]; //가속도Z 히스토리
  static const double threshold = 0.015; //변위 최댓값 설정
  bool isMoving = false;
  bool stopFlag = false;
  int isReady =0;
  double cutoffFrequency = 5.0; // 컷오프 주파수 (Hz)
  double sampleRate = 25.0; // 샘플링 레이트 (Hz)

  List<double> deltaTimes = [0.0];

  List<double> positions2 = [0.0];
  double last_zero_velocity = 0.0;
  double last_zero_positon = 0.0;
  bool isRotated = false;
  bool shouldIgnoreData = false;

  List<double> Zvelocities = [0.0];
  List<double> ZPositions = [0.0];

  double currentTime = 0.0;
  String state = "앉은 상태"; // 상태를 저장할 변수

  double offset = 0.006;



  /// position값을 [0,limitValue]범위로 리턴, 비워두면 기존값그대로 리턴
  @override
  double getPosition([double limitValue=threshold]){
    // print(stablePosition * (limitValue / threshold));
    return stablePosition * (limitValue / threshold);
    // return positions.last * (limitValue / threshold);
    return beforepositions.last * (limitValue / threshold);
  }

  /// <- processSensorData : 측정 1틱 진입점
  ///compensatePosition : 비정상 속도히스토리,위치 보상 알고리즘
  /// <- applyZUPT : 영속도 보정 알고리즘
  @override
  void processSensorData(DeviceMotionData data) {



    currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    double deltaTime = positions.length==1 ? 0 : currentTime - lastTimestamp;
    lastTimestamp = currentTime;

    double currentAccelY = data.userAcceleration.y.toDouble();
    double currentAccelZ = data.userAcceleration.z.toDouble();
    double currentAccelX = data.userAcceleration.x.toDouble();

    deltaTimes.add(deltaTime);

    //
    // // Z축
    // if(currentAccelZ.abs() < 0.01) currentAccelZ = 0.0;
    //
    // double afterZVelocity =  Zvelocities.last + currentAccelZ * deltaTime;
    // double afterZPosition = ZPositions.last + afterZVelocity * deltaTime;
    //
    //
    // [afterZVelocity,afterZPosition] = compensatePositionOnZ(afterZVelocity,afterZPosition);
    //





    //
    // Zvelocities.add( afterZVelocity);
    // ZPositions.add(afterZPosition);
    // rawY.add(currentAccelY);


    if(rawY.length > 500) {
      isReady++;
      rawY.removeAt(0);

    }
    if(isReady==1){
      velocities.last = 0;
      positions.last = 0;
      isReady=2;
    }
    acc_offset = 0;
    for(int i=0;i<rawY.length;i++){
      acc_offset += rawY[i];
    }
    acc_offset /= rawY.length;
    double accSum=0;
    for(int i=0;i<accelometers.length;i++){
      accSum += accelometers[i];
    }
    accSum /= accelometers.length;
    // print(["calibration 가속도 평균값:", accSum]);
    pastY.add(currentAccelY);
    pastZ.add(currentAccelZ);
    int len = 5;
    if(pastY.length > len) pastY.removeAt(0);
    if(pastZ.length > len) pastZ.removeAt(0);

    double cal_acc_y = 0.0;
    // double cal_acc_z = 0.0;

    //이동 평균 필터
    for(int i = 0; i < pastY.length;i++){
      // cal_acc_y += i*sortedY[i];
      cal_acc_y += pastY[i];
      // cal_acc_z += sortedZ[i];
    }
    // print(["raw가속도 평균값:", acc_offset]);
    // cal_acc_y /= (len-1)*len/2;
    cal_acc_y /= len;
    // cal_acc_y = (cal_acc_y + sortedY.last) / 2;
    // cal_acc_y -= acc_offset;
    // cal_acc_z /= len-2;
    accelometersNotSmooth.add(currentAccelY - acc_offset);

    // print(tmp);
    //가속도의 편차 줄이기
    // double cal_acc = -cal_acc_y + cal_acc_z; //y,z축 둘다 고려하기
    double cal_acc = cal_acc_y; //y축만 고려하기
    // cal_acc = hpfacc.process(cal_acc);






    // if(cal_acc.abs() < offset){
    //   if(finalAccelometers.last.abs()<=0.0000000001){
    //     cal_acc = 0.000000;
    //   }else if (finalAccelometers.last.abs()<=0.000000001)
    //     cal_acc = 0.0000000001;
    //   else if (finalAccelometers.last.abs()<=0.00001)
    //     cal_acc = 0.000000001;
    //   // else if (finalAccelometers.last.abs()<=0.0000001)
    //   //   cal_acc = 0.00000001;
    //   // else if (finalAccelometers.last.abs()<=0.000001)
    //   //   cal_acc = 0.0000001;
    //   // else if (finalAccelometers.last.abs()<=0.00001)
    //   //   cal_acc = 0.000001;
    //   else
    //     cal_acc = 0.00001;
    //
    // }

    if(cal_acc.abs() < offset) {
      cal_acc = 0;
    }


    print("cal_acc : ${cal_acc}");

    if(cal_acc.abs() > 0.3) {
      offset = 0.02;
      Timer(Duration(seconds: 3), () {
        offset = 0.006;
      });
    }



    accelometers.add(cal_acc);

    // if(cal_acc.abs() < 0.05){
    //   // if(cal_acc.abs() < 0){
    //   //   cal_acc = 0;
    //   // }
    //
    //   cal_acc *= 1.5;
    // }

    if(cal_acc<0){
      cal_acc = cal_acc*1.2;
    }




    double velocity = velocities.last + cal_acc * deltaTime;

    if(velocity < 0){
      velocity = velocity * 1.2;
      }

    if(velocity>0.015){
      velocity = 0.015;
    }else if(velocity<-0.015){
      velocity = -0.018;
    }

    // print("수정 전 ${velocity}");

    double NotZUPTvelocity = NotZUPTvelocities.last + cal_acc * deltaTime;


    double deviation = 0.0;
    int windowSIZE = 8;
    int zeroCount= 0;
    if(finalAccelometers.length < windowSIZE){


    }else {
      for (int i = finalAccelometers.length - windowSIZE+1; i <
          finalAccelometers.length; i++) {
        deviation += finalAccelometers[i].abs();
        if (finalAccelometers[i] == 0) {
          zeroCount++;
        }
      }

      // print(deviatio n);
      //편차 임계치 설정 추가 로직 필요 : 시간에 따라 가속도raw 측정값 자체의 오차가 커지는 현상 발견

        if (zeroCount > 1) {


          velocity = 0;
      }



    }


    double temp;


    if(velocity.abs() < 0.0002){
      velocity = velocity *20;
      print("1");
    }else if(velocity.abs() < 0.0008){
      velocity = velocity *16;
      print("2");
    }else if(velocity.abs() < 0.0012){
      velocity = velocity *14;
      print("3");
    }else if(velocity.abs() < 0.002){
      velocity = velocity *10;
      print("4");
    }else if(velocity.abs() < 0.006){
      velocity = velocity *2;
      print("5");
    }



      temp = velocity * deltaTime;


    // double temp = velocity * deltaTime;

    double position = positions.last + temp;
    double beforeposition = beforepositions.last + velocity * deltaTime;
    // position = hpfpos.process(position);
    // position = mafp.process(position);
    //ZUPT : 영속도 업데이트
    isZUPT.add(false);
    if(velocities.last * velocity < 0) stopFlag = true
    ;
    // NotZUPTvelocities.add(NotZUPTvelocity);
    // [velocity, position] = applyZUPT(velocity, position);



    List<double> sublist = [];
    if (accelometers.length > 10) {
      sublist = accelometers.sublist(accelometers.length - 3, accelometers.length);
    }



    // 회전 하고 정지 , 처음 아님
    if (isRotated  &&  sublist.isNotEmpty && sublist.reduce((a, b) => a + b) == 0 && position != last_zero_positon) {
      // print(1);

      int inx = positions.length - 1;

      // 롤백 조건 확인
      // print("체크포인트: ${positions[inx]}, 마지막 체크포인트: $last_zero_positon");

      // 현재 위치가 체크포인트와 같아질 때까지 롤백
      while (inx >= 0) {
        if (positions[inx] == last_zero_positon) {
          // print("롤백 완료: $inx 번째 위치가 체크포인트와 일치함.");
          break;  // 위치가 체크포인트와 같으면 롤백 중단
        }
        positions[inx] = last_zero_positon;  // 위치 롤백
        velocities[inx] = 0;  // 속도 롤백
        // print("롤백 중: $inx 위치가 $last_zero_positon 으로 설정됨.");
        inx--;
      }

      // 현재 속도와 위치를 체크포인트 값으로 복구
      velocity = last_zero_velocity;
      position = last_zero_positon;
      isRotated = false;  // 롤백 완료 후 회전 상태 해제
      }

      // 가속도가 0이고 속도도 0일 때 체크포인트 설정
     if (!isRotated  && sublist.isNotEmpty && sublist.reduce((a, b) => a + b) == 0 && velocity == 0) {
      // print(2);

        last_zero_velocity = velocity;
        last_zero_positon = position;



    }

     if (hasRotated(data.attitude.pitch.toDouble(), data.attitude.roll.toDouble(), data.attitude.yaw.toDouble())) {
      isRotated = true;
      print("회전 발생");
    }else{
// ZUPT 적용

       [velocity, position] = applyZUPT(velocity, position);
}


    if(position > threshold) position = threshold;
    else if(position < 0) position = 0.0;



    //화면상에서 100개 정보만 출력
    finalAccelometers.add(cal_acc);
    // accelometers.add(cal_acc);
    // velocities.add(velocity);

    // print("수정 후 ${velocity}");
    velocities.add(velocity);

    positions.add(position);
    positions2.add(position);
    beforepositions.add(beforeposition);
    // accelometers.add(data.attitude.pitch.toDouble());
    // velocities.add(data.attitude.roll.toDouble());
    // positions.add(data.attitude.yaw.toDouble());

    // if(velocities.last )stablePosition = position;

    if(!stopFlag) stablePosition = position;
    if(stablePosition > threshold) stablePosition = threshold;
    else if(stablePosition < -0.005) stablePosition = -0.005;
    stablePositions.add(stablePosition);



    //pitch, roll, yaw 각도 정보
    pitches.add(data.attitude.pitch.toDouble());
    rolls.add(data.attitude.roll.toDouble());
    yaws.add(data.attitude.yaw.toDouble());
    if(pitches.length > 100) pitches.removeAt(0);
    if(rolls.length > 100) rolls.removeAt(0);
    if(yaws.length > 100) yaws.removeAt(0);
    if(deltaTimes.length>100) deltaTimes.removeAt(0);


    if(accelometersNotSmooth.length > 100) accelometersNotSmooth.removeAt(0);
    if(finalAccelometers.length > 100) finalAccelometers.removeAt(0);
    if(accelometers.length > 100) accelometers.removeAt(0);
    if(velocities.length > 100) velocities.removeAt(0);
    if(NotZUPTvelocities.length > 100) NotZUPTvelocities.removeAt(0);
    if(beforepositions.length > 100) beforepositions.removeAt(0);
    if(positions.length > 100) positions.removeAt(0);
    if(stablePositions.length > 100) stablePositions.removeAt(0);
    if(positions2.length > 100) positions2.removeAt(0);

    rawZ.add(currentAccelZ);
    if(rawZ.length > 100) rawZ.removeAt(0);
    if(Zvelocities.length > 100) Zvelocities.removeAt(0);

  }


  bool hasRotated(double currentPitch, double currentRoll, double currentYaw) {
    // 변화량 계산
    double deltaPitch = (currentPitch - pitches.last).abs();
    double deltaRoll = (currentRoll - rolls.last).abs();
    double deltaYaw = (currentYaw - yaws.last).abs();

    // print("deltaPitch : $deltaPitch");
    // print("deltaRoll : $deltaRoll");
    // print("deltaYaw : $deltaYaw");



    // 회전 여부 판단
    bool rotated =   deltaRoll > 0.1|| deltaYaw > 0.08;

    // 이전 값을 현재 값으로 업데이트


    return rotated;
  }






  //[velocity, postion] => [개선된 velocity, position] 제공
  List<double> applyZUPT(double velocity, double position){
    double deviation = 0.0;
    double deviation2 = 0.0;
    int windowSIZE = 10;
    int zeroCount= 0;
    if(finalAccelometers.length < windowSIZE) return [velocity, position];

    for(int i=finalAccelometers.length - windowSIZE;i<finalAccelometers.length;i++){
      deviation += finalAccelometers[i];
      deviation2 += finalAccelometers[i].abs();
      if(finalAccelometers[i] == 0){
        zeroCount++;
      }
    }
    deviation /= windowSIZE;


    //편차 임계치 설정 추가 로직 필요 : 시간에 따라 가속도raw 측정값 자체의 오차가 커지는 현상 발견
    if(deviation.abs() > 0.01){
      // print(deviation);
      // 처음으로 0이 아닌게 나온 시점에는 오차가 존재해서 무시할 필요가 있음
      if(zeroCount>1){
        // velocity = 0;
        position = positions.last;
      }


      return [velocity, position];
    }
    //위치 보상 알고리즘
    //속도가 비정상으로 뒤집힌 구간만큼 롤백
    // position = compensatePosition(velocity, position);




    // if(deviation2 < 0.0008){
    //   print(velocity);
    //   velocity = 0;
    //   // position = positions.last;
    // }

    // print("ZUPT 적용 전 ${velocity}");
    velocity = 0;
    // position = positions.last;
    isZUPT.last = true;
    stopFlag = false;
    stablePosition = position;
    return [velocity, position];
  }

  ///위치 보상 알고리즘
  ///속도가 비정상으로 뒤집힌 구간만큼 롤백
  double compensatePosition(double velocity, double position){

    bool compensationFlag = false;
    int idx = velocities.length -1;






    idx = velocities.length -1;
    while(idx>=0){
      if(velocity * velocities[idx] > 0){
        idx--;
      }else{
        break;
      }

    }

    while(idx>=0 && velocity * velocities[idx] < 0) {
      compensationFlag = true;
      break;
      if(velocities[idx].abs() > 0.00001){
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

    ///위치 오차 보정 : 과도하게 커지거나 작아지면, limit값으로 강제 변경
    if(position > threshold) position = threshold;
    else if(position < 0) position = 0.0;

    if(position == threshold){
      // print("중단");
    }
    return position;
  }

}





/**
 * 테스트 환경 진입점
 * */
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AirpodsExampleApp(),
    );
  }
}

class AirpodsExampleApp extends StatefulWidget {
  @override
  _AirpodsExampleAppState createState() => _AirpodsExampleAppState();
}

class _AirpodsExampleAppState extends State<AirpodsExampleApp> {
  StreamSubscription<DeviceMotionData>? _subscription;
  bool _isListening = false;
  List<double> accelometers  = [0.0];
  List<double> velocities = [0.0];
  List<double> ZUPTvelocities = [0.0];

  List<double> beforepositions = [0.0];
  List<double> positions = [0.0];
  List<double> stablePositions = [0.0];
  List<double> rawY = [0.0];
  List<double> Zvelocity = [0.0];
  List<double> accelometersNotSmooth = [0.0];
  List<double> finalAccelometers = [0.0];

  List<double> pitches = [0.0];
  List<double> rolls = [0.0];
  List<double> yaws = [0.0];

  List<double> ZPositons = [0.0];

  @override
  void initState() {
    super.initState();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      Filter positionDisplay = AirpodsCalMovingAvgZupt();
      AirpodsCalMovingAvgZupt positionDisplayTest = positionDisplay as AirpodsCalMovingAvgZupt; //내부 테스트 용

      accelometersNotSmooth = positionDisplayTest.accelometersNotSmooth;
      accelometers = positionDisplayTest.accelometers;
      finalAccelometers = positionDisplayTest.finalAccelometers;

      velocities = positionDisplayTest.NotZUPTvelocities;
      ZUPTvelocities = positionDisplayTest.velocities;

      beforepositions = positionDisplayTest.beforepositions;
      positions = positionDisplayTest.positions;
      rawY = positionDisplayTest.rawY;
      stablePositions = positionDisplayTest.stablePositions;

      pitches = positionDisplayTest.pitches;
      rolls = positionDisplayTest.rolls;
      yaws = positionDisplayTest.yaws;

      Zvelocity = positionDisplayTest.Zvelocities;

      ZPositons = positionDisplayTest.ZPositions;

      _subscription = FlutterAirpodsMac.getAirPodsDeviceMotionUpdates.listen((data) {
        // print(positionDisplay.getPosition(100)); // 최대값100으로 scaling하여 위치 출력
        positionDisplay.processSensorData(data);
        setState(() {
        });
      }, onError: (error) {
        print('Error: $error');
      });

    });
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _subscription?.cancel();
      _subscription = null;
    });
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Position Detection'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Expanded(
          //   child: Column(
          //     children: [
          //       Expanded(
          //         child: LineChart(
          //           LineChartData(
          //             borderData: FlBorderData(show: false),
          //             minY: -0.2,
          //             maxY: 0.2,
          //             lineBarsData: [
          //               LineChartBarData(
          //                 spots: rawY.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          //                 isCurved: true,
          //                 color: Colors.blue,
          //               ),
          //             ],
          //             titlesData: FlTitlesData(
          //               bottomTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 레이블 숨기기
          //               ),
          //               topTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 상단 타이틀 숨기기
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       const Text('Raw Acceleration Data'),
          //     ],
          //   ),
          // ),
          // Expanded(
          //   child: Column(
          //     children: [
          //       Expanded(
          //         child: LineChart(
          //           LineChartData(
          //             borderData: FlBorderData(show: false),
          //             minY: -1.1,
          //             maxY: 1.1,
          //             lineBarsData: [
          //               LineChartBarData(
          //                 spots: accelometersNotSmooth.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          //                 isCurved: true,
          //                 color: Colors.blue,
          //               ),
          //             ],
          //             titlesData: FlTitlesData(
          //               bottomTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 레이블 숨기기
          //               ),
          //               topTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 상단 타이틀 숨기기
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       const Text('Acceleration Data'),
          //     ],
          //   ),
          // ),
          //
          // Expanded(
          //   child: Column(
          //     children: [
          //       Expanded(
          //         child: LineChart(
          //           LineChartData(
          //             borderData: FlBorderData(show: false),
          //             minY: -1.01,
          //             maxY: 1.01,
          //             lineBarsData: [
          //               LineChartBarData(
          //                 spots: accelometers.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          //                 isCurved: true,
          //                 color: Colors.blue,
          //               ),
          //             ],
          //             titlesData: FlTitlesData(
          //               bottomTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 레이블 숨기기
          //               ),
          //               topTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 상단 타이틀 숨기기
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       const Text('acceleration movingAvgFilter Data'),
          //     ],
          //   ),
          // ),
          //
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: false),
                      minY: -0.4,
                      maxY: 0.4,
                      lineBarsData: [
                        LineChartBarData(
                          spots: finalAccelometers.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                          isCurved: true,
                          color: Colors.blue,
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // X축 레이블 숨기기
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // X축 상단 타이틀 숨기기
                        ),
                      ),
                    ),
                  ),
                ),
                const Text('filtered acceleration'),
              ],
            ),
          ),




          // Expanded(
          //   child: Column(
          //     children: [
          //       Expanded(
          //         child: LineChart(
          //           LineChartData(
          //             borderData: FlBorderData(show: false),
          //             minY: -0.02,
          //             maxY: 0.02,
          //             lineBarsData: [
          //               LineChartBarData(
          //                 spots: velocities.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          //                 isCurved: true,
          //                 color: Colors.blue,
          //               ),
          //             ],
          //             titlesData: FlTitlesData(
          //               bottomTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 레이블 숨기기
          //               ),
          //               topTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 상단 타이틀 숨기기
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       const Text('Velocity Data'),
          //     ],
          //   ),
          // ),
          //
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: false),
                      minY: -0.02,
                      maxY: 0.02,
                      lineBarsData: [
                        LineChartBarData(
                          spots: ZUPTvelocities.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                          isCurved: true,
                          color: Colors.blue,
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // X축 레이블 숨기기
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // X축 상단 타이틀 숨기기
                        ),
                      ),
                    ),
                  ),
                ),
                const Text('ZUPT Velocity Data'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: false),
                      minY: -0.005 * 1000,
                      maxY: 0.020 * 1000,
                      lineBarsData: [
                        LineChartBarData(
                          spots: positions.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value * 1000)).toList(),
                          isCurved: true,
                          color: Colors.blue,
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // X축 레이블 숨기기
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // X축 상단 타이틀 숨기기
                        ),
                      ),
                    ),
                  ),
                ),
                const Text('Position Data'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: false),
                      minY: -0.005 * 1000,
                      maxY: 0.020 * 1000,
                      lineBarsData: [
                        LineChartBarData(
                          spots: stablePositions.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value * 1000)).toList(),
                          isCurved: true,
                          color: Colors.blue,
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // X축 레이블 숨기기
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // X축 상단 타이틀 숨기기
                        ),
                      ),
                    ),
                  ),
                ),
                const Text('stable Position Data'),
              ],
            ),
          ),

          // Expanded(
          //   child: Column(
          //     children: [
          //       Expanded(
          //         child: LineChart(
          //           LineChartData(
          //             borderData: FlBorderData(show: false),
          //             minY: 0.000,
          //             maxY: 0.015,
          //             lineBarsData: [
          //               LineChartBarData(
          //                 spots: stablePositions.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          //                 isCurved: true,
          //                 color: Colors.blue,
          //               ),
          //             ],
          //             titlesData: FlTitlesData(
          //               bottomTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 레이블 숨기기
          //               ),
          //               topTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 상단 타이틀 숨기기
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       const Text('Stable Position Data'),
          //     ],
          //   ),
          // ),
          // Expanded(
          //   child: Column(
          //     children: [
          //       Expanded(
          //         child: LineChart(
          //           LineChartData(
          //             borderData: FlBorderData(show: false),
          //             minY: -0.2,
          //             maxY: 0.2,
          //             lineBarsData: [
          //               LineChartBarData(
          //                 spots: Zvelocity.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          //                 isCurved: true,
          //                 color: Colors.blue,
          //               ),
          //             ],
          //             titlesData: FlTitlesData(
          //               bottomTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 레이블 숨기기
          //               ),
          //               topTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 상단 타이틀 숨기기
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       const Text('Z acceleration'),
          //     ],
          //   ),
          // ),
          //
          // Expanded(
          //   child: Column(
          //     children: [
          //       Expanded(
          //         child: LineChart(
          //           LineChartData(
          //             borderData: FlBorderData(show: false),
          //             minY: -0.2,
          //             maxY: 0.2,
          //             lineBarsData: [
          //               LineChartBarData(
          //                 spots: ZPositons.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          //                 isCurved: true,
          //                 color: Colors.blue,
          //               ),
          //             ],
          //             titlesData: FlTitlesData(
          //               bottomTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 레이블 숨기기
          //               ),
          //               topTitles: AxisTitles(
          //                 sideTitles: SideTitles(showTitles: false), // X축 상단 타이틀 숨기기
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       const Text('Z acceleration'),
          //     ],
          //   ),
          // ),



          ElevatedButton(
            onPressed: _isListening ? _stopListening : _startListening,
            child: Text(_isListening ? "Stop Listening" : "Start Listening"),
          ),
        ],
      ),

    );
  }
}