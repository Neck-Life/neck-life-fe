import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/service/stretching_timer.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/util/airpods/PositionDisplay.dart';
import 'package:mocksum_flutter/service/history_provider.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:just_audio/just_audio.dart';

import '../main.dart';
import 'global_timer.dart';


class MyAudioHandler extends BaseAudioHandler {

  StreamSubscription<DeviceMotionData>? _subscription;

  double _nowPitch = 0;
  double _nowRoll = 0;
  double _nowYaw = 0;
  double _nowPosition = 0;
  bool _isBackward = false;
  int _minInterval = 0;
  int _minInterval2 = 0;
  int _minInterval3 = 0;
  int _turtleNeckStartedTimeStamp = 0;
  int _turtleNeckStartedTimeStamp2 = 0;
  int _turtleNeckStartedTimeStamp3 = 0;
  final List<double> _slouchTiltThreshold = [0.4, 0.3, 0.2];
  final List<double> _forwardNeckThreshold = [0.2, 0.15, 0.1];
  final PositionDisplay _headPositionHandler = PositionDisplay();
  Map<String, dynamic> _poseForwardLog = {"forward": {}};
  Map<String, dynamic> _posePitchLog = {"pitch": {}};
  Map<String, dynamic> _poseTiltLog = {"tilt": {}};
  List<dynamic> _poseRawLog = [{'timestamp': DateTime.now().toIso8601String(),
    'pitch': 0,
    'roll': 0,
    'position': 0,}];

  bool isPlaying = false;
  bool isPlugged = true;

  double _alertVolume = 0.4;


  final _bgAudioPlayer = AudioPlayer();
  final _notiPlayer = AudioPlayer();
  bool _isNowHeadDown = false;
  bool _isNowTilt = false;
  bool _isNowForwardOrBackward = false;
  // bool _isNowBackward = false;
  // last 로그로 한번 더 분기?

  static const applicationLifecycleChannel = BasicMessageChannel<String>('applicationLifeCycle', StringCodec());
  static const kApplicationWillTerminate = 'applicationWillTerminate';

  String beforeHeadDownState = "NORMAL";
  String nowHeadDownState = "NORMAL";

  String beforeForwardState = "NORMAL";
  String nowForwardState = "NORMAL";

  String beforeTiltState = "NORMAL";
  String nowTiltState = "NORMAL";

  Timer? _timerForward;
  Timer? _timerForward2;
  Timer? _timerForward3;

  bool canPitchLog = false;
  bool canForwardLog = false;
  bool canTiltLog = false;

  int LoggingTime = 2;

  void _setAudioFile() async {
    // const storage = FlutterSecureStorage();
    String? filename = await storage.read(key: 'soundFileName');
    String? volume = await storage.read(key: 'soundVolume');
    _alertVolume = double.parse(volume ?? '0.4');
    await _notiPlayer.setAsset('assets/${filename ?? 'noti.mp3'}');
    await _notiPlayer.setLoopMode(LoopMode.one);
    await _notiPlayer.setVolume(0);

    await _bgAudioPlayer.setAsset('assets/white.mp3');
    await _bgAudioPlayer.setLoopMode(LoopMode.one);
    await _bgAudioPlayer.setVolume(0.4);
  }

  final _customEventController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get customEventStream => _customEventController.stream;

  MyAudioHandler() {
    _setAudioFile();
    applicationLifecycleChannel.setMessageHandler((message) async {
      switch(message) {
        case kApplicationWillTerminate:
          print('app end');
          if (DetectStatus.sNowDetecting) {
            _poseForwardLog['forward'][DateTime.now().toIso8601String().split('.')[0].substring(0, 18)] = 'END';
            _posePitchLog['pitch'][DateTime.now().toIso8601String().split('.')[0].substring(0, 18)] = 'END';
            _poseTiltLog['tilt'][DateTime.now().toIso8601String().split('.')[0].substring(0, 18)] = 'END';

            //todo
            HistoryStatus.postMeasuredPoseData(_poseForwardLog, _posePitchLog, _poseTiltLog, _poseRawLog);
          }
          break;
        default:
          break;
      }
      return message!;
    });

    _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
      handleMotionData(data);
    });
  }

  void handleMotionData(dynamic data) {
    _nowPitch = data.attitude.pitch.toDouble();
    _nowRoll = data.attitude.roll.toDouble();
    _nowYaw = data.toJson()['yaw'];
    _headPositionHandler.processSensorData(data);

    // if(DetectStatus.isLabMode) {
    //   _nowPosition = _headPositionHandler.getPosition(0.5);
    // }else{
    //   _nowPosition = 0;
    // }

    if (DetectStatus.sUseHorizontalMove) {
      _nowPosition = _headPositionHandler.getPosition(0.5);
    } else {
      _nowPosition = 0;
    }
    _isBackward = _headPositionHandler.isBackward();
    // _checkIsBackward();

    //로우데이터 저장
    // _poseRawLog.add({
    //   'timestamp': DateTime.now().toIso8601String(),
    //   'pitch': _nowPitch,
    //   'roll': _nowRoll,
    //   'position': _nowPosition,
    //   // 'status' : _checkIsNowTurtle() ? 'FORWARD' : 'NORMAL'
    // });



    // 로깅 최소시간 설정 - pitch값
    if (beforeHeadDownState != nowHeadDownState) {
      // 상태가 변경되었을 때
      // print('상태 변경: $beforeState -> $nowState');
      _timerForward?.cancel(); // 기존 타이머 취소
      beforeHeadDownState = nowHeadDownState;

      // 새로운 타이머 시작
      _timerForward = Timer(Duration(seconds: LoggingTime), () {
        // 상태가 3초 동안 지속되었을 때 로깅 수행
        canPitchLog = true;
      });
    } else {
      // 상태가 변경되지 않았을 때
      // 타이머가 없으면 시작
      if (_timerForward == null || !_timerForward!.isActive) {
        _timerForward = Timer(Duration(seconds: LoggingTime), () {
          canPitchLog = true;
        });
      }
    }

    // 로깅 최소시간 설정 - forward값
    if (beforeForwardState != nowForwardState) {
      // 상태가 변경되었을 때
      // print('상태 변경: $beforeState -> $nowState');
      _timerForward2?.cancel(); // 기존 타이머 취소
      beforeForwardState = nowForwardState;

      // 새로운 타이머 시작
      _timerForward2 = Timer(Duration(seconds: LoggingTime), () {
        // 상태가 3초 동안 지속되었을 때 로깅 수행
        canForwardLog = true;
      });
    } else {
      // 상태가 변경되지 않았을 때
      // 타이머가 없으면 시작
      if (_timerForward2 == null || !_timerForward2!.isActive) {
        _timerForward2 = Timer(Duration(seconds: LoggingTime), () {
          canForwardLog = true;
        });
      }
    }

    // 로깅 최소시간 설정 - tilt값
    if (beforeTiltState != nowTiltState) {
      // 상태가 변경되었을 때
      // print('상태 변경: $beforeState -> $nowState');
      _timerForward3?.cancel(); // 기존 타이머 취소
      beforeTiltState = nowTiltState;

      // 새로운 타이머 시작
      _timerForward3 = Timer(Duration(seconds: LoggingTime), () {
        // 상태가 3초 동안 지속되었을 때 로깅 수행
        canTiltLog = true;
      });
    } else {
      // 상태가 변경되지 않았을 때
      // 타이머가 없으면 시작
      if (_timerForward3 == null || !_timerForward3!.isActive) {
        _timerForward3 = Timer(Duration(seconds: LoggingTime), () {
          canTiltLog = true;
        });
      }
    }




    DetectStatus.nowPitch = _nowPitch;
    DetectStatus.nowRoll = _nowRoll;
    DetectStatus.nowYaw = _nowYaw;

    /** 스트레칭 모드일때는 거북목 탐지 안함 */
    if(StretchingTimer.isStretchingMode) return;


    DetectStatus.nowPosition = _nowPosition;
    DetectStatus.tickCount = (DetectStatus.tickCount+1) % 300;



    if (_checkIsHeadDown() && _turtleNeckStartedTimeStamp == 0 && DetectStatus.sNowDetecting) {
      _turtleNeckStartedTimeStamp = DateTime.now().millisecondsSinceEpoch;
      if (_minInterval <= 0 && canPitchLog) {
        // _poseLog['history']

        _posePitchLog['pitch'][DateTime.now().toIso8601String().split(
            '.')[0].substring(0, 19)] = 'DOWN';



        // _posePitchLog['pitch'][DateTime.now().toIso8601String().split('.')[0]
        //     .substring(0, 19)] = 'DOWN';
        // print('FORWARD');
        canPitchLog = false;
      }
    }

    //pitch 값들

    if (!_checkIsHeadDown()) {
      _turtleNeckStartedTimeStamp = 0;
      if (_isNowHeadDown  && canPitchLog) {


        // print(DateTime.now().toIso8601String());

        // print('NORMAL');
        _posePitchLog['pitch'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'DOWNNORMAL';
        _isNowHeadDown = false;
        emitCustomEvent('end');
        canPitchLog = false;
      }
    }

    _isNowHeadDown = _checkIsHeadDown();

    // print(_isNowHeadDown);

    if (DetectStatus.sNowDetecting && _checkIsHeadDown() && _minInterval == 0 && DateTime.now().millisecondsSinceEpoch - _turtleNeckStartedTimeStamp >= DetectStatus.sAlarmGap*1000) {
      GlobalTimer.alarmCount += 1;
      if (DetectStatus.sPushNotiAvtive) {
        _showPushAlarm();
      }
      // _posePitchLog['pitch'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'HEADDOWN';
      if (DetectStatus.sBgSoundActive) {
        _notiPlayer.setVolume(_alertVolume);
        // _notiPlayer.play();
        Timer(const Duration(seconds: 2), () {
          _notiPlayer.setVolume(0);
          // _notiPlayer.stop();
        });
      }
      _isNowHeadDown = true;
      emitCustomEvent('turtle');
      _minInterval = 25;
      _turtleNeckStartedTimeStamp = 0;
    }


    // if (_minInterval > 0) {
    //   _minInterval -= 1;
    // }



    if (_checkIsForward() && _turtleNeckStartedTimeStamp2 == 0 && DetectStatus.sNowDetecting) {
      _turtleNeckStartedTimeStamp2 = DateTime.now().millisecondsSinceEpoch;
      if (_minInterval2 <= 0 ) {
        // _poseLog['history']
        // if(_isBackward){
        //   _poseForwardLog['forward'][DateTime.now().toIso8601String().split(
        //       '.')[0].substring(0, 19)] = 'BACKWARD';
        // }else {
        //   _poseForwardLog['forward'][DateTime.now().toIso8601String().split(
        //       '.')[0].substring(0, 19)] = 'FORWARD';
        // }

        _poseForwardLog['forward'][DateTime.now().toIso8601String().split(
            '.')[0].substring(0, 19)] = 'FORWARD';
        // print('FORWARD');
        // canPitchLog = false;
      }
    }



    if (!_checkIsForward()) {
      _turtleNeckStartedTimeStamp2 = 0;
      if (_isNowForwardOrBackward  && canForwardLog) {
        // print('NORMAL');
        _poseForwardLog['forward'][DateTime.now().add(Duration(seconds: -LoggingTime)).toIso8601String().split('.')[0].substring(0, 19)] = 'FORWARDNORMAL';
        _isNowForwardOrBackward = false;
        emitCustomEvent('end');
        // canPitchLog = false;
      }
    }

    _isNowForwardOrBackward = _checkIsForward();

    if (DetectStatus.sNowDetecting && _checkIsForward() && _minInterval2 == 0 && DateTime.now().millisecondsSinceEpoch - _turtleNeckStartedTimeStamp2 >= DetectStatus.sAlarmGap*1000) {
      GlobalTimer.alarmCount += 1;
      if (DetectStatus.sPushNotiAvtive) {
        _showPushAlarm();
      }

      if (DetectStatus.sBgSoundActive) {
        _notiPlayer.setVolume(DetectStatus.sSoundVolume);
        // _notiPlayer.play();
        Timer(const Duration(seconds: 2), () {
          _notiPlayer.stop();
          _notiPlayer.setVolume(0);
        });
      }
      _isNowForwardOrBackward = true;
      emitCustomEvent('turtle');
      _minInterval2 = 25;
      _turtleNeckStartedTimeStamp2 = 0;
    }



    // tilt값 설정

    if (_checkIsTilt() && _turtleNeckStartedTimeStamp3 == 0 && DetectStatus.sNowDetecting) {
      _turtleNeckStartedTimeStamp3 = DateTime.now().millisecondsSinceEpoch;
      if (_minInterval3 <= 0 ) {

        _poseTiltLog['tilt'][DateTime.now().toIso8601String().split(
            '.')[0].substring(0, 19)] = 'TILT';

      }
    }


    if (!_checkIsTilt()) {
      _turtleNeckStartedTimeStamp3 = 0;
      if (_isNowTilt  && canForwardLog) {
        // print('NORMAL');
        _poseTiltLog['tilt'][DateTime.now().add(Duration(seconds: -LoggingTime)).toIso8601String().split('.')[0].substring(0, 19)] = 'TILTNORMAL';
        _isNowTilt = false;
        emitCustomEvent('end');
        // canPitchLog = false;
      }
    }

    _isNowTilt = _checkIsTilt();

    if (DetectStatus.sNowDetecting && _checkIsTilt() && _minInterval3 == 0 && DateTime.now().millisecondsSinceEpoch - _turtleNeckStartedTimeStamp3 >= DetectStatus.sAlarmGap*1000) {
      GlobalTimer.alarmCount += 1;
      if (DetectStatus.sPushNotiAvtive) {
        _showPushAlarm();
      }

      if (DetectStatus.sBgSoundActive) {
        _notiPlayer.setVolume(_alertVolume);
        // _notiPlayer.play();
        Timer(const Duration(seconds: 2), () {
          _notiPlayer.setVolume(0);
          // _notiPlayer.stop();
        });
      }
      _isNowTilt = true;
      emitCustomEvent('turtle');
      _minInterval3 = 25;
      _turtleNeckStartedTimeStamp3 = 0;
    }



    if (_minInterval > 0) {
      _minInterval -= 1;
    }

    if (_minInterval2 > 0) {
      _minInterval2 -= 1;
    }

    if (_minInterval3 > 0) {
      _minInterval3 -= 1;
    }
  }

  bool _checkIsHeadDown() {


    if (DetectStatus.initialPitch - _nowPitch > _slouchTiltThreshold[DetectStatus.sSensitivity]) {




      // print('head down');

      return true;
    } else {
      return false;
    }
  }

  bool _checkIsTilt() {
    if ((DetectStatus.initialRoll - _nowRoll).abs() > 0.35) {
      return true;
    } else {
      return false;
    }
  }


  bool _checkIsForward() {
    if (DetectStatus.nowPosition > 0.12) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> changeSound(String filename) async {
    await _notiPlayer.setAsset('assets/${DetectStatus.sSoundFileName}');
  }

  void changeVolume(double volume) {
    _alertVolume = volume;
  }

  // void _checkIsBackward() {
  //   if (_isBackward) {
  //  return true;
  //   } else {
  //     return false;
  //   }
  // }



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
        DetectStatus.lanCode == 'ko' ? '거북목 자세 감지' : 'Bad Posture Detected',
        DetectStatus.lanCode == 'ko' ? '바른 자세를 유지해봅시다!' : 'Let\'s keep a good posture!',
        _details
    );
  }

  @override
  Future<void> play() async {
    isPlaying = true;
    _poseForwardLog['forward'] = {};
    _poseForwardLog['forward'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'START';

    _posePitchLog['pitch'] = {};
    _posePitchLog['pitch'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'START';

    _poseTiltLog['tlt'] = {};
    _poseTiltLog['tilt'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'START';

    // print('start ${DateTime.now().toIso8601String().split('.')[0].substring(0, 19)}');
    await _notiPlayer.setVolume(0);
    _bgAudioPlayer.play();
    _notiPlayer.play();
  }

  Future<void> resume() async {
    print('resume in ah');
    if (!isPlaying) return;
    print('resume inner ah');
    isPlaying = true;
    _subscription = null;
    _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
      handleMotionData(data);
    });
    // await _bgAudioPlayer.setVolume(0.1);
    await _notiPlayer.setVolume(0);
    _bgAudioPlayer.play();
    _notiPlayer.play();
  }

  @override
  Future<void> pause() {
    print('pause');
    isPlaying = false;


    _posePitchLog['pitch'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'END';
    _poseForwardLog['forward'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'END';
    _poseTiltLog['tilt'][DateTime.now().toIso8601String().split('.')[0].substring(0, 19)] = 'END';



    // print('end ${DateTime.now().toIso8601String().split('.')[0].substring(0, 19)}');
    // print(_poseLog);
    if (UserStatus.sIsLogged) {
      HistoryStatus.postMeasuredPoseData(
          _posePitchLog, _poseForwardLog, _poseTiltLog, _poseRawLog);
    }
    // print('poselog $_poseLog');
    _bgAudioPlayer.pause();
    _notiPlayer.pause();
    _minInterval = 0;
    _turtleNeckStartedTimeStamp = 0;
    _posePitchLog = {"pitch": {}};
    _poseForwardLog = {"forward": {}};
    _poseTiltLog = {"tilt": {}};
    _poseRawLog =[{        'timestamp': DateTime.now().toIso8601String(),
      'pitch': 0,
      'roll': 0,
      'position': 0,}];
    return super.pause();
  }

  @override
  Future<void> stop() async {
    _bgAudioPlayer.stop();
    _notiPlayer.pause();
    await super.stop();
  }

  @override
  Future<void> skipToNext() => _bgAudioPlayer.seekToNext();

  @override
  Future<void> skipToPrevious() => _bgAudioPlayer.seekToPrevious();

}

