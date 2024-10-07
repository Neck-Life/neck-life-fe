import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';


class TimeDelayTile extends StatelessWidget {
  final int alarmDelay;
  final void Function(int) onChange;
  final int chosenVal;

  const TimeDelayTile({
    super.key,
    required this.alarmDelay,
    required this.onChange,
    required this.chosenVal
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return GestureDetector(
      onTap: () {
        onChange(alarmDelay);
      },
      child: SizedBox(
        height: res.percentHeight(6),
        child: Row(
          children: [
            Container(
              width: res.percentWidth(5),
              height: res.percentWidth(5),
              padding: EdgeInsets.all(res.percentWidth(0.5)),
              decoration: BoxDecoration(
                  color: chosenVal == alarmDelay ? const Color(0xFF236EF3) : const Color(0xFFF4F4F7),
                  borderRadius: BorderRadius.circular(res.percentWidth(3))
              ),
              child: AssetIcon('check', size: 1, color: chosenVal == alarmDelay ? Colors.white : const Color(0xFF101E32),),
            ),
            SizedBox(width: res.percentWidth(3),),
            TextDefault(content: 'setting_subpages.alarm_setting.alarm_setting_widgets.time_delay_tile.seconds'.tr(args:[alarmDelay.toString()]), fontSize: 16, isBold: false,),
          ],
        ),
    )
      // leading: Radio(
      //   value: alarmDelay,
      //   groupValue: chosenVal,
      //   onChanged: (int? value) {
      //     onChange(value!);
      //   },
      // ),
    );
  }

}