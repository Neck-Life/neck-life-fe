import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';


class DashedVerticalLine extends StatelessWidget {

  final double height;
  final Color? color;

  const DashedVerticalLine({
    super.key,
    required this.height,
    this.color
  });

  // 107 -> 10개
  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    const double dashHeight = 3;
    final lineHeight = res.percentHeight(height);

    return Column(
      children: List.filled(lineHeight ~/ (2*dashHeight), 0).map((_) {
        return Container(
          width: 1,
          height: dashHeight,
          margin: const EdgeInsets.only(bottom: dashHeight),
          decoration: BoxDecoration(
            color: color ?? const Color(0xFFEB5757)
          ),
        );
      }).toList() + (lineHeight % (2*dashHeight) <= dashHeight ? [] :
      [Container(
        width: 1,
        height: lineHeight % (2*dashHeight) - dashHeight,
        margin: const EdgeInsets.only(bottom: dashHeight),
        decoration: BoxDecoration(
            color: color ?? const Color(0xFFEB5757)
        ),
      )]),
    );
  }

}