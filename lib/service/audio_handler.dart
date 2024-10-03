import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocksum_flutter/util/airpods/PositionDisplay.dart';
import 'package:mocksum_flutter/service/history_provider.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:just_audio/just_audio.dart';


class MyAudioHandler extends BaseAudioHandler {

  StreamSubscription<DeviceMotionData>? _subscription;
  double _nowPitch = 0;
  double _nowPosition = 0;
  int _minInterval = 0;
  int _turtleNeckStartedTimeStamp = 0;
  final List<double> _turtleNeckThreshold = [0.5, 0.4, 0.3];
  final PositionDisplay _headPositionHandler = PositionDisplay();
  Map<String, dynamic> _poseLog = {"history": {}};
  bool _isPlaying = false;

  final _bgAudioPlayer = AudioPlayer();
  bool _isNowTurtle = false;
  // last 로그로 한번 더 분기?

  static const applicationLifecycleChannel = BasicMessageChannel<String>('applicationLifeCycle', StringCodec());
  static const kApplicationWillTerminate = 'applicationWillTerminate';

  void _setAudioFile() async {
    await _bgAudioPlayer.setAsset('assets/noti.mp3');
    await _bgAudioPlayer.setLoopMode(LoopMode.one);
    await _bgAudioPlayer.setVolume(0);
  }

  final _customEventController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get customEventStream => _customEventController.stream;

  MyAudioHandler() {
    _setAudioFile();
    applicationLifecycleChannel.setMessageHandler((message) async {
      switch(message) {
        case kApplicationWillTerminate:
          print('app end');
          if (_isPlaying) {
            _poseLog['history'][DateTime.now().toIso8601String().split('.')[0].substring(0, 18)] = 'END';
            HistoryStatus.postMeasuredPoseData(_poseLog);

          }
          break;
        default:
          break;
      }
      return message!;
    });

    _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
      _nowPitch = data.toJson()['pitch'];
      _headPositionHandler.processSensorData(data);

      if(DetectStatus.isLabMode) {
        _nowPosition = _headPositionHandler.getPosition(0.5);
      }else{
        _nowPosition = 0;
      }

      DetectStatus.nowPitch = _nowPitch;

      DetectStatus.nowPosition = _nowPosition;
      DetectStatus.tickCount = (DetectStatus.tickCount+1) % 300;
      if (_checkIsNowTurtle() && _turtleNeckStartedTimeStamp == 0 && DetectStatus.sNowDetecting) {
        _turtleNeckStartedTimeStamp = DateTime.now().millisecondsSinceEpoch;
        if (_minInterval <= 0) {
          // _poseLog['history']
          _poseLog['history'][DateTime.now().toIso8601String().split('.')[0]
              .substring(0, 19)] = 'FORWARD';
          print('FORWARD');
        }
      }

      if (!_checkIsNowTurtle()) {
        _turtleNeckStartedTimeStamp = 0;
        if (_isNowTurtle) {
          print('NORMAL');
          _poseLog['history'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'NORMAL';
          _isNowTurtle = false;
          emitCustomEvent('end');
        }
      }

      _isNowTurtle = _checkIsNowTurtle();

      if (DetectStatus.sNowDetecting && _checkIsNowTurtle() && _minInterval == 0 && DateTime.now().millisecondsSinceEpoch - _turtleNeckStartedTimeStamp >= DetectStatus.sAlarmGap*1000) {
        _showPushAlarm();
        // _poseLog['history'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'FORWARD';
        if (DetectStatus.sBgSoundActive) {
          _bgAudioPlayer.setVolume(0.4);
          Timer(const Duration(seconds: 2), () {
            _bgAudioPlayer.setVolume(0);
          });
        }
        _isNowTurtle = true;
        emitCustomEvent('turtle');
        _minInterval = 25;
        _turtleNeckStartedTimeStamp = 0;
      }
      if (_minInterval > 0) {
        _minInterval -= 1;
      }
    });

    HistoryStatus.postDataNotPosted();
  }

  bool _checkIsNowTurtle() {
    if (DetectStatus.initialPitch - _nowPitch > _turtleNeckThreshold[DetectStatus.sSensitivity] || DetectStatus.nowPosition > 0.2) {
      return true;
    } else {
      return false;
    }
  }


  Future<void> emitCustomEvent(dynamic event) async {
    _customEventController.add(event);
  }

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
    _isPlaying = true;
    _poseLog['history'] = {};
    _poseLog['history'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'START';
    // print('start ${DateTime.now().toIso8601String().split('.')[0].substring(0, 19)}');
    await _bgAudioPlayer.setVolume(0);
    _bgAudioPlayer.play();
  }

  @override
  Future<void> pause() {
    print('pause');
    _isPlaying = false;
    _poseLog['history'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'END';
    // print('end ${DateTime.now().toIso8601String().split('.')[0].substring(0, 19)}');
    print(_poseLog);
    HistoryStatus.postMeasuredPoseData(_poseLog);
    // print('poselog $_poseLog');
    _bgAudioPlayer.pause();
    _minInterval = 0;
    _turtleNeckStartedTimeStamp = 0;
    _poseLog = {"history": {}};
    return super.pause();
  }

  @override
  Future<void> stop() async {
    _bgAudioPlayer.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() => _bgAudioPlayer.seekToNext();

  @override
  Future<void> skipToPrevious() => _bgAudioPlayer.seekToPrevious();

}

