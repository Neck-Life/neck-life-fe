import 'package:flutter/material.dart';
import 'package:mocksum_flutter/view/stretch/stretching_completed.dart';
import 'package:mocksum_flutter/view/stretch/stretching_session.dart';
import 'package:mocksum_flutter/view/stretch/stretching_session_dev.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_complete_modal.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_start_modal.dart';

import '../../service/stretching_timer.dart';

/**
 * <--스트레칭괸련 테스트환경-->
 * TODO : 1. 스트레칭 음성,진동 추가
 * TODO : 2. 스트레칭 종료 후 다시 스트레칭 타이머 작동
 * TODO : 3. 자세탐지 도중 타이머(nn분 간격 스트레칭 알림) -> 백그라운드상에서 모달창 생기면, 타이머가 안돌아가는 이슈
 * TODO : 4. 스트레칭 옵션 설정(주기 타이머, 스트레칭종목 등) 기능 추가 -> 프로바이더 고려
 * TODO : 5. 스트레칭 백그라운드 Push Notification. (기존 소리,진동과는 차별되도록)
 * TODO : 6. 목표에 스트레칭 추가 및 목표달성 이벤트 추가
 * TODO : 7. 정면 캐릭터 사진 적용
 * TODO : 8. 앰플리튜드 추적 코드 추가
 */
StretchingTimer stretchingTimer = StretchingTimer();

class Stretching extends StatefulWidget {
  const Stretching({Key? key}) : super(key: key);

  @override
  _StretchingState createState() => _StretchingState();
}

class _StretchingState extends State<Stretching> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stretching Guide'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showStretchingStartModal(context);
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StretchingSessionDev()),
              );
            },
            child: const Text('스트레칭 세션(dev) 센서기반'),
          ),
          ElevatedButton(
            onPressed: () {
              stretchingTimer.setTimer(context);
            },
            child: const Text('스트레칭타이머 설정'),
          ),
        ],
      ),
    );
  }
}
