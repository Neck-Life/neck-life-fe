import 'dart:async';

import 'package:flutter/material.dart';
import 'util/responsive.dart';
import 'package:flutter_airpods/flutter_airpods.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:provider/provider.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
import 'dart:math';

class Neck extends StatefulWidget {
  final double rotateDeg;
  const Neck({super.key, required this.rotateDeg});

  @override
  NeckState createState() => NeckState();
}

class NeckState extends State<Neck> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  double rotateDeg = 0;
  double _pitch = 0;
  double _pitchTemp = 0;
  double _prevPitch = 0;
  int _sameValueCnt = 0;
  StreamSubscription<DeviceMotionData>? _subscription;
  bool _detectAvailable = false;


  void _startAirpodSensing() {
    // DetectStatus ds = Provider.of(context);
    // if (!ds.nowDetecting) return;
    setState(() {
      _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
        _detectAvailable = true;
        _pitchTemp = data.toJson()['pitch'];
      }, onError: (error) {
        print("error");
        _detectAvailable = false;
      });
    });
  }

  void _stopListening() {
    setState(() {
      _subscription?.cancel();
      _subscription = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _startAirpodSensing();
    rotateDeg = widget.rotateDeg;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _pitch = _pitchTemp;
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

    // _nowTime = DateTime.now().millisecondsSinceEpoch;
    // if (_detectAvailable && _nowTime -_lastSensoredTime > 500) {
    //   detectStatus.disavailableDetect();
    // }
    // if (!_detectAvailable && _nowTime - _lastSensoredTime < 500) {
    //   detectStatus.availableDetect();
    // }
    _checkDetectAvailable();
    rotateDeg = 0;
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
              width: responsive.percentWidth(85),
              height: responsive.percentWidth(85)*0.8,
              margin: const EdgeInsets.only(top: 20),
              decoration: ShapeDecoration(
                color: const Color(0xFFFFE2DD),
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
                      angle: rotateDeg, // **calculate based on head pos
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
                      top: responsive.percentWidth(85)*0.15+sin(rotateDeg).abs()*responsive.percentWidth(85)*0.15,
                      left: responsive.percentWidth(85)*0.5-responsive.percentWidth(85)*0.03+cos_f(rotateDeg, responsive.percentWidth(5)),
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