import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocksum_flutter/util/status_provider.dart';

import '../mac/flutter_airpods_mac.dart';

class LocationHandler {

  StreamSubscription<DeviceMotionData>? _airpodSubscription;
  double _nowPitch = 0;
  double _tempForDependency = 0;
  List<double> pitchList = [];
  int _minInterval = 0;
  int _turtleNeckStartedTimeStamp = 0;
  final List<double> _turtleNeckThreshold = [0.3, 0.4, 0.5];


  LocationHandler() {

    //todo 플랫폼별 분기

    if(Platform.isMacOS){
      _airpodSubscription = FlutterAirpodsMac.getAirPodsDeviceMotionUpdates.listen((data){
        _nowPitch = data.toJson()['pitch'];
        _tempForDependency = data.toJson()['pitch'];
        DetectStatus.nowPitch = _nowPitch;
        DetectStatus.tickCount = (DetectStatus.tickCount+1) % 300;
        // print(_minInterval);
        if (_checkIsNowTurtle() && _turtleNeckStartedTimeStamp == 0 && DetectStatus.sNowDetecting) {
          _turtleNeckStartedTimeStamp = DateTime.now().millisecondsSinceEpoch;
        }
        if (!_checkIsNowTurtle()) {
          _turtleNeckStartedTimeStamp = 0;
        }
        // print('test ${DetectStatus.sNowDetecting} ${} ${DateTime.now().millisecondsSinceEpoch}');
        if (DetectStatus.sNowDetecting && _checkIsNowTurtle() && _minInterval == 0 && DateTime.now().millisecondsSinceEpoch - _turtleNeckStartedTimeStamp >= DetectStatus.sAlarmGap*1000) {
          _showPushAlarm();
          // Provider.of<DetectStatus>(context, listen: false)
          _minInterval = 500;
          _turtleNeckStartedTimeStamp = 0;
        }
        if (_minInterval > 0) {
          _minInterval -= 1;
        }
      }) as StreamSubscription<DeviceMotionData>?;

      bg.BackgroundGeolocation.onHeartbeat((event) {
        print('hb ${DateTime.now()}');
        // _showPushAlarm(pitchList.length, pitchList.last);
        // print('on hb $pitchList');
        _tempForDependency += 1;

      });

    }else{


    _airpodSubscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
      _nowPitch = data.toJson()['pitch'];
      _tempForDependency = data.toJson()['pitch'];
      DetectStatus.nowPitch = _nowPitch;
      DetectStatus.tickCount = (DetectStatus.tickCount+1) % 300;
      // print(_minInterval);
      if (_checkIsNowTurtle() && _turtleNeckStartedTimeStamp == 0 && DetectStatus.sNowDetecting) {
        _turtleNeckStartedTimeStamp = DateTime.now().millisecondsSinceEpoch;
      }
      if (!_checkIsNowTurtle()) {
        _turtleNeckStartedTimeStamp = 0;
      }
      // print('test ${DetectStatus.sNowDetecting} ${} ${DateTime.now().millisecondsSinceEpoch}');
      if (DetectStatus.sNowDetecting && _checkIsNowTurtle() && _minInterval == 0 && DateTime.now().millisecondsSinceEpoch - _turtleNeckStartedTimeStamp >= DetectStatus.sAlarmGap*1000) {
        _showPushAlarm();
        // Provider.of<DetectStatus>(context, listen: false)
        _minInterval = 500;
        _turtleNeckStartedTimeStamp = 0;
      }
      if (_minInterval > 0) {
        _minInterval -= 1;
      }
    });

    bg.BackgroundGeolocation.onHeartbeat((event) {
      print('hb ${DateTime.now()}');
      // _showPushAlarm(pitchList.length, pitchList.last);
      // print('on hb $pitchList');
      _tempForDependency += 1;
    });
    }
  }


  bool _checkIsNowTurtle() {
    if (DetectStatus.initialPitch - _nowPitch > _turtleNeckThreshold[DetectStatus.sSensitivity]) {
      return true;
    } else {
      return false;
    }
  }

  Stream<DeviceMotionData> _getEventChannelStream() {
    const EventChannel _eventChannel = EventChannel('flutter_airpods.motion.mac');
    return _eventChannel.receiveBroadcastStream().map((event) {
      Map<String, dynamic> json = jsonDecode(event);

      /// Creates a [DeviceMotionData] from a JSON.
      DeviceMotionData deviceMotionData = DeviceMotionData.fromJson(json);

      /// Returns transformed [DeviceMotionData]
      return deviceMotionData;
    });
  }

  final NotificationDetails _details = const NotificationDetails(
      android: AndroidNotificationDetails('temp1', 'asdf'),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,

      )
  );

  Future<void> _showPushAlarm() async {
    FlutterLocalNotificationsPlugin localNotification =
    FlutterLocalNotificationsPlugin();

    await localNotification.show(0,
        '거북목 자세 감지',
        '바른 자세를 유지해봅시다!',
        _details
    );
  }

  void startBackgroundDetection() {
    bg.BackgroundGeolocation.ready(bg.Config(
        stopOnTerminate: false,
        startOnBoot: true,
        debug: false,
        heartbeatInterval: 10,
        preventSuspend: true
    )).then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });
  }

  void endBackgroundDetection() {
    bg.BackgroundGeolocation.stop();
  }

  void endAllDetection() {
    _airpodSubscription?.cancel();
    _airpodSubscription = null;
  }
}