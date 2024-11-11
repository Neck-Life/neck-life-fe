import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';


class DateCell extends StatelessWidget {
  final double rate;
  final bool? isToday;

  const DateCell({
    super.key,
    required this.rate,
    this.isToday
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Container(
      margin: const EdgeInsets.all(2),
      width: res.percentWidth(6),
      height: res.percentWidth(6),
      padding: EdgeInsets.all(res.percentWidth(1.5)),
      decoration: BoxDecoration(
          color: rate == 0 ? const Color(0xFFE1E1E9) : const Color(0xFF115FE9).withOpacity(max(rate, 0.2)),
          borderRadius: BorderRadius.circular(5),
          border: isToday == true ? Border.all(color: Colors.black, width: 1) : null
      ),
      child: isToday == true ? Container(
        width: res.percentWidth(2),
        height: res.percentWidth(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: const Color(0xFF8991A0)
        ),
      ) : const SizedBox(),
    );
  }

}