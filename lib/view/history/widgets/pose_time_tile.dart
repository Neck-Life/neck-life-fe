import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/dashed_vertical_line.dart';
import 'package:mocksum_flutter/util/responsive.dart';

enum DurationType {
  normal,
  abnormal,
  none;

  Color get tileColor {
    switch (this) {
      case DurationType.normal:
        return const Color(0xFFD8E2F9);
      case DurationType.abnormal:
        return const Color(0xFFDCC6D9);
      case DurationType.none:
        return const Color(0xFFF4F4F7);
    }
  }

  String get durationString {
    switch (this) {
      case DurationType.normal:
        return 'normal';
      case DurationType.abnormal:
        return 'abnormal';
      case DurationType.none:
        return 'none';
    }
  }

}

class PoseTimeTile extends StatelessWidget {

  final DurationType durationType;
  final double widthRate;

  const PoseTimeTile({
    super.key,
    required this.widthRate,
    required this.durationType
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Stack(
      children: [
        Container(
            width: res.percentWidth(74)*widthRate,
            height: res.percentHeight(6),
            decoration: BoxDecoration(
              color: durationType.tileColor,
            )
        ),
        durationType == DurationType.abnormal ? const Positioned(
            left: 0,
            child: DashedVerticalLine(height: 12)
        ) : const SizedBox(),
        durationType == DurationType.abnormal ? Positioned(
          left: res.percentWidth(74)*widthRate-1,
          child: const DashedVerticalLine(height: 12)
        ) : const SizedBox(),
      ],
    );
  }

}