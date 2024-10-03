import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/theme/component/person_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import '../../util/responsive.dart';
import 'package:provider/provider.dart';
import 'package:mocksum_flutter/service/status_provider.dart';


class StartPosition extends StatefulWidget {
  const StartPosition({super.key});
  @override
  StartPositionState createState() => StartPositionState();
}

class StartPositionState extends State<StartPosition> {
  bool _timerRunning = false;
  int _lastTime = 5;
  double _avgInitPitch = 0;
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    _started = false;

    Future.delayed(Duration.zero, () {
      _startTimer();
    });
    super.initState();
  }

  void _startTimer() {
    DetectStatus detectStatus = Provider.of<DetectStatus>(context, listen: false);
    _timerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _lastTime--;
      });
      if (_lastTime <= 3) {
        _avgInitPitch += DetectStatus.nowPitch;
      }
      if (_lastTime <= 0) {

        timer.cancel();
        DetectStatus.initialPitch = _avgInitPitch / 3;
        detectStatus.startDetecting();
        Provider.of<GlobalTimer>(context, listen: false).startTimer();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return PopScope(
      canPop: _started ? false : true,
      child: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.only(left: res.percentWidth(7.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: res.percentHeight(9),),
                  const PersonIcon(),
                  Container(
                      margin: const EdgeInsets.only(top: 12.5),
                      child: const TextDefault(
                        content: '바른 자세를 5초 동안\n유지해주세요!',
                        fontSize: 28,
                        isBold: true,
                      )
                  ),
                  SizedBox(height: res.percentHeight(2),),
                  const TextDefault(
                    content: '기준 자세 측정 중',
                    fontSize: 16,
                    isBold: false,
                    fontColor: Color(0xFF115FE9),
                  ),
                  const SizedBox(height: 70),
                  Container(
                    margin: EdgeInsets.only(left: res.percentWidth(17.5)),
                    child: SizedBox(
                      width: res.percentWidth(50),
                      height: res.percentWidth(50),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const CircularProgressIndicator(
                            strokeWidth: 20,
                            backgroundColor: Color(0xFFE2E2E2),
                            color: Color(0xFF236EF3),
                          ),
                          Center(
                            child: ClipRRect(
                              child: Container(
                                width: res.percentWidth(50),
                                height: res.percentWidth(50),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(res.percentWidth(25))
                                ),
                                alignment: Alignment.center,
                                child: TextDefault(
                                    content: _lastTime.toString(),
                                    fontSize: 80,
                                    isBold: false
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
