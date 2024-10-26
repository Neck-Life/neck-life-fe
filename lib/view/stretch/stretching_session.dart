import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/view/home/widgets/app_bar.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/view/stretch/stretching_completed.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_progressBar.dart';
import 'package:provider/provider.dart';

import '../../util/responsive.dart';
import 'data/stretching_data.dart';
import 'models/stretching_action.dart';

/**
 * TODO : 하단 프로그레스바 위젯 생성
 * TODO : 스트레칭 데이터 기반 처리 마이그레이션
 * TODO : 자세탐지 도중 타이머(nn분 간격 스트레칭 알림)
 * */
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
        stretchingProgressBar.updateProgress(pitch);
        print(stretchingProgressBar.progress);
      });
    });
  }

  @override
  void dispose() {
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
          StretchingTitleWidget(text: "스트레칭 시간입니다."),
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
                      child: const Text(
                        "10초간 고개를\n하늘을 향해 젖혀주세요",
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



/**
 * 캐릭터 모델
 * Pitch, roll버전
 * */
class NeckModel extends StatefulWidget {
  const NeckModel({Key? key}) : super(key: key);

  @override
  NeckModelState createState() => NeckModelState();
}

class NeckModelState extends State<NeckModel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double degree = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50))
      ..addListener(() {
        setState(() {
          updateAnimationValues(); // 자식 클래스에서 정의
        });
      })
      ..repeat();
  }

  // 자식 클래스에서 이 메서드를 오버라이드하여 각도 값 업데이트
  void updateAnimationValues() {}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return Container(
      width: res.percentWidth(35),
      height: res.percentWidth(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(res.percentWidth(25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(res.percentWidth(25)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: res.percentHeight(7.5),
              child: Container(
                width: res.percentWidth(5.5),
                height: res.percentWidth(85) * 0.3,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB59E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
            Positioned(
              top: res.percentHeight(12),
              left: res.percentWidth(6),
              child: SizedBox(
                width: res.percentWidth(22),
                child: Image.asset(
                  'assets/body.png',
                  width: res.percentWidth(30),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
                top: res.percentWidth(30) * 0.15,
                left: res.percentWidth(20) * 0.5 - res.percentWidth(20) * 0.03,
                child: Transform.rotate(
                    angle: degree, // **calculated by pitch
                    origin: Offset(
                        -res.percentWidth(25) * 0.5 + res.percentWidth(10),
                        res.percentWidth(25) * 0.5 - res.percentWidth(5)),
                    child: SizedBox(
                        width: res.percentWidth(17.5),
                        height: res.percentWidth(17.5),
                        child: Image.asset(
                          "assets/head.png",
                          width: res.percentWidth(25),
                          height: res.percentWidth(25),
                          fit: BoxFit.contain,
                        )))),
          ],
        ),
      ),
    );
  }
}

class NeckPitch extends NeckModel {
  const NeckPitch({Key? key}) : super(key: key);

  @override
  NeckPitchState createState() => NeckPitchState();
}

class NeckPitchState extends NeckModelState {
  @override
  void updateAnimationValues() {
    degree = -DetectStatus.nowPitch; // Pitch 값을 업데이트
  }
}

class NeckRoll extends NeckModel {
  const NeckRoll({Key? key}) : super(key: key);

  @override
  NeckRollState createState() => NeckRollState();
}

class NeckRollState extends NeckModelState {
  @override
  void updateAnimationValues() {
    degree = DetectStatus.nowRoll; // Pitch 값을 업데이트
  }
}
