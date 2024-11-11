
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';

class StreakExplain extends StatelessWidget {
  const StreakExplain({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return Container(
      width: res.percentWidth(90),
      height: context.locale.languageCode == 'ko' ? 300 : 330,//res.percentHeight(33),
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
                TextDefault(
                    content: 'goal_view.streak_title'.tr(),
                    fontSize: 20,
                    isBold: true,
                    fontColor: const Color(0xFF323238)
                ),
                SizedBox(height: res.percentHeight(1),),
                Container(
                  height: res.percentHeight(11),
                  padding: EdgeInsets.only(right: res.percentWidth(4)),
                  child: TextDefault(
                    content: 'goal_view.streak_explain'.tr(),
                    fontSize: 15,
                    isBold: false,
                    fontColor: const Color(0xFF64646F),
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
                child:  Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextDefault(
                      content: 'history_widgets.score_explain.understand'.tr(),
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