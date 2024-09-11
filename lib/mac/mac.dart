import 'dart:async';
import 'dart:ffi';
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
    double currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    double deltaTime = positions.length==1 ? 0 : currentTime - lastTimestamp;
    lastTimestamp = currentTime;

    double currentAccelY = data.userAcceleration.y.toDouble();
    double currentAccelZ = data.userAcceleration.z.toDouble();
    double currentAccelX = data.userAcceleration.x.toDouble();


    rawY.add(currentAccelY);
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
    // print(["raw가속도 평균값:", acc_offset]);
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
    // cal_acc_y /= (len-1)*len/2;
    cal_acc_y /= len;
    // cal_acc_y = (cal_acc_y + sortedY.last) / 2;
    cal_acc_y -= acc_offset;
    // cal_acc_z /= len-2;
    accelometersNotSmooth.add(currentAccelY - acc_offset);

    // print(tmp);
    //가속도의 편차 줄이기
    // double cal_acc = -cal_acc_y + cal_acc_z; //y,z축 둘다 고려하기
    double cal_acc = -cal_acc_y; //y축만 고려하기
    // cal_acc = hpfacc.process(cal_acc);

    accelometers.add(cal_acc);
    double offset = 0.01;
    if(cal_acc > offset) cal_acc -= 0.001;
    else if(cal_acc < -offset) cal_acc += 0.001;
    else cal_acc = 0;

    double velocity = velocities.last + cal_acc * deltaTime;
    // double NotZUPTvelocity = NotZUPTvelocities.last + cal_acc * deltaTime;
    // velocity = hpfvel.process(velocity);
    // velocity = mafv.process(velocity);
    double position = positions.last + velocity * deltaTime;
    double beforeposition = beforepositions.last + velocity * deltaTime;
    // position = hpfpos.process(position);
    // position = mafp.process(position);
    //ZUPT : 영속도 업데이트
    isZUPT.add(false);
    if(velocities.last * velocity < 0) stopFlag = true
    ;
    // NotZUPTvelocities.add(NotZUPTvelocity);
    // [velocity, position] = applyZUPT(velocity, position);
    [velocity, position] = applyZUPT(velocity, position);

    //화면상에서 100개 정보만 출력
    finalAccelometers.add(cal_acc);
    // accelometers.add(cal_acc);
    // velocities.add(velocity);

    velocities.add(velocity);
    positions.add(position);
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
    if(pitches.length > 500) pitches.removeAt(0);
    if(rolls.length > 500) rolls.removeAt(0);
    if(yaws.length > 500) yaws.removeAt(0);


    if(accelometersNotSmooth.length > 500) accelometersNotSmooth.removeAt(0);
    if(finalAccelometers.length > 500) finalAccelometers.removeAt(0);
    if(accelometers.length > 500) accelometers.removeAt(0);
    if(velocities.length > 500) velocities.removeAt(0);
    if(NotZUPTvelocities.length > 500) NotZUPTvelocities.removeAt(0);
    if(beforepositions.length > 500) beforepositions.removeAt(0);
    if(positions.length > 500) positions.removeAt(0);
    if(stablePositions.length > 500) stablePositions.removeAt(0);
  }

  //[velocity, postion] => [개선된 velocity, position] 제공
  List<double> applyZUPT(double velocity, double position){
    double deviation = 0.0;
    int windowSIZE = 20;
    if(finalAccelometers.length < windowSIZE) return [velocity, position];

    for(int i=finalAccelometers.length - windowSIZE;i<finalAccelometers.length;i++){
      deviation += finalAccelometers[i].abs();
    }
    deviation /= windowSIZE;
    print(deviation);
    // print(deviatio n);
    //편차 임계치 설정 추가 로직 필요 : 시간에 따라 가속도raw 측정값 자체의 오차가 커지는 현상 발견
    if(deviation > 0.0015) return [velocity, position];
    //위치 보상 알고리즘
    //속도가 비정상으로 뒤집힌 구간만큼 롤백
    position = compensatePosition(velocity, position);
    velocity = 0;
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
    //각도로 판단하는 거리 롤백
    // while(idx>=0 && (yaws[idx] - yaws.last).abs() < 0.1){
    //   idx--;
    // }
    // if(idx-100>=0 && (yaws[idx-100] - yaws.last).abs() > 0.1){
    //   position = positions[idx-100];
    //   return position;
    // }

    // while(idx>=0 && (yaws[idx] - yaws.last).abs() < 0.1){
    //   idx--;
    // }
    // while(idx>=3 && (yaws[idx-3] - yaws[idx])*(yaws[idx] - yaws.last) >= 0){
    //   idx--;
    // }
    // return position = positions[idx];

    // 속도그래프가 봉우리 모양이 아닐때 탐지 및 복구
    int idx_r = velocities.length -1;
    double MAX_velocity = 0;
    while(idx_r>=0 && MAX_velocity <= velocities[idx_r].abs()){
      MAX_velocity = max(MAX_velocity, velocities[idx_r].abs());
    }
    if(MAX_velocity/2 < velocities.last.abs()){ // 어 왜 속도가 0이 아니지?싶은 순간
      double lastVelocityValue = velocities.last;
      int idx_l=  idx_r;
      while(idx_l>=0 && velocities[idx_r].abs() < 0.001){
        velocities[idx_l] -= 2*lastVelocityValue;
        idx--;
      }
      //속도그래프의 삼각형구간을 역전시킨뒤 두배하여 위치를 복구함
      position = positions[idx_r] - 2*(positions[idx_r] - positions[idx_l]);
    }



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
      print("중단");
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
  List<double> accelometersNotSmooth = [0.0];
  List<double> finalAccelometers = [0.0];

  List<double> pitches = [0.0];
  List<double> rolls = [0.0];
  List<double> yaws = [0.0];

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
                      minY: -0.2,
                      maxY: 0.2,
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
          //             minY: 1.000,
          //             maxY: -1.000,
          //             lineBarsData: [
          //               LineChartBarData(
          //                 spots: yaws.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
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
          //       const Text('yaw Data'),
          //     ],
          //   ),
          // ),
          //
          ElevatedButton(
            onPressed: _isListening ? _stopListening : _startListening,
            child: Text(_isListening ? "Stop Listening" : "Start Listening"),
          ),
        ],
      ),

    );
  }
}