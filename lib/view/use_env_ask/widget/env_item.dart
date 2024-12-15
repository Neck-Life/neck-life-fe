import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/main.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/util/responsive.dart';

import '../../../theme/component/text_default.dart';
import '../../../theme/component/white_container.dart';

enum UserEnvType {
  book,
  moving,
  phone,
  monitor,
  laptop,
  no_setting;

  String get typeString {
    switch (this) {
      case UserEnvType.book:
        return 'book';
      case UserEnvType.moving:
        return 'moving';
      case UserEnvType.phone:
        return 'phone';
      case UserEnvType.monitor:
        return 'monitor';
      case UserEnvType.laptop:
        return 'laptop';
      case UserEnvType.no_setting:
        return 'no_setting';
    }
  }
}


class EnvItem extends StatelessWidget {
  final String desc;
  final bool isSelected;
  final void Function() onChange;


  const EnvItem({super.key, required this.desc, required this.isSelected, required this.onChange});

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return GestureDetector(
      onTap: () {
        onChange();
      },
      child: WhiteContainer(
        padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2)),
        margin: EdgeInsets.only(bottom: res.percentHeight(1)),
        borderColor: isSelected ? const Color(0xFF236EF3) : const Color(0xFFF4F4F7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextDefault(content: desc, fontSize: 16, isBold: false, fontColor: const Color(0xFF323238),),
            Container(
              width: res.percentWidth(5),
              height: res.percentWidth(5),
              padding: EdgeInsets.all(res.percentWidth(0.5)),
              decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF236EF3) : const Color(0xFFF4F4F7),
                  borderRadius: BorderRadius.circular(res.percentWidth(3))
              ),
              child: AssetIcon('check', size: 1, color: isSelected ? Colors.white : const Color(0xFF101E32),),
            )
          ],
        ),
      ),
    );
  }

}