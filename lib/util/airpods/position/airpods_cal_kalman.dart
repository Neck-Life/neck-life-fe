import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../filter/KalmanFilterPosition.dart';
import '../../filter/KalmanFilterVelocity.dart';
import '../../filter/MovementFilter.dart';
import 'Quaternion.dart';





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
  List<double> accelerations = [0.0];
  List<double> rotationRatesX = [0.0];
  List<double> rotationRatesY = [0.0];
  List<double> rotationRatesZ = [0.0];
  List<double> roll = [0.0];
  List<double> pitch = [0.0];
  List<double> yaw = [0.0];
  List<double> quaternionY = [0.0];
  MovementFilter movementFilter = MovementFilter(10);
  double neckPosition =0;



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
    double deltaTime = velocities.length==1 ? 0 : currentTime - lastTimestamp;
    lastTimestamp = currentTime;



    double currentAccelY = data.userAcceleration.y.toDouble() * cos(RotationAngle);

    // print(data.attitude.quaternion.y);




    // print(" data rationRate: ${data.rotationRate.x} ${data.rotationRate.y} ${data.rotationRate.z} ");
    if(data.rotationRate.x.abs()-rotationRatesX.last.abs()
        + data.rotationRate.y.abs() -rotationRatesY.last.abs()
        + data.rotationRate.z.abs() -rotationRatesZ.last.abs() > 0.0000000000001) {

      currentAccelY =0;
    }
    // if(currentAccelY.abs() < 0.01) currentAccelY = 0.0;




    var kf_v = KalmanfilterVelocity();

    kf_v.setDt(deltaTime);
    kf_v.iterate([currentAccelY]);
    var estimate_vel = kf_v.x_esti[0];

    double velocityY = estimate_vel  ;




    var kf_p = KalmanfilterPosition();


    kf_p.setX([positions.last, 0]);

    kf_p.setDt(deltaTime);
    kf_p.iterate([velocityY]);
    var estimate_pos = kf_p.x_esti[0];


    // 탐지로직
    // 여기에 이동평균 씌워서 얼마나 이동했는지?
    var update = movementFilter.update(estimate_pos);

    if(update> 0.001){
      print("목이 앞으로 이동");
      print(update);
      neckPosition+=update;
      movementFilter.clear();
    }else if(update < -0.001){
      print("목이 뒤로 이동");
      print(update);
      neckPosition+=update;
      movementFilter.clear();
    }

    print("목 위치 : $neckPosition");

    // Store the position for visualization
    if (velocities.length > 5) { // Keep last 100 data points
      velocities.removeAt(0);
      // positions.clear();
      positions.removeAt(0);
      accelerations.removeAt(0);
      rotationRatesX.removeAt(0);
      rotationRatesY.removeAt(0);
      rotationRatesZ.removeAt(0);

      quaternionY.remove(0);
      

    }
    accelerations.add(currentAccelY);
    velocities.add(velocityY);
    positions.add(estimate_pos);
    rotationRatesX.add(data.rotationRate.x.toDouble());
    rotationRatesY.add(data.rotationRate.y.toDouble());
    rotationRatesZ.add(data.rotationRate.z.toDouble());


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
                minY: -0.1,
                maxY: 0.1,
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: accelerations.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
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
                minY: -0.1,
                maxY: 0.1,
                borderData: FlBorderData(show: false),
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