import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/button.dart';
import 'package:mocksum_flutter/theme/component/person_icon.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/util/time_convert.dart';
import 'package:provider/provider.dart';

import '../../../service/stretching_timer.dart';
import '../../../util/localization_string.dart';
import '../stretching.dart';
import '../stretching_session.dart';

// 모달창을 띄우는 함수

void showStretchingStartModal() {
  BuildContext context = stretchingContext;
  final StretchingTimer stretchingTimer = context.read<StretchingTimer>();
// 플래그 초기화
  StretchingTimer.isStretchingMode = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 모달이 화면 크기에 맞춰 스크롤을 조정할 수 있게 설정
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) => const FractionallySizedBox(
      child: StretchingStartModalSheet(),
    ),
  ).whenComplete(() {
    // scrim 영역 클릭으로 모달이 닫힐 때 stretchingTimer.setTimer() 호출
    if (!StretchingTimer.isStretchingMode) {
      stretchingTimer.setTimer();
    }
  });
}

class StretchingStartModalSheet extends StatefulWidget {

  const StretchingStartModalSheet({
    super.key,
  });

  @override
  _StretchingStartModalSheetState createState() => _StretchingStartModalSheetState();
}

class _StretchingStartModalSheetState extends State<StretchingStartModalSheet> {
  int countdown = 29; // 초기값 29로 설정
  Timer? _timer; // 타이머를 위한 변수
  final _amplitudeManager = AmplitudeEventManager();

  @override
  void initState() {
    super.initState();
    _startCountdown(); // 타이머 시작
    _amplitudeManager.viewEvent('stretching_modal');
  }

  @override
  void dispose() {
    _timer?.cancel(); // 화면에서 벗어날 때 타이머 해제
    super.dispose();
  }

  // 타이머로 1초마다 카운트다운 감소
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--; // 1씩 감소
        });
      } else {
        _timer?.cancel(); // 0이 되면 타이머 정지
        Navigator.pop(context);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    final GlobalTimer globalTimer = context.watch();
    final StretchingTimer stretchingTimer = context.watch();

    return SafeArea( // SafeArea로 감싸서 화면 안전 영역을 고려
      child: Container(
        width: res.percentWidth(90),
        height: res.percentHeight(50),
        margin: EdgeInsets.only(bottom: res.percentHeight(5)),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F7),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(res.percentWidth(5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LS.tr('stretching.start_modal.stretch_prompt', [stretchingTimer.getStretchingInterval()!~/60]),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        LS.tr('stretching.start_modal.detection_time', [TimeConvert.sec2Min(globalTimer.useSec, context.locale.languageCode), stretchingTimer.completedStretchCount]),
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF236EF3),
                        ),
                      ),
                      SizedBox(height: res.percentHeight(2)),
                      Center(
                        child: PersonIcon(size: res.percentWidth(8)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: res.percentWidth(5),
                  top: res.percentWidth(3),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: res.percentWidth(8),
                      height: res.percentWidth(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8991A0),
                        borderRadius: BorderRadius.circular(res.percentWidth(4)),
                      ),
                      alignment: Alignment.center,
                      child: AssetIcon('close', color: Colors.white, size: res.percentWidth(4)),
                    ),
                  ),
                )
              ],
            ),
            const Spacer(),
            // 버튼 부분을 하단에서 약간 더 높게 배치하기 위해 SizedBox 추가
            Padding(
              padding: EdgeInsets.symmetric(horizontal: res.percentWidth(6)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // "안할래요" 버튼
                      Button(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        text: LS.tr('stretching.start_modal.no_stretch', [countdown]),
                        backgroundColor: const Color(0xFF8991A0),
                        color: Colors.white,
                        width: res.percentWidth(38),
                        padding: res.percentWidth(4.5),
                      ),
                      Button(
                        onPressed: () {
                          // 스트레칭 버튼 클릭 시 플래그 설정
                          StretchingTimer.isStretchingMode = true;
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StretchingSession(shouldResetTimer: true,)),
                          );
                        },
                        text: LS.tr('stretching.start_modal.start_stretching'),
                        backgroundColor: const Color(0xFF236EF3),
                        color: Colors.white,
                        width: res.percentWidth(38),
                        padding: res.percentWidth(4.5),
                      ),
                    ],
                  ),
                  SizedBox(height: res.percentHeight(3)), // 하단에서 약간 더 높게 배치하기 위한 간격 추가
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}