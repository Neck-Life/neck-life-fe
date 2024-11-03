import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/view/home/subpage/survey/survey.dart';

class SurveyBanner extends StatelessWidget {

  const SurveyBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Survey()));
      },
      child: Container(
        width: 340,
        height: 50,
        padding: const EdgeInsets.only(left: 5),
        decoration: const BoxDecoration(
            color: Color(0xFF236EF3)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextDefault(content: '사용자 만족도 조사', fontSize: 20, isBold: true, fontColor: Colors.white,),
                TextDefault(content: '여러분의 소중한 의견을 들려주세요!', fontSize: 12, isBold: true, fontColor: Colors.white,),
              ],
            ),
            Image.asset('assets/mockup.png', width: 100, fit: BoxFit.cover,)
          ],
        ),
      ),
    );
  }

}