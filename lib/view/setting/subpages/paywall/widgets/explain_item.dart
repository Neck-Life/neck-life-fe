import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';


class ExplainItem extends StatelessWidget {
  final String icon;
  final String title;
  final String content;

  const ExplainItem({
    super.key,
    required this.icon,
    required this.title,
    required this.content
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return WhiteContainer(
      padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
      radius: 20,
      margin: EdgeInsets.only(bottom: res.percentHeight(1.5)),
      child: Row(
        children: [
          // ColorFiltered(
          //   colorFilter: const ColorFilter.mode(Color(0x33FF0000), BlendMode.srcATop),
          //   child: Image.asset('assets/paywall_$icon.png', width: res.percentWidth(6)),
          // ),
          Image.asset('assets/paywall_$icon.png', width: res.percentWidth(12)),
          SizedBox(width: res.percentWidth(2),),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextDefault(content: title, fontSize: 18, isBold: true, fontColor: const Color(0xFF323238),),
              TextDefault(content: content, fontSize: 14, isBold: true, fontColor: const Color(0xFF8991A0),),
            ],
          )
        ],
      ),
    );
  }

}