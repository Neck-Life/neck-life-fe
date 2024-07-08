import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'util/responsive.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:provider/provider.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
import 'package:mocksum_flutter/util/Quaternion.dart';
import 'dart:math';

class Neck extends StatefulWidget {
  const Neck({super.key});

  @override
  NeckState createState() => NeckState();
}

class NeckState extends State<Neck> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  double _rotateDeg = 0;
  double _pitch = 0;
  double _pitchTemp = 0;
  double _prevPitch = 0;
  int _sameValueCnt = 0;
  StreamSubscription<DeviceMotionData>? _subscription;
  bool _detectAvailable = false;
  int _minAlarmDelay = 0;
  // bool _nowDetecting = false;

  // for position calculating
  Quaternion? _initialQuaternion;
  final double _sampleRate = 1/0.04;
  double _lastTimestamp = 0.0;
  List<double> _positions = [0.0];
  double _nowPosition = 0;

  final NotificationDetails _details = const NotificationDetails(
      android: AndroidNotificationDetails('temp1', 'asdf'),
      iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true
      )
  );

  // temporary code for ui test
  bool _isTurtle = false;

  bool _checkIsNowTurtle() {
    if (_pitch < -0.3) {
      return true;
    } else {
      return false;
    }
  }

  void _processSensorData(DeviceMotionData data) {
    // 초기 자세 측정
    _initialQuaternion ??= Quaternion(data.attitude.quaternion.w.toDouble(),
      data.attitude.quaternion.x.toDouble(),
      data.attitude.quaternion.y.toDouble(),
      data.attitude.quaternion.z.toDouble(),
    );

    var nowQuaternion = Quaternion(data.attitude.quaternion.w.toDouble(),
      data.attitude.quaternion.x.toDouble(),
      data.attitude.quaternion.y.toDouble(),
      data.attitude.quaternion.z.toDouble(),
    );

    var RotationAngle = calculateRotationAngle(_initialQuaternion!,nowQuaternion);

    double currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    double deltaTime = _positions.length==1 ? 0 : currentTime - _lastTimestamp;
    _lastTimestamp = currentTime;

    double currentAccelY = data.userAcceleration.y.toDouble();

    if(currentAccelY.abs()*cos(RotationAngle) < 0.1) {
      currentAccelY = 0;
    }
    double velocityY = _positions.last + currentAccelY * deltaTime * cos(RotationAngle);
    // Store the position for visualization
    if (_positions.length > 100) { // Keep last 100 data points
      _positions.removeAt(0);
    }
    _positions.add(velocityY);

    setState(() {
      _nowPosition = velocityY;
    });
  }

  Future<void> _showPushAlarm() async {
    FlutterLocalNotificationsPlugin localNotification =
    FlutterLocalNotificationsPlugin();

    await localNotification.show(0,
        '거북목 자세 감지',
        '바른 자세를 유지해봅시다!',
        _details
    );
  }

  void _startAirpodSensing() {
    // DetectStatus ds = Provider.of(context);
    // if (!ds.nowDetecting) return;
    setState(() {
      _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
        _detectAvailable = true;
        // _processSensorData(data);
        _pitchTemp = data.toJson()['pitch'];
        print(_pitchTemp);
        print('$_isTurtle $_minAlarmDelay ${DetectStatus.sNowDetecting}');
        if (_minAlarmDelay > 0) {
          _minAlarmDelay -= 1;
        }
        if (DetectStatus.sNowDetecting && _pitchTemp < -0.3 && _minAlarmDelay == 0) {
          _showPushAlarm();
          // Provider.of<DetectStatus>(context, listen: false)
          _isTurtle = false;
          _minAlarmDelay = 600;
        }
      }, onError: (error) {
        print("error");
        _detectAvailable = false;
      });
    });
  }

  void _stopListening() {
    setState(() {
      _subscription?.cancel();
      _positions.clear();
      _positions.add(0.0);
      _lastTimestamp = 0.0;
      _subscription = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _startAirpodSensing();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _pitch = _pitchTemp;
          _isTurtle = _checkIsNowTurtle();
          // _rotateDeg = -_nowPosition*10;
          // print("now pitch: $_pitch");
        });
        _controller.value = 0;
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopListening();
    super.dispose();
  }

  double cos_f(double d, double offset) {
    return d >= 0 ? (1-cos(d))*(offset*(1+d*5)) : (cos(d)-1)*offset*(1-5*(1/d));
  }

  void _checkDetectAvailable() {
    Future.delayed(Duration.zero, () {
      // _nowDetecting = Provider.of<DetectStatus>(context, listen: false).nowDetecting;
      // // print('$_isTurtle $_minAlarmDelay $_nowDetecting');
      if (_prevPitch != 0 && _prevPitch == _pitch) {
        _sameValueCnt += 1;
        if (_sameValueCnt > 30) {
          Provider.of<DetectStatus>(context, listen: false).disavailableDetect();
          _prevPitch = 0;
          _pitch = 0;
          _detectAvailable = false;
          _sameValueCnt = 0;
        }
      }
      if (_prevPitch != 0 && _prevPitch != _pitch) {
        _sameValueCnt = 0;
      }
      if (_detectAvailable) {
        Provider.of<DetectStatus>(context, listen: false).availableDetect();
      }
      _prevPitch = _pitch;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    _checkDetectAvailable();

    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
              width: responsive.percentWidth(85),
              height: responsive.percentWidth(85)*0.8,
              margin: const EdgeInsets.only(top: 20),
              decoration: ShapeDecoration(
                color: _isTurtle ? const Color(0xFFFFC2B9) : const Color(0xFFBBFFB9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 4,
                    offset: Offset(2, 2),
                    spreadRadius: 3,
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 2,
                    height: responsive.percentWidth(85)*0.7,
                    decoration: const BoxDecoration(
                        color: Color(0xFF000000)
                    ),
                  ),
                  Container(
                    width: responsive.percentWidth(20),
                    height: responsive.percentWidth(85)*0.3,
                    margin: EdgeInsets.only(top: responsive.percentWidth(85)*0.4),
                    decoration: const BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                    ),
                  ),
                  Positioned(
                    top: responsive.percentWidth(85)*0.28,
                    child: Transform.rotate(
                      angle: _rotateDeg, // **calculate based on head pos
                      origin: Offset(0, responsive.percentWidth(85)*0.1),
                      child: Container(
                        width: responsive.percentWidth(5),
                        height: responsive.percentWidth(85)*0.2,
                        decoration: const BoxDecoration(
                            color: Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      top: responsive.percentWidth(85)*0.15+sin(-_nowPosition*100).abs()*responsive.percentWidth(85)*0.15,
                      left: responsive.percentWidth(85)*0.5-responsive.percentWidth(85)*0.03+cos_f(-_nowPosition*100, responsive.percentWidth(5)),
                      child: Transform.rotate(
                          angle: -_pitch, // **calculated by pitch
                          origin: Offset(-responsive.percentWidth(15)*0.5+responsive.percentWidth(5)/2, responsive.percentWidth(15)*0.5-responsive.percentWidth(5)/2),
                          child: Container(
                            width: responsive.percentWidth(15),
                            height: responsive.percentWidth(15),
                            decoration: const BoxDecoration(
                                color: Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10))
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: responsive.percentWidth(15)*0.3,
                                  height: 5,
                                  margin: EdgeInsets.only(top: responsive.percentWidth(15)*0.2, left: responsive.percentWidth(15)*0.7),
                                  decoration: const BoxDecoration(
                                      color: Colors.black
                                  ),
                                ),
                                Container(
                                  width: responsive.percentWidth(15)*0.1,
                                  height: 5,
                                  margin: EdgeInsets.only(top: responsive.percentWidth(15)*0.7, left: responsive.percentWidth(15)*0.9),
                                  decoration: const BoxDecoration(
                                      color: Colors.black
                                  ),
                                )
                              ],
                            ),
                          )
                      )
                  )
                ],
              )
          );
        });
  }
}