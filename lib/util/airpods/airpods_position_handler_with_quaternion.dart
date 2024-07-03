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
  List<double> positions = [0.0];

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



    if(currentAccelY.abs()*cos(RotationAngle) < 0.1) {
      currentAccelY = 0;
    }
    double velocityY =  positions.last + currentAccelY * deltaTime * cos(RotationAngle);

    // Store the position for visualization
    if (positions.length > 100) { // Keep last 100 data points
      positions.removeAt(0);
    }
    positions.add(velocityY);

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