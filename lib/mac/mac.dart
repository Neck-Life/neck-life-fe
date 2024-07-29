import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Core Head Motion Example'),
        ),
        body: Center(
          child: HeadMotionWidget(),
        ),
      ),
    );
  }
}

class HeadMotionWidget extends StatefulWidget {
  @override
  _HeadMotionWidgetState createState() => _HeadMotionWidgetState();
}

class _HeadMotionWidgetState extends State<HeadMotionWidget> {
  static const EventChannel _eventChannel = EventChannel('flutter_airpods.motion');
  String _motionData = 'Unknown head motion data';
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void _onEvent(dynamic event) {
    setState(() {
      _motionData = event;
    });
  }

  void _onError(dynamic error) {
    setState(() {
      _motionData = 'Failed to get head motion data: ${error.message}';
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_motionData);
  }
}
