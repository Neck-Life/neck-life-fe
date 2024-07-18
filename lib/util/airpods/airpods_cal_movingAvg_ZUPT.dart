import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mocksum_flutter/util/airpods/PositionDisplay.dart';

///측정로직 클래스
class AirpodsCalMovingAvgZupt extends PositionDisplay{
  // final double sampleRate = 1/0.04;
  double lastTimestamp = 0.0;
  List<double> accelometers = [0.0];
  List<double> velocities = [0.0];
  List<double> positions = [0.0];
  List<double> pastY = [0.0]; //가속도Y 히스토리
  List<double> pastZ = [0.0]; //가속도Z 히스토리
  // double offset_y = 0.001543; //y축 초기 보정 - 임의 측정값임 없애도 됨

  @override
  double getPosition() {
    return positions.last;
  }

  ///compensatePosition : 비정상 속도히스토리,위치 보상 알고리즘
  /// <- applyZUPT : 영속도 보정 알고리즘
  ///  <- processSensorData : 측정 1틱 진입점
  double compensatePosition(double velocity, double position){
    //위치 보상 알고리즘
    //속도가 비정상으로 뒤집힌 구간만큼 롤백
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
    return position;
  }

  //velocity, postion -> 개선된 velocity, position 제공
  List<double> applyZUPT(double velocity, double position){
    double deviation = 0.0;
    int windowSIZE = 10;
    for(int i=max(0,accelometers.length - windowSIZE);i<accelometers.length;i++){
      deviation += accelometers[i].abs();
    }
    deviation /= min(accelometers.length, windowSIZE);

    if(deviation > 0.0002) return [velocity, position];
    //위치 보상 알고리즘
    //속도가 비정상으로 뒤집힌 구간만큼 롤백
    position = compensatePosition(velocity, position);
    velocity = 0;
    return [velocity, position];
  }

  @override
  void processSensorData(DeviceMotionData data) {

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

    //절사평균 : 추가 조정 필수
    for(int i = 1; i < sortedY.length-1;i++){
      cal_acc_y += sortedY[i];
      cal_acc_z += sortedZ[i];
    }
    cal_acc_y /= len-2;
    cal_acc_z /= len-2;

    //가속도의 편차 줄이기
    // double cal_acc = -cal_acc_y + cal_acc_z;
    double cal_acc = -cal_acc_y;
    double offset = 0.005;
    if(cal_acc > offset) cal_acc -= offset;
    else if(cal_acc < -offset) cal_acc += offset;
    else cal_acc = 0;

    double velocity = velocities.last + cal_acc * deltaTime;
    double position = positions.last + velocity * deltaTime;
    //ZUPT : 영속도 업데이트
    [velocity, position] = applyZUPT(velocity, position);


    //화면상에서 100개 정보만 출력
    accelometers.add(cal_acc);
    velocities.add(velocity);
    positions.add(position);
    if(accelometers.length > 100) accelometers.removeAt(0);
    if(velocities.length > 100) velocities.removeAt(0);
    if(positions.length > 100) positions.removeAt(0);
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
  List<double> positions = [0.0];
  @override
  void initState() {
    super.initState();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      // PositionDisplay positionDisplay = new AirpodsCalMovingAvgZupt();
      AirpodsCalMovingAvgZupt positionDisplay = AirpodsCalMovingAvgZupt();
      accelometers = positionDisplay.accelometers;
      velocities = positionDisplay.velocities;
      positions = positionDisplay.positions;
      _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
        print(positionDisplay.getPosition());
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
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: -0.2, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.2, // Y축 최대값 설정
                lineBarsData: [
                  LineChartBarData(
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
                    spots: velocities.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
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