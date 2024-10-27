import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/view/home/widgets/app_bar.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/view/stretch/stretching_completed.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_neck.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_progressBar.dart';
import 'package:provider/provider.dart';

import '../../util/responsive.dart';
import 'data/stretching_data.dart';
import 'models/stretching_action.dart';

class StretchingSession extends StatefulWidget {
  final StretchingGroup selectedGroup = stretchingGroups[5];

  StretchingSession({super.key});

  @override
  _StretchingSessionState createState() => _StretchingSessionState();
}

class _StretchingSessionState extends State<StretchingSession> {
  double pitch = DetectStatus.nowPitch;
  double roll = DetectStatus.nowRoll;
  double yaw = DetectStatus.nowYaw;

  int currentStepIndex = 0;
  Timer? _timer, _updateDataTimer;
  double _elapsedTime = 0;
  bool _isActive = true;

  String get guideText => widget.selectedGroup.actions[currentStepIndex].name;
  String get stretchingGroupName => widget.selectedGroup.groupName;

  StretchingProgressBar stretchingProgressBar = StretchingProgressBar(key: GlobalKey(),);

  @override
  void initState() {
    super.initState();
    // 1초마다 상태를 확인하고 강제로 setState()를 호출해 UI를 갱신
    _updateDataTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
      setState(() {
        pitch = DetectStatus.nowPitch;
        roll = DetectStatus.nowRoll;
        yaw = DetectStatus.nowYaw;
        checkStretchCompletion(pitch, roll, yaw);
      });
    });
  }

  @override
  void dispose() {
    _updateDataTimer?.cancel();
    super.dispose();
  }
  void startTimer(double duration) {
    _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        _elapsedTime += 0.25;
      });

      if (_elapsedTime >= duration) {
        _goToNextStep();
        _resetTimer();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _elapsedTime = 0;
  }

  bool isStepCompleted(double pitch, double roll, double yaw) {
    final currentAction = widget.selectedGroup.actions[currentStepIndex];
    return currentAction.isCompleted(pitch, roll, yaw);
  }

  void checkStretchCompletion(double pitch, double roll, double yaw) {
    final currentAction = widget.selectedGroup.actions[currentStepIndex];
    double value;
    switch (currentAction.progressVariable) {
      case ProgressVariable.pitch:
        value = pitch;
        break;
      case ProgressVariable.negativePitch:
        value = -pitch;
        break;
      case ProgressVariable.roll:
        value = roll;
        break;
      case ProgressVariable.negativeRoll:
        value = -roll;
        break;
      case ProgressVariable.yaw:
        value = yaw;
        break;
      case ProgressVariable.negativeYaw:
        value = -yaw;
        break;
    }

    bool isThresholdReached = currentAction.isCompleted(pitch,roll,yaw);

    double duration = currentAction.duration;
    stretchingProgressBar.updateProgress(value, isThresholdReached, _elapsedTime, duration);


    if (_isActive && isStepCompleted(pitch, roll, yaw)) {
      if (_timer == null || !_timer!.isActive) {
        startTimer(currentAction.duration); // 동작별 duration을 사용
      }
    } else {
      _resetTimer();
    }
  }

  void _goToNextStep() {
    if (currentStepIndex < widget.selectedGroup.actions.length - 1) {
      setState(() {
        currentStepIndex += 1;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    _toggleStretchingWidget(); // 스트레칭 비활성화
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const StretchingCompletedScreen()),
    );
  }

  void _toggleStretchingWidget() {
    setState(() {
      _isActive = !_isActive;
      currentStepIndex = 0;
    });
  }


  void _showCompletedScreen() {
    // _toggleStretchingWidget(); // 스트레칭 비활성화
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const StretchingCompletedScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    DetectStatus detectStatus = context.watch();
    UserStatus userStatus = context.watch();
    GlobalTimer globalTimer = context.watch();

    final currentAction = widget.selectedGroup.actions[currentStepIndex]; // 동작 정보 가져오기
    final double duration = currentAction.duration; // 동작에 따른 duration 설정

    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60), child: HomeAppBar()),
      body: Center(
          child: Column(
        children: [
          StretchingTitleWidget(
              // text: "스트레칭 시간입니다."
              text: stretchingGroupName
          ),
          Container(
              width: res.percentWidth(90),
              height: res.percentWidth(85),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFD8E2F9),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Container(
                      width: res.percentWidth(70),
                      padding: EdgeInsets.only(top: res.percentWidth(7.5)),
                      child: Text(
                        // "10초간 고개를\n하늘을 향해 젖혀주세요",
                        guideText,
                        style: TextStyle(
                          fontSize: 24, // 폰트 크기
                          fontWeight: FontWeight.bold, // 굵게 설정
                          height: 1.2, // 줄 간격 설정
                        ),
                        textAlign: TextAlign.center,
                        // 정렬은 필요에 따라 설정 (중앙 정렬로 설정)
                        softWrap: true,
                      )),
                  SizedBox(
                    height: res.percentHeight(2.5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const NeckPitch(),
                      SizedBox(width: res.percentWidth(5)),
                      const NeckRoll(),
                    ],
                  ),
                  SizedBox(
                    height: res.percentHeight(2),
                  ),
                  GestureDetector(
                    onTap: (){
                      print("터치 감지");
                      _showCompletedScreen();
                    },
                    child: Container(
                      width: res.percentWidth(80),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                          vertical: res.percentHeight(2),
                          horizontal: res.percentWidth(5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextDefault(
                            content: "시간",
                            fontSize: 16,
                            isBold: true,
                            fontColor: const Color(0xFF236EF3),
                          ),
                          TextDefault(
                            content: "스트레칭 건너뛰기",
                            fontSize: 16,
                            isBold: false,
                            fontColor: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )),
          SizedBox(height: res.percentHeight(5)),
          stretchingProgressBar,
        ],
      )),
    );
  }
}


class StretchingTitleWidget extends StatelessWidget {
  final String text; // 전달받을 텍스트 변수

  StretchingTitleWidget({super.key, required this.text}){}

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive(context).percentWidth(90),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // 패딩 설정
      decoration: BoxDecoration(
        color: Colors.white, // 배경색 설정
        borderRadius: BorderRadius.circular(12.0), // 둥근 모서리 설정
        border: Border.all(color: Colors.grey.shade300, width: 1), // 테두리 설정

      ),
      child: Center(
        child: Text(
          text, // 전달받은 텍스트 사용
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500, // 중간 굵기
            color: Colors.black, // 텍스트 색상
          ),
        ),
      ),
    );
  }
}