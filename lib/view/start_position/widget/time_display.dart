import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/main.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/util/responsive.dart';

import '../../../theme/component/text_default.dart';


class TimeDisplay extends StatelessWidget {
  final int minute;
  final void Function() plus;
  final void Function() minus;


  const TimeDisplay({super.key, required this.minute, required this.plus, required this.minus});

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Container(
      // margin: EdgeInsets.only(left: res.percentWidth(17.5)),
      width: res.percentWidth(30),
      padding: EdgeInsets.symmetric(horizontal: res.percentWidth(3), vertical: res.percentHeight(0.5)),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextDefault(content: "$minute${context.locale.languageCode == 'ko' ? '분' : "'"}", fontSize: 16, isBold: true),
          // SizedBox(width: res.percentWidth(3),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  // print('touch');
                  plus();
                },
                child: AssetIcon('arrowUp', size: res.percentWidth(1.25),),
              ),
              GestureDetector(
                onTap: () {
                  // print('tuoch');
                  minus();
                },
                child: AssetIcon('arrowDown', size: res.percentWidth(1.25),),
              )
            ],
          )
        ],
      )
    );
  }

}