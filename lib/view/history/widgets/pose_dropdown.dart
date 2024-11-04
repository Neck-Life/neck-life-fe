import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/view/history/widgets/pose_count_frame.dart';

class PoseDropdown extends StatelessWidget {

  final void Function(PoseType) onChanged;
  final PoseType? chosenValue;

  const PoseDropdown({
    super.key,
    required this.onChanged,
    this.chosenValue
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: res.percentWidth(2)),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E3EC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton(
        value: chosenValue,
        borderRadius: BorderRadius.circular(20),
        items: [
          DropdownMenuItem(
            value: PoseType.slouch,
            child: SizedBox(
              width: res.percentWidth(20),
              child: Row(
                children: [
                  TextDefault(content: PoseType.slouch.poseString, fontSize: 14, isBold: false, fontColor: chosenValue == PoseType.slouch ? const Color(0xFF323238) : const Color(0xFF8991A0),),
                  // SizedBox(width: 5,),
                  // chosenValue == 'WEEK' ? const AssetIcon('check', size: 5, color: Color(0xFF236EF3),) : const SizedBox()
                ],
              ),
            ),
          ),
          DropdownMenuItem(
            value: PoseType.turtle,
            child: SizedBox(
              width: res.percentWidth(20),
              child: Row(
                children: [
                  TextDefault(content: PoseType.turtle.poseString, fontSize: 14, isBold: false, fontColor: chosenValue == PoseType.turtle ? const Color(0xFF323238) : const Color(0xFF8991A0),),
                  // chosenValue == 'MONTH1' ? const AssetIcon('check', size: 3, color: Color(0xFF236EF3),) : const SizedBox()
                ],
              ),
            ),
          ),
          DropdownMenuItem(
            value: PoseType.tilt,
            child: SizedBox(
              width: res.percentWidth(20),
              child: Row(
                children: [
                  TextDefault(content: PoseType.tilt.poseString, fontSize: 14, isBold: false, fontColor: chosenValue == PoseType.tilt ? const Color(0xFF323238) : const Color(0xFF8991A0),),
                  // chosenValue == 'MONTH3' ? const AssetIcon('check', size: 3, color: Color(0xFF236EF3),) : const SizedBox()
                ],
              ),
            ),
          ),
        ],
        onChanged: (value) {
          onChanged(value!);
        },
        icon: const AssetIcon('arrowDown', size: 4, color: Color(0xFF323238),),
        underline: const SizedBox(),
      ),
    );
  }

}