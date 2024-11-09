import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/service/stretching_timer.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/theme/component/person_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/view/start_position/widget/animated_man.dart';
import 'package:mocksum_flutter/view/start_position/widget/spinning_timer.dart';
import 'package:mocksum_flutter/view/start_position/widget/time_display.dart';
import '../../theme/asset_icon.dart';
import '../../theme/component/button.dart';
import '../../util/localization_string.dart';
import '../../util/responsive.dart';
import 'package:provider/provider.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:wheel_picker/wheel_picker.dart';


class StartPosition extends StatefulWidget {
  final void Function(bool, int)? onStart;

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

  int _detectionMin = 10;
  bool _useTimeLimit = true;

  @override
  void initState() {
    _started = false;

    Future.delayed(Duration.zero, () {
      _detectionMin = min(10, ((3600-Provider.of<GlobalTimer>(context, listen: false).useSec)/60).ceil());
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
        if (detectStatus.detectAvailable) {
          detectStatus.startDetecting();
          detectStatus.setUseTimeLimit(_useTimeLimit, _useTimeLimit ? _detectionMin : null);
          Provider.of<GlobalTimer>(context, listen: false).startTimer();
          Provider.of<StretchingTimer>(context, listen: false).setTimer(); // 스트레칭 타이머 동작
          widget.onStart!(_useTimeLimit, _detectionMin);
        } else {
          showSnackbar(LS.tr('home_view.airpods_disconnect_detection_end'));
        }
        Navigator.pop(context);
      }
    });
  }

  void _showMinWheelPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) {
        Responsive res = Responsive(context);
        return Container(
          width: res.deviceWidth,
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F7),
            borderRadius: BorderRadius.circular(30),
          ),
          child: WheelPicker(
            itemCount: ((3600-Provider.of<GlobalTimer>(context, listen: false).useSec)/60).ceil(),
            builder: (context, index) => TextDefault(content: '${index+1}${context.locale.languageCode == 'ko' ? '분' : "'"}', fontSize: 20, isBold: false, fontColor: const Color(0xFFB0B8C6),),
            // selectedIndexColor: Colors.orange,
            looping: false,
            onIndexChanged: (idx) {
              setState(() {
                _detectionMin = idx+1;
              });
            },
            selectedIndexColor: Colors.black
          ),
        );
    });
  }

  void showSnackbar(String msg) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: const Color(0xFFF25959),
                borderRadius: BorderRadius.circular(10)
            ),
            alignment: Alignment.center,
            child: const AssetIcon('close', color: Colors.white, size: 20,),
          ),
          const SizedBox(width: 10,),
          TextDefault(
            content: msg,
            fontSize: 16,
            isBold: false,
            fontColor: Colors.white,
          )
        ],
      ),
      backgroundColor: const Color(0xFF323238),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    UserStatus userStatus = context.read();
    GlobalTimer globalTimer = context.read();

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
                    // crossAxisAlignment: CrossAxisAlignment.,
                    children: [
                      const AnimatedMan(),
                      SizedBox(height: res.percentHeight(2),),
                      SizedBox(
                        width: res.percentWidth(85),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Row(
                                  mainAxisAlignment: context.locale.languageCode == 'ko' ? MainAxisAlignment.start : MainAxisAlignment.end,
                                  textDirection: context.locale.languageCode == 'ko' ? null : ui.TextDirection.rtl,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showMinWheelPicker();
                                      },
                                      child: TimeDisplay(
                                        minute: _detectionMin,
                                        plus: () {
                                          if (!userStatus.isPremium && _detectionMin + 5 > ((3600-globalTimer.useSec)/60).ceil()) {
                                            setState(() {
                                              _detectionMin = ((3600-globalTimer.useSec)/60).ceil();
                                            });
                                            showSnackbar('start_position_view.snackbar_txt'.tr());
                                          } else {
                                            setState(() {
                                              _detectionMin += 5;
                                            });
                                          }
                                        },
                                        minus: () {
                                          if (_detectionMin <= 5) return;
                                          setState(() {
                                            _detectionMin -= 5;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: res.percentWidth(2),),
                                    TextDefault(content: 'start_position_view.detect_txt'.tr(), fontSize: 18, isBold: true),
                                  ],
                                ),
                                _useTimeLimit ? const SizedBox() : Container(
                                  width: res.percentWidth(70),
                                  height: res.percentHeight(5),
                                  color: const Color(0xAAF4F4F7),
                                )
                              ],
                            ),
                            SizedBox(height: res.percentHeight(2),),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _useTimeLimit = !_useTimeLimit;
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: res.percentWidth(5),
                                    height: res.percentWidth(5),
                                    padding: EdgeInsets.all(res.percentWidth(0.5)),
                                    decoration: BoxDecoration(
                                        color: !_useTimeLimit ? const Color(0xFF236EF3) : const Color(0xFFE5E5EB),
                                        borderRadius: BorderRadius.circular(res.percentWidth(3))
                                    ),
                                    child: AssetIcon('check', size: 1, color: !_useTimeLimit ? Colors.white : const Color(0xFF101E32),),
                                  ),
                                  SizedBox(width: res.percentWidth(3),),
                                  TextDefault(content: 'start_position_view.direct_stop'.tr(), fontSize: 16, isBold: false,),
                                ],
                              ),
                            ),
                            SizedBox(height: res.percentHeight(3),),
                            !userStatus.isPremium ?
                            TextDefault(content: '${'start_position_view.today_time'.tr()}: ${((3600-globalTimer.useSec)/60).ceil()}${context.locale.languageCode == 'ko' ? '분' : "'"}', fontSize: 15, isBold: true, fontColor: const Color(0xFF115FE9),)
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      SizedBox(height: res.percentHeight(2),),
                      Button(
                        onPressed: () {
                          if (DetectStatus.sDetectAvailable) {
                            _startTimer();
                          } else {
                            showSnackbar(LS.tr('home_view.airpods_disconnect_detection_end'));
                          }
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
