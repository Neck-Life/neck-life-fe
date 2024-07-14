import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_airpods/models/user_acceleration.dart';

import 'Quaternion.dart';
// import 'package:turtleneck/util/airpods/Quaternion.dart';
// import
// import 'package:turtleneck/util/filter/MovingAvgFilter.dart';
//
// import '../filter/Filter.dart';

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
  Quaternion? initialQuaternion;
  final double sampleRate = 1/0.04;
  double lastTimestamp = 0.0;
  List<double> accelometers  = [0.0];
  List<double> velocities = [0.0];
  List<double> positions = [0.0];
  List<double> pastY = [0.0]; //가속도Y 히스토리
  List<double> pastZ = [0.0]; //가속도Z 히스토리
  double offset_y = 0.001543; //y축 초기 보정 - 임의 측정값임 없애도 됨

  bool hasUp = false;
  int time = 0;
  @override
  void initState() {
    super.initState();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
        _processSensorData(data);
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
      positions.clear();
      positions.add(0.0);
      velocities.clear();
      velocities.add(0.0);
      lastTimestamp= 0.0;
    });
  }

  void _processSensorData(DeviceMotionData data) {

    // 초기 자세 측정
    initialQuaternion ??= Quaternion(data.attitude.quaternion.w.toDouble(),
      data.attitude.quaternion.x.toDouble(),
      data.attitude.quaternion.y.toDouble(),
      data.attitude.quaternion.z.toDouble(),
    );
    var nowQuaternion = Quaternion(data.attitude.quaternion.w.toDouble(),
      data.attitude.quaternion.x.toDouble(),
      data.attitude.quaternion.y.toDouble(),
      data.attitude.quaternion.z.toDouble(),
    );
    var RotationAngle = calculateRotationAngle(initialQuaternion!,nowQuaternion);




    double currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    double deltaTime = positions.length==1 ? 0 : currentTime - lastTimestamp;
    lastTimestamp = currentTime;

    double currentAccelY = data.userAcceleration.y.toDouble();
    double currentAccelZ = data.userAcceleration.z.toDouble();
    pastY.add(currentAccelY);
    pastZ.add(currentAccelZ);
    int len = 6;
    if(pastY.length > len) pastY.removeAt(0);
    if(pastZ.length > len) pastZ.removeAt(0);

    double cal_acc_y = 0.0;
    double cal_acc_z = 0.0;
    List<double> sortedY = List.from(pastY);
    List<double> sortedZ = List.from(pastZ);
    sortedY.sort();
    sortedZ.sort();

    //절사평균 조정 필수
    for(int i = 1; i < sortedY.length-1;i++){
      cal_acc_y += sortedY[i];
      cal_acc_z += sortedZ[i];
    }
    cal_acc_y /= len-2;
    cal_acc_z /= len-2;
    // 절사평균


    // double cal_acc = -cal_acc_y + cal_acc_z;
    double cal_acc = -cal_acc_y;

    double offset = 0.002;
    if(cal_acc > offset) cal_acc -= offset;
    else if(cal_acc < -offset) cal_acc += offset;
    else cal_acc = 0;
    //가속도의 편차 줄이기
    double sum = 0;
    for(int i=0;i<accelometers.length;i++){
      sum += accelometers[i];
    }
    sum /= accelometers.length;
    // print(sum);


    double deviation = 0.0;

    for(int i=95;i<accelometers.length;i++){
      deviation += accelometers[i].abs();
    }
    deviation /= max(1, accelometers.length - 95);

    double velocity = velocities.last + cal_acc * deltaTime;
    double position = positions.last + velocity * deltaTime;
    // print(velocities.length);
    if(deviation <= 0.002) {
      int idx = velocities.length - 1;
      //위치 보상 알고리즘
      //속도가 비정상으로 뒤집힌 구간만큼 롤백
      while(idx>=0 && velocity * velocities[idx] > 0){
        // position -= velocities[idx] * deltaTime;
        velocities[idx] = 0;
        idx--;
      }
      velocity = 0;
      position = positions[idx];
    }
    //ZUPT : 영속도 업데이트




    accelometers.add(cal_acc);
    velocities.add(velocity);
    positions.add(position);

    bool isMaxLimited = true;
    bool isMinLimited = true;
    for(int i=95;i<positions.length; i++){
      if(positions[i] < 0.0090) isMaxLimited = false;
      if(positions[i] > 0.0002) isMinLimited = false;
    }

    //과도하게 올라간 변위 조정
    if(isMaxLimited && positions.length > 100){
      // position = 0.010;
      // if(velocity < 0) velocities[velocities.length-1] = 0.001;
      // print("거북이감지 1초간 정지 후 리셋");
      // velocities.clear();
      // positions.clear();
      // velocities.add(0);
      // positions.add(0);
      // sleep(Duration(seconds:1));
      // return;
    }
    //과도하게 내려간 변위조정
    if(isMinLimited){
      // position = 0.0;
      // if(velocity > 0) velocities[velocities.length-1] = -0.001;
    }
    // positions.removeLast();
    // positions.add(position);

    // print("pos_tmp : $pos_tmp, velocity : $velocity");
    if(accelometers.length > 100) accelometers.removeAt(0);

    if (velocities.length > 100) { // Keep last 100 data points
      velocities.removeAt(0);
    }
    if (positions.length > 100) { // Keep last 100 data points
      positions.removeAt(0);
    }


    setState(() {});
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
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: -0.2, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.2, // Y축 최대값 설정
                lineBarsData: [
                  LineChartBarData(
                    // spots: positions.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    // spots: velocities.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    spots: accelometers.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: -0.1, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.1, // Y축 최대값 설정
                lineBarsData: [
                  LineChartBarData(
                    // spots: positions.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    spots: velocities.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    // spots: accelometers.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: -0.01, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.02, // Y축 최대값 설정
                lineBarsData: [
                  LineChartBarData(
                    spots: positions.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    // spots: velocities.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    // spots: accelometers.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),

          ElevatedButton(
            onPressed: _isListening ? _stopListening : _startListening,
            child: Text(_isListening ? "Stop Listening" : "Start Listening"),
          ),

        ],
      ),
    );
  }
}