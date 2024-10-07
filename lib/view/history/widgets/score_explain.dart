
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';

class ScoreExplain extends StatelessWidget {
  const ScoreExplain({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return Container(
      width: res.percentWidth(90),
      height: 300,//res.percentHeight(33),
      margin: EdgeInsets.only(bottom: res.percentHeight(5)),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(3.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextDefault(
                    content: '자세 점수는 어떻게 계산되나요?',
                    fontSize: 20,
                    isBold: true,
                    fontColor: Color(0xFF323238)
                ),
                SizedBox(height: res.percentHeight(1),),
                Container(
                  height: res.percentHeight(11),
                  padding: EdgeInsets.only(right: res.percentWidth(4)),
                  child: const TextDefault(
                      content: '자세 점수는 기본 70점에서 출발하여 바른 자세를 오랜 시간 유지할수록 점점 증가하고, 안 좋은 자세를 탐지할 때마다 감점됩니다. 점수의 최고점은 100점, 최하점은 0점입니다.',
                      fontSize: 15,
                      isBold: false,
                      fontColor: Color(0xFF64646F),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: res.percentHeight(1),),
          Container(
            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5)),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: res.percentWidth(80),
                decoration: BoxDecoration(
                  color: const Color(0xFF8991A0),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: res.percentWidth(5),),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextDefault(
                      content: '이해했어요',
                      fontSize: 16,
                      isBold: true,
                      fontColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

}