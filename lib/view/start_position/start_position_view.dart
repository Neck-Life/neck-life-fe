import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/theme/component/person_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/view/start_position/widget/animated_man.dart';
import 'package:mocksum_flutter/view/start_position/widget/spinning_timer.dart';
import '../../theme/component/button.dart';
import '../../util/localization_string.dart';
import '../../util/responsive.dart';
import 'package:provider/provider.dart';
import 'package:mocksum_flutter/service/status_provider.dart';


class StartPosition extends StatefulWidget {
  final void Function()? onStart;

  const StartPosition({super.key, this.onStart});
  @override
  StartPositionState createState() => StartPositionState();
}

class StartPositionState extends State<StartPosition> {
  bool _timerRunning = false;
  int _lastTime = 5;
  double _avgInitPitch = 0;
  double _avgInitRoll = 0;
  double _avgInitYaw = 0;
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    _started = false;

    Future.delayed(Duration.zero, () {
      // _startTimer();
    });
    super.initState();
  }

  void _startTimer() {
    setState(() {
      _started = true;
    });
    DetectStatus detectStatus = Provider.of<DetectStatus>(context, listen: false);
    _timerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _lastTime--;
      });
      if (_lastTime <= 3) {
        _avgInitPitch += DetectStatus.nowPitch;
        _avgInitRoll += DetectStatus.nowRoll;
        _avgInitYaw += DetectStatus.nowYaw;
      }
      if (_lastTime <= 0) {

        timer.cancel();
        DetectStatus.initialPitch = _avgInitPitch / 3;
        DetectStatus.initialRoll = _avgInitRoll / 3;
        DetectStatus.initialYaw = _avgInitYaw / 3;
        detectStatus.startDetecting();
        Provider.of<GlobalTimer>(context, listen: false).startTimer();
        widget.onStart!();
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
                      child:  TextDefault(
                        content: LS.tr('start_position_view.explain_txt'),
                        fontSize: 28,
                        isBold: true,
                      )
                  ),
                  SizedBox(height: res.percentHeight(2),),
                  TextDefault(
                    content: _started ? LS.tr('start_position_view.measuring_txt') : LS.tr('start_position_view.guide_txt'),
                    fontSize: 16,
                    isBold: false,
                    fontColor: const Color(0xFF115FE9),
                  ),
                  const SizedBox(height: 70),
                  !_started ? Column(
                    children: [
                      const AnimatedMan(),
                      SizedBox(height: res.percentHeight(2),),
                      Button(
                        onPressed: () {
                          _startTimer();
                        },
                        text: 'start_position_view.start'.tr(),
                        backgroundColor: const Color(0xFF236EF3),
                        color: Colors.white,
                        width: res.percentWidth(85),
                        padding: res.percentWidth(4),
                      )
                    ],
                  ) : SpinningTimer(lastTime: _lastTime)
                ],
              ),
            ),
          )
      ),
    );
  }
}
