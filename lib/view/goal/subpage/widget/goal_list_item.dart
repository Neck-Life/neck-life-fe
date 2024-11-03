import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/view/goal/subpage/goal_setting.dart';

import '../../../../theme/asset_icon.dart';
import '../../../../theme/component/text_default.dart';
import '../../../../theme/component/white_container.dart';


class GoalListItem extends StatelessWidget {
  final GoalType goalType;
  final double targetValue;
  final bool isSet;
  final double achieveRate;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool isInHistory;


  const GoalListItem({
    super.key,
    required this.goalType,
    required this.targetValue,
    required this.isSet,
    required this.achieveRate,
    this.fontSize,
    this.padding,
    this.isInHistory = false
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    print(targetValue);

    return GestureDetector(
      onTap: () {
        if (isInHistory) return;
        Navigator.push(
            context, MaterialPageRoute(builder: (
            context) => GoalSetting(goalType: goalType,)));
      },
      child: WhiteContainer(
        padding: padding ?? EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: Row(
                children: [
                  AssetIcon(goalType.iconName, size: res.percentWidth(1), color: const Color(0xFF8991A0),),
                  SizedBox(width: res.percentWidth(2),),
                  TextDefault(content: goalType.desc.replaceAll('n', (goalType == GoalType.time ? targetValue/60 : targetValue).toInt().toString()), fontSize: fontSize ?? 16, isBold: false, fontColor: const Color(0xFF323238),)
                ],
              ),
            ),
            !isSet ?
            (isInHistory ? const SizedBox() : AssetIcon('arrowNext', size: res.percentWidth(1), color: const Color(0xFF8991A0),))
            : Row(
              children: [
                achieveRate == 1 ? AssetIcon('check', size: res.percentWidth(1), color: const Color(0xFF236EF3),)
                : SizedBox(
                  width: res.percentWidth(4),
                  height: res.percentWidth(4),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: achieveRate,
                    color: const Color(0xFF236EF3),
                    backgroundColor: const Color(0xFFF4F4F7),
                  ),
                ),
                SizedBox(width: res.percentWidth(2),),
                TextDefault(content: achieveRate == 1 ? 'goal_view.complete'.tr() : '${(achieveRate*100).round()}%', fontSize: 15, isBold: false, fontColor: const Color(0xFF236EF3),)
              ],
            )
          ],
        ),
      ),
    );
  }
}
