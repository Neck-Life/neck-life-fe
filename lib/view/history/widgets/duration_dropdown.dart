import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';

class DurationDropdown extends StatelessWidget {
  
  final void Function(String) onChanged;
  final String? chosenValue;

  const DurationDropdown({
    super.key,
    required this.onChanged,
    this.chosenValue
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: DropdownButton(
        value: chosenValue,
        borderRadius: BorderRadius.circular(20),
        items: [
          DropdownMenuItem(
            value: 'WEEK',
            child: SizedBox(
              width: res.percentWidth(15),
              child: Row(
                children: [
                  TextDefault(content: 'history_widgets.duration_dropdown.week'.tr(), fontSize: chosenValue == 'WEEK' ? 22 : 16, isBold: chosenValue == 'WEEK' ? true : false, fontColor: chosenValue == 'WEEK' ? const Color(0xFF323238) : const Color(0xFF8991A0),),
                  // SizedBox(width: 5,),
                  // chosenValue == 'WEEK' ? const AssetIcon('check', size: 5, color: Color(0xFF236EF3),) : const SizedBox()
                ],
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'MONTH1',
            child: SizedBox(
              width: res.percentWidth(20),
              child: Row(
                children: [
                  TextDefault(content: 'history_widgets.duration_dropdown.month1'.tr(), fontSize: chosenValue == 'MONTH1' ? 22 : 16, isBold: chosenValue == 'MONTH1' ? true : false, fontColor: chosenValue == 'MONTH1' ? const Color(0xFF323238) : const Color(0xFF8991A0),),
                  // chosenValue == 'MONTH1' ? const AssetIcon('check', size: 3, color: Color(0xFF236EF3),) : const SizedBox()
                ],
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'MONTH3',
            child: SizedBox(
              width: res.percentWidth(20),
              child: Row(
                children: [
                  TextDefault(content: 'history_widgets.duration_dropdown.month3'.tr(), fontSize: chosenValue == 'MONTH3' ? 22 : 16, isBold: chosenValue == 'MONTH3' ? true : false, fontColor: chosenValue == 'MONTH3' ? const Color(0xFF323238) : const Color(0xFF8991A0),),
                  // chosenValue == 'MONTH3' ? const AssetIcon('check', size: 3, color: Color(0xFF236EF3),) : const SizedBox()
                ],
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'MONTH6',
            child: SizedBox(
              width: res.percentWidth(20),
              child: Row(
                children: [
                  TextDefault(content: 'history_widgets.duration_dropdown.month6'.tr(), fontSize: chosenValue == 'MONTH6' ? 22 : 16, isBold: chosenValue == 'MONTH6' ? true : false, fontColor: chosenValue == 'MONTH6' ? const Color(0xFF323238) : const Color(0xFF8991A0),),
                  // chosenValue == 'MONTH6' ? const AssetIcon('check', size: 3, color: Color(0xFF236EF3),) : const SizedBox()
                ],
              ),
            ),
          )
        ],
        onChanged: (value) {
          onChanged(value!);
        },
        icon: const AssetIcon('arrowDown', size: 5, color: Color(0xFF323238),),
        underline: const SizedBox(),
      ),
    );
  }

}