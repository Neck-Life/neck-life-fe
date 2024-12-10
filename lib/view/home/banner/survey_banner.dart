import 'package:easy_localization/easy_localization.dart';
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
        width: res.deviceWidth,
        height: 90,
        padding: const EdgeInsets.only(left: 5),
        decoration: const BoxDecoration(
            color: Color(0xFF236EF3)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: res.percentWidth(60),
                  child: TextDefault(content: 'survey.banner_txt'.tr(), fontSize: 15, isBold: true, fontColor: Colors.white,),
                ),
                // TextDefault(content: '여러분의 소중한 의견을 들려주세요!', fontSize: 12, isBold: true, fontColor: Colors.white,),
              ],
            ),
            Image.asset('assets/mockup.png', width: 100, fit: BoxFit.cover,)
          ],
        ),
      ),
    );
  }

}