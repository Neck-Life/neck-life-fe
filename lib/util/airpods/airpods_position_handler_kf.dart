import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:turtleneck/util/airpods/Quaternion.dart';
import 'package:turtleneck/util/filter/LPFFilter.dart';

import '../detection/dection_filter.dart';

import '../filter/KalmanFilterV2.dart';

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


  // 거북목 경향 측정
  bool _isSaving = false;
  List<double> _data = [];

  List<double> correlation = [];
  late detectionFilter detection_filter;


  void _startSaving() {
    setState(() {
      _isSaving = true;
      _data.clear();
      _isListening = true;
      _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
        double currentAccelY = data.userAcceleration.y.toDouble();


        //
        // if(currentAccelY.abs()*cos(RotationAngle) < 0.05) {
        //   currentAccelY = 0;
        // }

        var kf_v = KalmanFilter();

        kf_v.setDt(0.4);
        kf_v.iterate([currentAccelY]);
        var estimate_vel = kf_v.x_esti[0];
        _data.add(estimate_vel);

      }, onError: (error) {
        print('Error: $error');
      });


    });
  }

  void _stopSaving() {
    setState(() {
      _isSaving = false;
      _isListening = false;
      _subscription?.cancel();
      _subscription = null;
      velocities.clear();
      velocities.add(0.0);
      lastTimestamp= 0.0;

      detection_filter =  detectionFilter(_data);

    });
  }


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

    double currentAccelY = data.userAcceleration.y.toDouble();


    //
    // if(currentAccelY.abs()*cos(RotationAngle) < 0.05) {
    //   currentAccelY = 0;
    // }

    var kf_v = KalmanFilter();

    kf_v.setDt(deltaTime);
    kf_v.iterate([currentAccelY]);
    var estimate_vel = kf_v.x_esti[0];

    // var kf_p = KalmanFilter();
    // kf_p.setX([positions.last]);
    //
    // kf_p.setDt(deltaTime);
    // kf_p.iterate([estimate_vel]);
    // var estimate_pos = kf_v.x_esti[0];


    // 절대값 추정
    // var calculatedCorrelation = detection_filter.getCorrelation(velocities);
    //
    //
    //
    // correlation.add(calculatedCorrelation);
    //  // print(calculatedCorrelation);
    // if(calculatedCorrelation> 0.7) {
    //
    //   print('거북목 경향이 있습니다.');
    // }else if(calculatedCorrelation < -0.7) {
    //   print('뒤로 이동입니다.');
    // }

    // relation_sum.clear();


    // if (estimate_vel.abs() < 0.001) estimate_vel = 0.0; //미세한 가속도는 노이즈로 판단하여 제거

    double velocityY = estimate_vel  * cos(RotationAngle);

    // LPFFilter lpfFilter = LPFFilter(0.1);
    //
    // double estimate_acc = lpfFilter.filter(currentAccelY);

    // if (estimate_acc.abs() < 0.001) estimate_acc = 0.0; //미세한 가속도는 노이즈로 판단하여 제거
    //
    // double velocityY = velocities.last+ estimate_acc * deltaTime * cos(RotationAngle);




    // if(velocityY > 0.005) velocityY -= 0.00005; //속도를 점진적으로 줄임으로써, 정적상태의 속도변화를 제거
    // if(velocityY < 0.005) velocityY += 0.00005;

    
    // double calVelocity = estimate_vel * deltaTime * cos(RotationAngle);
    // double PositionY =  velocities.last +calVelocity * deltaTime;

    double PositionY = positions.last + velocityY * deltaTime;

    // print(PositionY);

    // Store the position for visualization
    if (velocities.length > 100) { // Keep last 100 data points
      velocities.removeAt(0);
      positions.removeAt(0);
      // velocities.clear();
      // positions.clear();

    }
    velocities.add(velocityY);
    positions.add(PositionY);

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
                    spots: velocities.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
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

          ElevatedButton(
            onPressed: _isSaving ? _stopSaving : _startSaving,
            child: Text(_isSaving ? "Stop Saving" : "Start Saving"),
          ),

        ],
      ),
    );
  }
}