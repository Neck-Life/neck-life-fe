import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../util/responsive.dart';


class StretchingProgressBar extends StatefulWidget {
  final GlobalKey<_StretchingProgressBarState> key;
  double progress=0.0;
  // GlobalKey를 외부에서 받을 수 있도록 설정합니다.
  StretchingProgressBar({required this.key}) : super(key: key);

  @override
  _StretchingProgressBarState createState() => _StretchingProgressBarState();
  // 퍼블릭 메서드를 통해 State의 메서드를 호출할 수 있도록 프록시 메서드 추가
  ///파라미터 value 구간 [0, 1]에 맞게 적절히
  void updateProgress(double value) {
    key.currentState?.updateProgress(value);
  }
}


class _StretchingProgressBarState extends State<StretchingProgressBar> {
  double progress = 0.0; // 초기 progress 값

  void updateProgress(double value) {
    if(value < 0) value = 0;
    if(value > 1) value = 1;
    // Timer를 통해 주기적으로 progress 업데이트
    setState(() {
      progress = value; // targetValue를 progress로 반영
      widget.progress = progress;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset('assets/icons/time.svg'),
              progress < 0.8 ? Text(
                '고개를 조금 더 기울여볼까요?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ): Text("측정중"),
              SvgPicture.asset('assets/icons/time.svg'),
            ],
          ),
          SizedBox(height: 16,),
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
                        color: Color(0xFFD8E2F9), // 수정된 테두리 색상
                        width: 1, // 테두리 두께
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress, // 진행률에 따라 너비 조절
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFF236EF3),
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