import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';

enum PoseType {
  slouch,
  turtle,
  back;

  String get poseString {
    switch (this) {
      case PoseType.slouch:
        return 'history_widgets.pose_count_frame.slouch'.tr();
      case PoseType.turtle:
        return 'history_widgets.pose_count_frame.turtle'.tr();
      case PoseType.back:
        return 'history_widgets.pose_count_frame.back'.tr();;
    }
  }

  String get poseIconString {
    switch (this) {
      case PoseType.slouch:
        return 'assets/slouch.svg';
      case PoseType.turtle:
        return 'assets/turtle.svg';
      case PoseType.back:
        return 'assets/back.svg';
    }
  }
}

class PoseCountFrame extends StatelessWidget {

  final int? count;
  final PoseType poseType;

  const PoseCountFrame({
    super.key,
    required this.poseType,
    this.count
  });

  @override
  Widget build(BuildContext context) {
    // print('count build');
    Responsive res = Responsive(context);
    int? count_ = count;
    return WhiteContainer(
      width: res.percentWidth(5.5),
      padding: EdgeInsets.symmetric(horizontal: res.percentWidth(2), vertical: res.percentHeight(2)),
      radius: 12,
      child: Column(
        children: [
          TextDefault(
            content: poseType.poseString,
            fontSize: 14,
            isBold: false
          ),
          // SizedBox(height: res.percentHeight(0.5),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextDefault(
                content: count_ == null ? '0' : count_.toString(),
                fontSize: 22,
                isBold: true,
                fontColor: const Color(0xFFF25959),
              ),
              TextDefault(
                content: 'history_widgets.pose_count_frame.count'.tr(),
                fontSize: 16,
                isBold: false,
                fontColor: Color(0xFFF25959),
              )
            ],
          ),
          SizedBox(height: res.percentHeight(1),),
          ClipRRect(
            borderRadius: BorderRadius.circular(res.percentWidth(7)),
            child: Container(
              width: res.percentWidth(12.5),
              height: res.percentWidth(12.5),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F7)
              ),
              padding: EdgeInsets.only(top: res.percentHeight(1)),
              child: Center(
                child: SvgPicture.asset(
                  poseType.poseIconString,
                  width: res.percentWidth(12.5),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

}