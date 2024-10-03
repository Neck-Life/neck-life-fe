import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/view/setting/subpages/paywall/paywall_view.dart';


class MenuItem extends StatelessWidget {
  final String iconStr;
  final String text;
  final void Function() onTap;
  final bool? isPremium;


  const MenuItem({
    super.key,
    required this.iconStr,
    required this.text,
    required this.onTap,
    this.isPremium
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: res.deviceWidth,
        padding: EdgeInsets.only(left: res.percentWidth(6), right: res.percentWidth(6), top: res.percentHeight(3)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AssetIcon(iconStr, size: 5, color: const Color(0xFF8991A0),),
                SizedBox(width: res.percentWidth(2),),
                TextDefault(
                    content: text,
                    fontSize: 15,
                    isBold: false
                )
              ],
            ),
            Row(
              children: [
                text == '내 구독' ? GestureDetector(
                  onTap: () {
                    if (isPremium == false) {
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) => const Paywall()));
                    } else {

                    }
                  },
                  child: TextDefault(content: isPremium == true ? '프리미엄 플랜' : '구독하기', fontSize: 15, isBold: false, fontColor: Color(0xFF236EF3),),
                ) : const SizedBox(),
                SizedBox(width: res.percentWidth(2),),
                const AssetIcon('arrowNext', color: Color(0xFF9696A2), size: 5,)
              ],
            )
          ],
        ),
      ),
    );
  }

}