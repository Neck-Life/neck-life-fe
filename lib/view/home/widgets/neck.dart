import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mocksum_flutter/view/home/widgets/start_button.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import '../../../theme/component/button.dart';
import '../../../util/responsive.dart';
import 'package:provider/provider.dart';
import 'package:mocksum_flutter/service/status_provider.dart';

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
  double _prevPitch = 0;
  int _prevTickCount = 0;
  int _sameValueCnt = 0;
  bool _detectAvailable = false;
  final List<double> _turtleThreshold = [0.3, 0.4, 0.5];


  // temporary code for ui test
  bool _isTurtle = false;


  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 50));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _pitch = DetectStatus.nowPitch;

          if(DetectStatus.isLabMode){
            _rotateDeg = DetectStatus.nowPosition;
            // print(_rotateDeg);

          }else{
            _rotateDeg = 0;
          }

          if (_pitch == 0 || DetectStatus.tickCount == _prevTickCount) {
            _detectAvailable = false;
          } else {
            _detectAvailable = true;
          }

          _isTurtle = _isNowTurtle();
          if (context.read<DetectStatus>().isNowTurtle != _isTurtle) {
            if (_isTurtle) {
              context.read<DetectStatus>().toTurtle();
            } else {
              context.read<DetectStatus>().toNotTurtle();
            }
          }
        });
        _controller.value = 0;
        _controller.forward();
      }
    });
  }

  bool _isNowTurtle() {
    if (DetectStatus.initialPitch - _pitch > _turtleThreshold[DetectStatus.sSensitivity] || DetectStatus.nowPosition >= 0.2) {
      return true;
    } else {
      return false;
    }
  }

  double _cosWithWeight(double d, double offset) {
    return d >= 0 ? (1-cos(d))*(offset*(10*cos(4*d)+d*20)) : (cos(d)-1)*offset-offset/5;
  }

  void _updateDetectAvailable() {
    Future.delayed(Duration.zero, () {
      if (_prevPitch != 0 && _prevPitch == _pitch) {
        _sameValueCnt += 1;
        if (_sameValueCnt > 30) {
          Provider.of<DetectStatus>(context, listen: false).disavailableDetect();
          _prevPitch = 0;
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
      _prevTickCount = DetectStatus.tickCount;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    _updateDetectAvailable();

    // _rotateDeg = 0;

    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: res.percentWidth(45),
            height: res.percentWidth(45),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(res.percentWidth(25))
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(res.percentWidth(25)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Container(
                  //   width: 2,
                  //   height: responsive.percentWidth(85)*0.7,
                  //   decoration: const BoxDecoration(
                  //     color: Color(0xFF000000)
                  //   ),
                  // ),
                  Positioned(
                    top: res.percentHeight(7.5),
                    child: Transform.rotate(
                      angle: _rotateDeg, // **calculate based on head pos
                      origin: Offset(0, -res.percentWidth(1)),
                      child: Container(
                        width: res.percentWidth(5.5),
                        height: res.percentWidth(85)*0.3,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFFB59E),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: res.percentHeight(12),
                    left: res.percentWidth(11),
                    child: SizedBox(
                      width: res.percentWidth(22),
                      // height: res.percentWidth(22.5),
                      // margin: EdgeInsets.only(top: res.percentWidth(85)*0.4),
                      // decoration: const BoxDecoration(
                      //   color: Color(0xFFD9D9D9),
                      //   // borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                      // ),
                      child: Image.asset(
                        'assets/body.png',
                        width: res.percentWidth(30),
                        // height: res.percentWidth(25),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                      top: res.percentWidth(30)*0.15+sin(_rotateDeg).abs()*res.percentWidth(30)*0.15,
                      left: res.percentWidth(30)*0.5-res.percentWidth(30)*0.03+_cosWithWeight(_rotateDeg, res.percentWidth(5)),
                      child: Transform.rotate(
                          angle: -_pitch, // **calculated by pitch
                          origin: Offset(-res.percentWidth(25)*0.5+res.percentWidth(10), res.percentWidth(25)*0.5-res.percentWidth(5)),
                          child: SizedBox(
                              width: res.percentWidth(17.5),
                              height: res.percentWidth(17.5),
                              child: Image.asset(
                                "assets/head.png",
                                width: res.percentWidth(25),
                                height: res.percentWidth(25),
                                fit: BoxFit.contain,
                              )
                          )
                      )
                  ),
                ],
              ),
            ),
          );
        });
  }
}