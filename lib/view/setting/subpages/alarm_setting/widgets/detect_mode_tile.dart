import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';


class DetectModeTile extends StatelessWidget {
  final bool useHorizontalMove;
  final void Function(bool) onChange;
  final bool chosenVal;

  const DetectModeTile({
    super.key,
    required this.useHorizontalMove,
    required this.onChange,
    required this.chosenVal
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return GestureDetector(
        onTap: () {
          onChange(useHorizontalMove);
        },
        child: Container(
          height: res.percentHeight(6),
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: res.percentWidth(5),
                height: res.percentWidth(5),
                padding: EdgeInsets.all(res.percentWidth(0.5)),
                decoration: BoxDecoration(
                    color: chosenVal == useHorizontalMove ? const Color(0xFF236EF3) : const Color(0xFFF4F4F7),
                    borderRadius: BorderRadius.circular(res.percentWidth(3))
                ),
                child: AssetIcon('check', size: 1, color: chosenVal == useHorizontalMove ? Colors.white : const Color(0xFF101E32),),
              ),
              SizedBox(width: res.percentWidth(3),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextDefault(content: useHorizontalMove ? 'setting_subpages.alarm_setting.alarm_setting_view.horizon_o1'.tr() : 'setting_subpages.alarm_setting.alarm_setting_view.horizon_o2', fontSize: 16, isBold: false,),
                  TextDefault(
                    content: useHorizontalMove ? 'setting_subpages.alarm_setting.alarm_setting_view.recommend1' : 'setting_subpages.alarm_setting.alarm_setting_view.recommend2',
                    fontSize: 13,
                    isBold: false,
                    fontColor: const Color(0xFF8991A0),
                  ),
                ],
              ),
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