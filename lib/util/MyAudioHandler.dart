import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:flutter/services.dart';


class MyAudioHandler extends BaseAudioHandler {

  // final MethodChannel _channel = const MethodChannel("flutter.airpods.sensor");


  StreamSubscription<DeviceMotionData>? _subscription;
  double _nowPitch = 0;
  int _minInterval = 0;
  int _turtleNeckStartedTimeStamp = 0;
  final List<double> _turtleNeckThreshold = [0.3, 0.4, 0.5];

  final _audioPlayer = AudioPlayer();
  
  void _setAudioFile() async {
    await _audioPlayer.setUrl('asset:///assets/test.mp3');
  }

  final _customEventController = StreamController<dynamic>.broadcast();
  Timer? _backgroundTimer;

  Stream<dynamic> get customEventStream => _customEventController.stream;
  
  MyAudioHandler() {
    _setAudioFile();
    // _startBackgroundTask();
    _audioPlayer.setLoopMode(LoopMode.one);
    _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
      _customEventController.add(data);
      _nowPitch = data.toJson()['pitch'];
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
  }

  bool _checkIsNowTurtle() {
    if (DetectStatus.initialPitch - _nowPitch > _turtleNeckThreshold[DetectStatus.sSensitivity]) {
      return true;
    } else {
      return false;
    }
  }

  // void _startBackgroundTask() {
  //   _backgroundTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
  //     if (_audioPlayer.playing) {
  //       // Only emit events if audio is playing
  //       emitCustomEvent('Background task running at ${DateTime.now()}');
  //     }
  //   });
  // }
  //
  // dynamic _getNowAirpodsSensor() async {
  //   print('test1 start');
  //   final data = await _channel.invokeMethod("getAirpodsSensorData");
  //   print('test1 $data');

  //   return data;
  // }
  //
  // Future<void> emitCustomEvent(dynamic event) async {
  //   print('emit start');
  //   dynamic data = await _getNowAirpodsSensor();
  //   // double pitch = data['pitch'];
  //   print(data);
  //   _customEventController.add(event);
  //   print('emit end');
  // }

  final NotificationDetails _details = const NotificationDetails(
    android: AndroidNotificationDetails('temp1', 'asdf'),
    iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true
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

  @override
  Future<void> play() async {
    _audioPlayer.play();
  }

  @override
  Future<void> stop() async {
    _subscription?.cancel();
    _subscription = null;
    _backgroundTimer?.cancel();
    await super.stop();

  }
}