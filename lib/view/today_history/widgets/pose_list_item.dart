import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/view/history/widgets/pose_count_frame.dart';


class PoseListItem extends StatelessWidget {
  final PoseType poseType;
  final String time;


  const PoseListItem({
    super.key,
    required this.poseType,
    required this.time
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              // margin: EdgeInsets.only(top: res.percentWidth(1)),
              width: res.percentWidth(3),
              height: res.percentWidth(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF25959),
                borderRadius: BorderRadius.circular(res.percentWidth(1.5))
              ),
            ),
            Container(
              width: 2,
              height: res.percentHeight(7.5),
              decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EB),
                  borderRadius: BorderRadius.circular(1)
              ),
            ),
          ],
        ),
        SizedBox(width: res.percentWidth(3),),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextDefault(
                  content: poseType.poseString,
                  fontSize: 16,
                  isBold: false,
                  fontColor: const Color(0xFFF25959),
                ),
                TextDefault(
                  content: 'today_history_widgets.pose_list_item.posture_detection'.tr(),
                  fontSize: 16,
                  isBold: false,
                )
              ],
            ),
            const SizedBox(height: 5,),
            TextDefault(
              content: time,
              fontSize: 14,
              isBold: false,
              fontColor: const Color(0xFF6983B2),
            ),
          ],
        )
      ],
    );
  }

}