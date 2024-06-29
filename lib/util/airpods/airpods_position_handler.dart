import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:turtleneck/util/imufusion/FusionOffset.dart';
import 'package:turtleneck/util/imufusion/fusionAhrs.dart';
import '../imufusion/fusion_convention.dart';
import '../imufusion/fusion_math.dart';


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
  List<bool> isMoving = [];


  final double sampleRate = 400.0;
  double lastTimestamp = 0.0;
  List<double> timestamp = [];
  List<List<double>> gyroscope = [];
  List<List<double>> accelerometer = [];

  List<double> velocity = [0.0, 0.0, 0.0];
  List<double> position = [0.0, 0.0, 0.0];

  late FusionOffset offset;
  late FusionAhrs ahrs;

  DeviceMotionData? lastdata;


  @override
  void initState() {
    //초기 세팅

    super.initState();

    offset = FusionOffset(sampleRate.toInt());

    ahrs = FusionAhrs();
    ahrs.settings = (FusionAhrsSettings());
    FusionAhrsInitialise(ahrs);


    FusionAhrsSettings settings = FusionAhrsSettings(convention: FusionConvention.NWU,
        gain: 0.5,
        gyroscopeRange: 2000,
        accelerationRejection: 10,
        magneticRejection:  0,
        recoveryTriggerPeriod:  (5 * sampleRate).toInt());

    FusionAhrsSetSettings(ahrs, settings);

  }

  void _startListening() {

    print("start listening");

    setState(() {
      _isListening = true;
      _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
        // print('Data received: ${data.toJson()}');
         _processSensorData(data);
      }, onError: (error) {
        print('Error: $error'); // 오류 발생 시 출력
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

  void _processSensorData(DeviceMotionData data) {

    lastdata = data;

    double currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

    if (timestamp.isEmpty) {
      lastTimestamp = currentTime;
      timestamp.add(currentTime);
    } else {
      timestamp.add(currentTime - timestamp.first);
    }






    // Calculate delta time
    double deltaTime = currentTime - lastTimestamp;
    lastTimestamp = currentTime;

    // Update gyroscope with offset
    // List<double> currentGyro = offset.update(gyroscope);


    var currentGyro = FusionOffsetUpdate(offset, FusionVector(data.rotationRate.x , data.rotationRate.y, data.rotationRate.z ));

    // Calculate acceleration in m/s^2
    var currentAccel = FusionVector(data.userAcceleration.x - data.gravity.x , data.userAcceleration.y  - data.gravity.y , data.userAcceleration.z -  data.gravity.z);

    FusionAhrsUpdateNoMagnetometer(ahrs,currentGyro, currentAccel, deltaTime);

    var euler = FusionEuler(data.attitude.roll.toDouble(), data.attitude.pitch.toDouble(), data.attitude.yaw.toDouble());

    var fusionAhrsGetEarthAcceleration = FusionVectorMultiplyScalar(FusionAhrsGetEarthAcceleration(ahrs), 9.81);

    isMoving.add(sqrt(FusionVectorDotProduct(fusionAhrsGetEarthAcceleration, fusionAhrsGetEarthAcceleration)) > 1);   //threshold

    var margin =(0.1*sampleRate).toInt();

    //todo margin



    setState(() {

      velocity = [
        velocity[0] + fusionAhrsGetEarthAcceleration.x * deltaTime,
        velocity[1] + fusionAhrsGetEarthAcceleration.y * deltaTime,
        velocity[2] + fusionAhrsGetEarthAcceleration.z * deltaTime,
      ];

      print(velocity.toString());

      position = [
        position[0] + velocity[0] * deltaTime,
        position[1] + velocity[1] * deltaTime,
        position[2] + velocity[2] * deltaTime,
      ];


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
        title: const Text('Flutter Airpods example app'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text("Position: ${position.toString()}"),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isListening ? _stopListening : _startListening,
            child: Text(_isListening ? "Stop Listening" : "Start Listening"),
          ),
        ],
      ),
    );
  }
}