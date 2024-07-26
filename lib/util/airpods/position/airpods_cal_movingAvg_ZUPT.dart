import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mocksum_flutter/util/airpods/PositionDisplay.dart';
import 'Quaternion.dart';

///측정로직 클래스
class AirpodsCalMovingAvgZupt extends Filter{
  double lastTimestamp = 0.0;
  List<double> accelometers = [0.0];
  List<double> velocities = [0.0];
  List<double> positions = [0.0];
  List<double> pastY = [0.0]; //가속도Y 히스토리
  List<double> pastZ = [0.0]; //가속도Z 히스토리
  static const double threshold = 0.015;

  Quaternion? initialQuaternion; //변위 최댓값 설정

  /// position값을 [0,limitValue]범위로 리턴, 비워두면 기존값그대로 리턴
  @override
  double getPosition([double limitValue=threshold]){
    return positions.last * (limitValue / threshold);
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
    //절사평균 : 추가 조정 필수
    for(int i = 1; i < sortedY.length-1;i++){
      cal_acc_y += sortedY[i];
      cal_acc_z += sortedZ[i];
    }
    cal_acc_y /= len-2;
    cal_acc_z /= len-2;
    //가속도의 편차 줄이기
    // double cal_acc = -cal_acc_y + cal_acc_z; //y,z축 둘다 고려하기
    // double cal_acc = -cal_acc_z; //y축만 고려하기
    double cal_acc = sqrt(cal_acc_y*cal_acc_y + cal_acc_z*cal_acc_z); //y,z축 방향제거된 norm값
    cal_acc *= (1-RotationAngle);
    cal_acc *= -cal_acc_y/(0.00001+cal_acc_y.abs()); // y축 경향으로 +- 따지기 + divided by zero 방지

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

  ///[velocity, postion] => [개선된 velocity, position] 제공
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
    if(deviation > 0.002) return [velocity, position];
    //위치 보상 알고리즘
    //속도가 비정상으로 뒤집힌 구간만큼 롤백
    position = compensatePosition(velocity, position);
    velocity = 0;
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

    ///위치 오차 보정 : 과도하게 커지거나 작아지면, limit값으로 강제 변경
    if(position > threshold) position = threshold;
    else if(position < 0) position = 0.0;
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
  List<double> positions = [0.0];
  @override
  void initState() {
    super.initState();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      Filter positionDisplay = AirpodsCalMovingAvgZupt();
      AirpodsCalMovingAvgZupt positionDisplayTest = positionDisplay as AirpodsCalMovingAvgZupt; //내부 테스트 용
      print("zzzz");
      accelometers = positionDisplayTest.accelometers;
      velocities = positionDisplayTest.velocities;
      positions = positionDisplayTest.positions;
      _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
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
                minY: 0.000, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.015, // Y축 최대값 설정
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