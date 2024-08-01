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

  final _bgAudioPlayer = AudioPlayer();
  // final _noticeAudioPlayer = AudioPlayer();
  // final playlist = ConcatenatingAudioSource(
  //   // Start loading next item just before reaching it
  //   useLazyPreparation: true,
  //   // Customise the shuffle algorithm
  //   shuffleOrder: DefaultShuffleOrder(),
  //   // Specify the playlist items
  //   children: [
  //     AudioSource.asset('assets/bg_sound.mp3'),
  //     AudioSource.asset('assets/noti.mp3'),
  //   ],
  // );

  // int _playingSoundIdx = 0;
  bool _isNowTurtle = false;

  void _setAudioFile() async {
    await _bgAudioPlayer.setAsset('assets/noti.mp3'); //setAudioSource(playlist, initialIndex: 0, initialPosition: Duration.zero);
    await _bgAudioPlayer.setLoopMode(LoopMode.one);
    // await _noticeAudioPlayer.setAsset('assets/noti.mp3');
    if (DetectStatus.sBgSoundActive) {
      await _bgAudioPlayer.setVolume(0.4);
    } else {
      await _bgAudioPlayer.setVolume(0);
    }

    // await _bgAudioPlayer.setClip(start: const Duration(seconds: 2), end: const Duration(seconds: 10));
  }

  final _customEventController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get customEventStream => _customEventController.stream;

  MyAudioHandler() {
    _setAudioFile();
    _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
      // print(_playingSoundIdx);
      // _customEventController.add(data);
      _nowPitch = data.toJson()['pitch'];
      DetectStatus.nowPitch = _nowPitch;
      DetectStatus.tickCount = (DetectStatus.tickCount+1) % 300;
      // print(_minInterval);
      if (_checkIsNowTurtle() && _turtleNeckStartedTimeStamp == 0 && DetectStatus.sNowDetecting) {
        _turtleNeckStartedTimeStamp = DateTime.now().millisecondsSinceEpoch;
      }
      if (!_checkIsNowTurtle()) {
        _turtleNeckStartedTimeStamp = 0;
        if (_isNowTurtle) {
          _isNowTurtle = false;
          emitCustomEvent('end');
          // _bgAudioPlayer.setAsset('assets/test_bg.mp3');
        }
        // if (_playingSoundIdx == 1) {
        //   _bgAudioPlayer.seekToPrevious();
        //   _playingSoundIdx = 0;
        // }
      }
      // print('test ${DetectStatus.sNowDetecting} ${} ${DateTime.now().millisecondsSinceEpoch}');
      if (DetectStatus.sNowDetecting && _checkIsNowTurtle() && _minInterval == 0 && DateTime.now().millisecondsSinceEpoch - _turtleNeckStartedTimeStamp >= DetectStatus.sAlarmGap*1000) {
        _showPushAlarm();
        _bgAudioPlayer.setVolume(0.4);
        // _noticeAudioPlayer.play();
        Timer(const Duration(seconds: 2), () {
          _bgAudioPlayer.setVolume(0);
        });
        _isNowTurtle = true;
        emitCustomEvent('turtle');
        // _bgAudioPlayer.setClip(start: const Duration(seconds: 15), end: const Duration(seconds: 17));
        // _bgAudioPlayer.setAsset('assets/noti.mp3');
        // _bgAudioPlayer.seekToNext();
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
  Future<void> emitCustomEvent(dynamic event) async {
    print('emit start');
    _customEventController.add(event);
    print('emit end');
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
    if (DetectStatus.sBgSoundActive) {
      await _bgAudioPlayer.setVolume(0.4);
    } else {
      await _bgAudioPlayer.setVolume(0);
    }
    _bgAudioPlayer.play();
  }

  @override
  Future<void> pause() {
    _bgAudioPlayer.pause();
    return super.pause();
  }

  @override
  Future<void> stop() async {
    // _subscription?.cancel();
    // _subscription = null;
    _bgAudioPlayer.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() => _bgAudioPlayer.seekToNext();

  @override
  Future<void> skipToPrevious() => _bgAudioPlayer.seekToPrevious();

}


// void _setAudioHandler() async {
//   _audioHandler = await AudioService.init(
//     builder: () => MyAudioHandler(),
//     config: const AudioServiceConfig(
//       androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
//       androidNotificationChannelName: 'Music playback',
//     )
//   );
//
//   _audioHandler.play();
//   _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
//   _audioHandler.customEventStream.listen((data) {
//   });
// }

