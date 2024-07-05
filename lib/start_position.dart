import 'dart:async';

import 'package:flutter/material.dart';
import 'util/responsive.dart';
import 'package:provider/provider.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
import 'package:mocksum_flutter/util/Quaternion.dart';


class StartPosition extends StatefulWidget {
  const StartPosition({super.key});
  @override
  StartPositionState createState() => StartPositionState();
}

class StartPositionState extends State<StartPosition> {
  bool _timerRunning = false;
  int _lastTime = 5;
  Timer? _timer;

  void _startTimer(DetectStatus detectStatus, BuildContext context) {
    _timerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _lastTime--;
      });
      if (_lastTime <= 0) {
        timer.cancel();
        detectStatus.startDetecting();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    DetectStatus detectStatus = Provider.of(context);

    return Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
              child:Column(
                children: [
                  Container(
                      margin: const EdgeInsets.only(top: 70),
                      child: Text(
                        !_timerRunning ? '바른 자세를 5초 동안 \n유지해주세요!' : '측정중입니다..\n',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 0,
                        ),
                      )
                  ),
                  const SizedBox(height: 70),
                  Stack(
                    children: [
                      Container(
                        width: responsive.percentWidth(70),
                        height: responsive.percentWidth(70),
                        decoration: const ShapeDecoration(
                          color: Colors.white,
                          shape: OvalBorder(),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 0),
                              spreadRadius: 1,
                            )
                          ],
                        ),
                      ),
                      Positioned(
                          top: 9,
                          left: 9,
                          child: Container(
                            width: responsive.percentWidth(70)-18,
                            height: responsive.percentWidth(70)-18,
                            decoration: const ShapeDecoration(
                              color: Color(0xFF646464),
                              shape: OvalBorder(),
                            ),
                            child: Center(
                              child: Text(
                                _lastTime.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFEBEBEB),
                                  fontSize: 80,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                ),
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                  const SizedBox(height: 70),
                  Container(
                      height: 35,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF4A4A4A),
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
                      child: Visibility(
                        visible: _timerRunning ? false : true,
                        child: ElevatedButton(
                            onPressed: () {
                              _startTimer(detectStatus, context);
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(responsive.percentWidth(40), 30),
                                backgroundColor: const Color(0xFF4A4A4A),
                                surfaceTintColor: const Color(0xFF4A4A4A),
                                shadowColor: const Color(0x19000000)
                            ),
                            child: const Text(
                              '기준 자세 측정',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                            )
                        ),
                      )
                  )
                ],
              )
          ),
        )
    );
  }
}
