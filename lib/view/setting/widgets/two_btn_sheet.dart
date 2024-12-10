
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/button.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';


class TwoBtnSheet extends StatelessWidget {

  const TwoBtnSheet({
    super.key,
    required this.title,
    this.content,
    required this.onError,
    required this.onSuccess,
    required this.onPress,
    this.btnStr,
    this.secondBtnStr
  });

  final void Function() onError;
  final void Function() onSuccess;
  final void Function() onPress;


  final String title;
  final String? content;
  final String? btnStr;
  final String? secondBtnStr;


  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return Container(
      width: res.percentWidth(90),
      height: content != null ? 300 : 210,
      margin: EdgeInsets.only(bottom: res.percentHeight(5)),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextDefault(
                    content: title,
                    fontSize: 20,
                    isBold: true,
                    fontColor: const Color(0xFF323238)
                ),
                SizedBox(height: res.percentHeight(1),),
                content != null ? Container(
                  height: res.percentHeight(9),
                  padding: EdgeInsets.only(right: res.percentWidth(4)),
                  child: TextDefault(
                      content: content!,
                      fontSize: 15,
                      isBold: false,
                      fontColor: const Color(0xFF64646F)
                  ),
                ) : const SizedBox(),
              ],
            ),
          ),
          // SizedBox(height: res.percentHeight(1),),
          Container(
            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Button(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: btnStr ?? 'setting_widgets.two_btn_sheet.cancel'.tr(),
                  backgroundColor: const Color(0xFF8991A0),
                  color: Colors.white,
                  width: res.percentWidth(38.5),
                  padding: res.percentWidth(4),
                  horizontalPadding: res.percentWidth(4),
                ),
                Button(
                  onPressed: () {
                    onPress();
                  },
                  text: secondBtnStr ??  'setting_widgets.two_btn_sheet.ok'.tr(),
                  backgroundColor: const Color(0xFF236EF3),
                  color: Colors.white,
                  width: res.percentWidth(38.5),
                  padding: res.percentWidth(4),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

}