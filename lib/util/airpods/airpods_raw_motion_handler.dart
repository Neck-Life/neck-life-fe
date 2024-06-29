import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AirpodsTestApp(),
    );
  }
}

class AirpodsTestApp extends StatefulWidget {
  @override
  _AirpodsTestAppState createState() => _AirpodsTestAppState();
}

class _AirpodsTestAppState extends State<AirpodsTestApp> {
  StreamSubscription<DeviceMotionData>? _subscription;
  bool _isListening = false;

  void _startListening() {
    setState(() {
      _isListening = true;
      _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
        print('Data received: ${data.toJson()}');
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
        title: const Text('Flutter Airpods Test App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _isListening ? _stopListening : _startListening,
          child: Text(_isListening ? 'Stop' : 'Start'),
        ),
      ),
    );
  }
}