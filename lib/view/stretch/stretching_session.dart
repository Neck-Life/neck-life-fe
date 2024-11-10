import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/view/home/widgets/app_bar.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/view/stretch/stretching_completed.dart';
import 'package:mocksum_flutter/view/stretch/subpages/strethcing_alarm_setting.dart';
import 'package:mocksum_flutter/view/stretch/widgets/Stretching_animate_man.dart';
import 'package:mocksum_flutter/view/stretch/widgets/blurred_man.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_exit_modal.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_neck.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_progressBar.dart';
import 'package:provider/provider.dart';

import '../../service/stretching_timer.dart';
import '../../util/localization_string.dart';
import '../../util/responsive.dart';
import '../../util/time_convert.dart';
import 'data/stretching_data.dart';
import 'models/stretching_action.dart';

const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails('temp1', 'asdf'),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    )
);

Future<void> _showPushAlarm(String title, String body) async {
  FlutterLocalNotificationsPlugin localNotification =
  FlutterLocalNotificationsPlugin();
  // await localNotification.cancel(11); //목 돌리기 운동처럼 동작시간이 짧으면 알림이 씹힘 ㅠ
  await localNotification.show(11, // 푸쉬알림고유ID
      title,
      body,
      _details
  );
}
class StretchingSession extends StatefulWidget {
  final bool? shouldResetTimer; // 스트레칭 세션 종료,이탈시 타이머 재설정하는가?
  final StretchingGroup? preSelectedStretchingGroup;

  const StretchingSession({
    super.key,
    this.preSelectedStretchingGroup, this.shouldResetTimer
  });

  @override
  State<StatefulWidget> createState() => _StretchingSessionState();
}

class _StretchingSessionState extends State<StretchingSession> {
  final FlutterTts _flutterTts = FlutterTts();
  double pitch = DetectStatus.nowPitch;
  double roll = DetectStatus.nowRoll;
  double yaw = DetectStatus.nowYaw;

  int currentStepIndex = 0;
  Timer? _timer, _updateDataTimer;
  double _elapsedTime = 0;
  bool _isActive = true;
  StretchingGroup? selectedStretchingGroup;

  String get guideText => selectedStretchingGroup!.actions[currentStepIndex].name;
  String get stretchingGroupName => selectedStretchingGroup!.groupName;

  StretchingProgressBar stretchingProgressBar = StretchingProgressBar(key: GlobalKey(),);

  bool isStretchingProcess = false;

  final amplitudeManager = AmplitudeEventManager();

  @override
  void initState() {
    super.initState();
    StretchingTimer.isStretchingMode = true;

    amplitudeManager.actionEvent('stretching', 'doStretching');
    _initializeTts();
    // List stretchingList = StretchingData.init(DetectStatus.lanCode);
    selectedStretchingGroup = widget.preSelectedStretchingGroup ?? Provider.of<StretchingTimer>(context, listen: false).getSelectedStretching();
    if(DetectStatus.lanCode == 'ko') {
      _speak("${(selectedStretchingGroup!.actions[currentStepIndex].duration).toInt()}초간 $guideText");
    } else {
      //영어
      _speak("${guideText} for ${(selectedStretchingGroup!.actions[currentStepIndex].duration).toInt()} seconds");
    }


    // 1초마다 상태를 확인하고 강제로 setState()를 호출해 UI를 갱신
    _updateDataTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() {
        pitch = DetectStatus.nowPitch - DetectStatus.initialPitch;
        roll = DetectStatus.nowRoll - DetectStatus.initialRoll;
        yaw = DetectStatus.nowYaw - DetectStatus.initialYaw;
        checkStretchCompletion(pitch, roll, yaw);
        // print([pitch, roll, yaw]);
      });
    });
  }

  @override
  void dispose() {
    _updateDataTimer?.cancel();

    super.dispose();
  }

  // TTS 초기화 메서드
  void _initializeTts() async {
    if(DetectStatus.lanCode == 'ko'){
      await _flutterTts.setLanguage("ko-KR"); // 언어 설정
    }else{
      await _flutterTts.setLanguage("en-US"); // 언어 설정
    }
    await _flutterTts.setSpeechRate(0.5); // 말하기 속도 설정
    await _flutterTts.setVolume(1.0); // 볼륨 설정
    await _flutterTts.setPitch(1.0); // 음성 피치 설정
  }

  // 나레이션 시작
  Future _speak(String text) async {
    await _flutterTts.awaitSpeakCompletion(true); // 음성이 끝날 때까지 대기 설정
    await _flutterTts.speak(text);
  }

  // 나레이션 멈추기
  Future _stop() async {
    await _flutterTts.stop();
  }

  void startTimer(double duration) {
    _timer = Timer.periodic(const Duration(milliseconds: 050), (timer) {
      if(isStretchingProcess){
        setState(() {
          _elapsedTime += 0.050;
          // print('타이머!');
        });
      }


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
    final currentAction = selectedStretchingGroup!.actions[currentStepIndex];
    return currentAction.isCompleted(pitch, roll, yaw);
  }

  void checkStretchCompletion(double pitch, double roll, double yaw) {
    final currentAction = selectedStretchingGroup!.actions[currentStepIndex];
    double value=0;
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
      default:
        // value = _elapsedTime / currentAction.duration;
    }

    bool isThresholdReached = currentAction.isCompleted(pitch,roll,yaw);

    double duration = currentAction.duration;
    stretchingProgressBar.updateProgress(value, isThresholdReached, _elapsedTime, duration);


    if (_isActive && isStepCompleted(pitch, roll, yaw)) {
      isStretchingProcess = true;
      if (_timer == null || !_timer!.isActive) {
        startTimer(currentAction.duration); // 동작별 duration을 사용
      }
    } else {
      isStretchingProcess = false;
      // _resetTimer();
    }
  }

  void _goToNextStep() {

    if (currentStepIndex < selectedStretchingGroup!.actions.length - 1) {
      _showPushAlarm(
          LS.tr('stretching.stretching_session.good_job_next_step_title'),
          LS.tr('stretching.stretching_session.good_job_next_step_body')
      );
      setState(() {
        currentStepIndex += 1;
        final duration = selectedStretchingGroup!.actions[currentStepIndex].duration;
        final message = DetectStatus.lanCode == 'ko'
            ? (duration < 1 ? "$guideText" : "${duration.toInt()}초간 $guideText")
            : (duration < 1 ? "$guideText" : "$guideText for ${duration.toInt()} seconds");
        //1초미만 동작은 시간 생략
        _speak(message);

      });
    } else {
      _showPushAlarm(
          LS.tr('stretching.stretching_session.congratulations_all_done_title'),
          LS.tr('stretching.stretching_session.congratulations_all_done_body')
      );

      if(DetectStatus.lanCode =='ko') {
        _speak("모든 스트레칭이 끝났습니다.");
      } else {
        _speak("All stretches completed.");
      }

      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    _toggleStretchingWidget(); // 스트레칭 비활성화
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => StretchingCompletedScreen(shouldResetTimer: widget.shouldResetTimer,)),
    );
  }

  void _toggleStretchingWidget() {
    setState(() {
      _isActive = !_isActive;
      currentStepIndex = 0;
    });
  }

  void _exitStretching() {
    // _toggleStretchingWidget(); // 스트레칭 비활성화
    showStretchingExitModal(context, widget.shouldResetTimer);
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    GlobalTimer globalTimer = context.watch();

    final currentAction = selectedStretchingGroup!.actions[currentStepIndex]; // 동작 정보 가져오기

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                // height: res.percentWidth(85),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E2F9),
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.only(bottom: res.percentHeight(4)),
                child: Column(
                  children: [
                    Container(
                        width: res.percentWidth(70),
                        padding: EdgeInsets.only(top: res.percentWidth(7.5)),
                        child: Text(
                          // "10초간 고개를\n하늘을 향해 젖혀주세요",
                          guideText,
                          style: const TextStyle(
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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     const NeckPitch(),
                    //     SizedBox(width: res.percentWidth(5)),
                    //     const NeckRoll(),
                    //   ],
                    // ),
                    currentAction.animationAvailable != null && currentAction.animationAvailable == true ? const StretchingAnimateMan() : (currentAction.progressVariable == ProgressVariable.none ? const BlurredMan(isBlurred: false,) : const BlurredMan(isBlurred: true,)),
                    SizedBox(
                      height: res.percentHeight(2),
                    ),
                    GestureDetector(
                      onTap: (){
                        // print("exit터치 감지");
                        _exitStretching();
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
                              content: TimeConvert.sec2TimeFormat(globalTimer.useSec),
                              fontSize: 16,
                              isBold: true,
                              fontColor: const Color(0xFF236EF3),
                            ),
                            TextDefault(
                              content: LS.tr('stretching.stretching_session.skip_stretching'),
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
      ),
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