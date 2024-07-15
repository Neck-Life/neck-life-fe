import 'dart:async';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocksum_flutter/util/filter/KalmanFilterPosition.dart';
import 'package:mocksum_flutter/util/filter/KalmanFilterVelocity.dart';
import 'package:mocksum_flutter/util/filter/MovementFilter.dart';
import 'util/airpods/Quaternion.dart';
import 'util/responsive.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:provider/provider.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
// import 'package:csv/csv.dart';

import 'dart:math';

class Neck extends StatefulWidget {
  const Neck({super.key});

  @override
  NeckState createState() => NeckState();
}

class NeckState extends State<Neck> with SingleTickerProviderStateMixin {

  // List<List<dynamic>> rows = [];


  late AnimationController _controller;
  double _rotateDeg = 0;
  double _pitch = 0;
  double _pitchTemp = 0;
  double _prevPitch = 0;
  int _sameValueCnt = 0;
  StreamSubscription<DeviceMotionData>? _subscription;
  bool _detectAvailable = false;
  int _minAlarmDelay = 0;
  int _stateTurtleNeck = 0;
  final List<double> _turtleThreshold = [0.3, 0.4, 0.5];
  // bool _nowDetecting = false;
  int _initTick = 0;

  // for position calculating
  Quaternion? initialQuaternion;
  final double sampleRate = 1/0.04;
  double lastTimestamp = 0.0;
  List<double> velocities = [0.0];
  List<double> positions = [0.0];
  List<double> accelerations = [0.0];
  List<double> rotationRatesX = [0.0];
  List<double> rotationRatesY = [0.0];
  List<double> rotationRatesZ = [0.0];
  List<double> roll = [0.0];
  List<double> pitch = [0.0];
  List<double> yaw = [0.0];
  List<double> quaternionY = [0.0];
  MovementFilter movementFilter = MovementFilter(5);
  double neckPosition = 0;
  double neckPositionUI = 0;

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
    if (DetectStatus.initialPitch - _pitch > _turtleThreshold[DetectStatus.sSensitivity]) {
      return true;
    } else {
      return false;
    }
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
    double deltaTime = velocities.length==1 ? 0 : currentTime - lastTimestamp;
    lastTimestamp = currentTime;

    double currentAccelY = data.userAcceleration.y.toDouble() * cos(RotationAngle);

    // print(data.attitude.quaternion.y);

    // print(" data rationRate: ${data.rotationRate.x} ${data.rotationRate.y} ${data.rotationRate.z} ");
    if(data.rotationRate.x.abs()-rotationRatesX.last.abs()
        + data.rotationRate.y.abs() -rotationRatesY.last.abs()
        + data.rotationRate.z.abs() -rotationRatesZ.last.abs() > 0.0000000000001) {

      currentAccelY =0;
    }
    // if(currentAccelY.abs() < 0.01) currentAccelY = 0.0;

    var kf_v = KalmanfilterVelocity();

    kf_v.setDt(deltaTime);
    kf_v.iterate([currentAccelY]);
    var estimate_vel = kf_v.x_esti[0];

    double velocityY = estimate_vel  ;

    var kf_p = KalmanfilterPosition();

    kf_p.setX([positions.last, 0]);

    _initTick++;
    if(_initTick >=3000){
      kf_p.setX([0, 0]);
    }
    if(_initTick ==3005) {
      _initTick=0;
    }

    kf_p.setDt(deltaTime);
    kf_p.iterate([velocityY]);
    var estimate_pos = kf_p.x_esti[0];


    // 탐지로직
    // 여기에 이동평균 씌워서 얼마나 이동했는지?
    var update = movementFilter.update(estimate_pos);

    if(update> 0.001){
      print("목이 앞으로 이동");
      // print(update);
      neckPosition+=update;
      movementFilter.clear();
    }else if(update < -0.0001){
      print("목이 뒤로 이동");
      // print(update);
      neckPosition+=update;
      movementFilter.clear();
    }


    print("목 위치 : $neckPosition");

    // Store the position for visualization
    if (velocities.length > 5) { // Keep last 100 data points
      velocities.removeAt(0);
      // positions.clear();
      positions.removeAt(0);
      accelerations.removeAt(0);
      rotationRatesX.removeAt(0);
      rotationRatesY.removeAt(0);
      rotationRatesZ.removeAt(0);

      quaternionY.remove(0);


    }
    accelerations.add(currentAccelY);
    velocities.add(velocityY);
    positions.add(estimate_pos);
    rotationRatesX.add(data.rotationRate.x.toDouble());
    rotationRatesY.add(data.rotationRate.y.toDouble());
    rotationRatesZ.add(data.rotationRate.z.toDouble());

    // List<dynamic> row = [];
    // row.add(currentAccelY);
    // row.add(velocityY);
    // row.add(neckPosition);
    // rows.add(row);
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
        DetectStatus.nowPitch = _pitchTemp;
        // print(DetectStatus.initialPitch);
        // print(_pitchTemp);
        // print('$_isTurtle $_minAlarmDelay ${DetectStatus.sNowDetecting}');
        if (_minAlarmDelay > 0) {
          _minAlarmDelay -= 1;
        }
        print(_stateTurtleNeck);
        if (DetectStatus.sNowDetecting && _isTurtle && _minAlarmDelay == 0 && DateTime.now().millisecondsSinceEpoch - _stateTurtleNeck >= DetectStatus.sAlarmGap*1000) {
          _showPushAlarm();
          // Provider.of<DetectStatus>(context, listen: false)
          _isTurtle = false;
          _minAlarmDelay = 600;
          _stateTurtleNeck = 0;
        }
      }, onError: (error) {
        print("error");
        _detectAvailable = false;
      });
    });
  }

  void _stopListening() {
    // print('asdf');
    // String csv = const ListToCsvConverter().convert(rows);
    //
    // File f = File('est.csv');
    // f.writeAsString(csv);

    setState(() {
      _subscription?.cancel();
      // _positions.clear();
      // _positions.add(0.0);
      // _lastTimestamp = 0.0;
      _subscription = null;
    });
  }

  @override
  void initState() {
    super.initState();
    // List<dynamic> row = [];
    // row.add("acc");
    // row.add("vel");
    // row.add("pos");
    // rows.add(row);

    _startAirpodSensing();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _pitch = _pitchTemp;
          _isTurtle = _checkIsNowTurtle();
          if (_isTurtle && _stateTurtleNeck == 0 && DetectStatus.sNowDetecting) {
            _stateTurtleNeck = DateTime.now().millisecondsSinceEpoch;
          }
          if (!_isTurtle) {
            _stateTurtleNeck = 0;
          }
          // neckPositionUI = neckPosition*5;
          _rotateDeg = positions.last*50 > 0.5 ? 0.5 : positions.last*50;
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
                      top: responsive.percentWidth(85)*0.15+sin(_rotateDeg).abs()*responsive.percentWidth(85)*0.15,
                      left: responsive.percentWidth(85)*0.5-responsive.percentWidth(85)*0.03+cos_f(_rotateDeg, responsive.percentWidth(5)),
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