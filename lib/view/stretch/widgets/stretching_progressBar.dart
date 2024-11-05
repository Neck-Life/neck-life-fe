import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../util/localization_string.dart';
import '../../../util/responsive.dart';

class StretchingProgressBar extends StatefulWidget {
  final GlobalKey<_StretchingProgressBarState> key;
  double progress = 0.0;

  // GlobalKey를 외부에서 받을 수 있도록 설정합니다.
  StretchingProgressBar({required this.key}) : super(key: key);

  @override
  _StretchingProgressBarState createState() => _StretchingProgressBarState();

  // 퍼블릭 메서드를 통해 State의 메서드를 호출할 수 있도록 프록시 메서드 추가
  ///파라미터 value 구간 [0, 1]에 맞게 적절히
  void updateProgress(double progress, bool isThresholdReached,
      double elapsedTime, double duration) {
    key.currentState
        ?.updateProgress(progress, isThresholdReached, elapsedTime, duration);
  }
}

class _StretchingProgressBarState extends State<StretchingProgressBar> {
  double elapsedTime = 0;
  double duration = 0;
  bool isThresholdReached = false;

  void updateProgress(double progress, bool isThresholdReached,
      double elapsedTime, double duration) {
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;
    // Timer를 통해 주기적으로 progress 업데이트
    setState(() {
      widget.progress = progress;
      this.isThresholdReached = isThresholdReached;
      this.elapsedTime = elapsedTime;
      this.duration = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive(context).percentWidth(90),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive(context).percentWidth(5), // 화면 너비의 5%
        vertical: Responsive(context).percentHeight(2.5), // 화면 높이의 2%
      ),
      // padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFFE5E5EB), // 수정된 테두리 색상
          width: 1, // 테두리 두께
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌측 모래시계 아이콘
          isThresholdReached
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset('assets/icons/time.svg'),
                    Text(
                      LS.tr('stretching.progress_bar.time_elapsed', [
                        elapsedTime.toStringAsFixed(0),
                        duration.toStringAsFixed(0)
                      ]),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SvgPicture.asset('assets/icons/time.svg'),
                  ],
                )
              : Text(
                LS.tr('stretching.progress_bar.slightly_more_tilt'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
          SizedBox(
            height: 16,
          ),
          // 중앙 텍스트 및 진행 상황 바
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 진행 상황 바
              Stack(
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        // color: Color(0xFFD8E2F9),
                        color: isThresholdReached
                            ? Color(0xFFD8E2F9)
                            : Color(0x9FED5252),
                        width: 0.5, // 테두리 두께
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: isThresholdReached
                            ? elapsedTime / duration
                            : widget.progress, // 진행률에 따라 너비 조절
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            // color: isThresholdReached ? Color(0xFFD8E2F9) : Color(0x9FED5252),
                            color: isThresholdReached
                                ? Color(0xFF236EF3)
                                : Color(0x9FED5252),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
