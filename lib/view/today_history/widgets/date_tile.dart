import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';


class DateTile extends StatelessWidget {

  final double? width;
  final bool? hasChosen;
  final int date;
  final int month;

  const DateTile({
    super.key,
    required this.date,
    required this.month,
    this.width,
    this.hasChosen
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Container(
      width: width == null ? res.percentWidth(17) : res.percentWidth(width!),
      height: width == null ? res.percentWidth(16.5) : res.percentWidth(width!-1),
      margin: EdgeInsets.only(left: res.percentWidth(2)),
      decoration: BoxDecoration(
        color: hasChosen == true ? const Color(0xFF3077F4) : const Color(0xFFE3E3EC),
        borderRadius: BorderRadius.circular(15)
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextDefault(
            content: '$month월',
            fontSize: 14,
            isBold: false,
            fontColor: hasChosen == true ? const Color(0xFFFFFFFF) : const Color(0xFF636377)
          ),
          TextDefault(
              content: '$date',
              fontSize: 18,
              isBold: true,
              fontColor: hasChosen == true ? const Color(0xFFFFFFFF) : const Color(0xFF636377)
          )
        ],
      ),
    );
  }

}