import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mocksum_flutter/view/stretch/stretching_completed.dart';
import 'package:mocksum_flutter/view/stretch/stretching_session.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_complete_modal.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_start_modal.dart';
import 'package:provider/provider.dart';

import '../../../service/stretching_timer.dart';
import '../../../util/responsive.dart';

class StretchingDevEnv extends StatefulWidget {
  const StretchingDevEnv({Key? key}) : super(key: key);

  @override
  _StretchingDevEnvState createState() => _StretchingDevEnvState();
}

class _StretchingDevEnvState extends State<StretchingDevEnv> {
  int _anchorIdx = 0;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  // TTS 초기화 메서드
  void _initializeTts() async {
      await _flutterTts.setLanguage("ko-KR"); // 언어 설정
      await _flutterTts.setSpeechRate(0.5); // 말하기 속도 설정
      await _flutterTts.setVolume(1.0); // 볼륨 설정
      await _flutterTts.setPitch(1.0); // 음성 피치 설정
  }

  // 나레이션 시작
  Future speak(String text) async {
    await _flutterTts.awaitSpeakCompletion(true); // 음성이 끝날 때까지 대기 설정
    await _flutterTts.speak(text);
  }

  // 나레이션 멈추기
  Future _stop() async {
    await _flutterTts.stop();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    final stretchingTimer = Provider.of<StretchingTimer>(context);
    Responsive res = Responsive(context);
    return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showStretchingStartModal();
            },
            child: Text("스트레칭 시작 모달창 띄우기"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StretchingCompletedScreen()),
              );
            },
            child: const Text('스트레칭 완료'),
          ),
          ElevatedButton(
            onPressed: () {
              showStretchingCompleteModal(context);
            },
            child: Text("스트레칭 완료 모달창 띄우기"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StretchingSession()),
              );
            },
            child: const Text('스트레칭 세션'),
          ),
          ElevatedButton(
            onPressed: () {
              stretchingTimer.setTimer();
            },
            child: const Text('스트레칭타이머 설정'),
          ),
          ElevatedButton(
            onPressed: () => speak("7초간 하늘을 바라봐주세요"),
            child: Text("Start Narration"),
          )
        ],
      );
  }
}
