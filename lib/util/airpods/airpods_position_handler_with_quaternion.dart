import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:turtleneck/util/airpods/Quaternion.dart';

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
  List<double> velocities = [0.0];
  List<double> positions = [0.0];
  List<double> past = [0.0]; //가속도 히스토리
  double offset_y = 0.001543; //y축 초기 보정 - 임의 측정값임 없애도 됨
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
    past.add(currentAccelY);
    if(past.length > 20) past.removeAt(0);
    double cal_acc = 0.0;
    for(int i=0;i<past.length;i++){
      cal_acc += past[i];
    }

    cal_acc /= past.length;
    cal_acc -= 0.0015; //왜 변수로 계산안되는진 모르겠어서, 상수로 빼버림
    //최근 가속도 n개 평균을 낸 후, offset만큼 제거

    // if(currentAccelY.abs()*cos(RotationAngle) < 0.1) {
    //   currentAccelY = 0;
    // }
    // double velocityY =  positions.last + currentAccelY * deltaTime * cos(RotationAngle);
    // double velocityY =  positions.last + cal_acc * deltaTime * cos(RotationAngle);
    if (cal_acc.abs() < 0.003) cal_acc = 0.0; //미세한 가속도는 노이즈로 판단하여 제거
    double velocityY = velocities.last + cal_acc * deltaTime * cos(RotationAngle);
    if(velocityY > 0.0001) velocityY -= 0.0001; //속도를 점진적으로 줄임으로써, 정적상태의 속도변화를 제거
    if(velocityY < 0.0001) velocityY += 0.0001;

    double positionY = positions.last + velocityY * deltaTime;
    // Store the position for visualization

    if (velocities.length > 100) { // Keep last 100 data points
    velocities.removeAt(0);
    }
    if (positions.length > 100) { // Keep last 100 data points
      positions.removeAt(0);
    }
    velocities.add(velocityY); //속도 그래프로 보기
    // positions.add(currentAccelY.toDouble());
    // positions.add(cal_acc); //평균필터쓴 가속도 그래프로 보고
    positions.add(positionY); //변위 그래프로 보기
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
        title: const Text('Flutter Airpods Example App'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: -0.5, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.5, // Y축 최대값 설정
                lineBarsData: [
                  LineChartBarData(
                    spots: positions.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    // spots: velocities.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
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