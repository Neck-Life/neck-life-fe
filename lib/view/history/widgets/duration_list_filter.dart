import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/view/history/widgets/pose_count_frame.dart';

import '../../../theme/component/text_default.dart';

class DurationListFilter extends StatelessWidget {
  final bool chosen;
  final PoseType type;
  final void Function() onClick;


  const DurationListFilter({
    super.key,
    required this.type,
    required this.chosen,
    required this.onClick
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: res.percentHeight(1), left: res.percentWidth(2)),
        padding: EdgeInsets.symmetric(horizontal: res.percentWidth(2), vertical: res.percentHeight(0.5)),
        decoration: BoxDecoration(
          color: chosen ?  const Color(0xFF8991A0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              width: 1,
              color: const Color(0xFF8991A0)
          )
        ),
        child: TextDefault(content: type.poseString, fontSize: 13, isBold: false, fontColor: chosen ? Colors.white : const Color(0xFF8991A0),),
      ),
    );
  }

}