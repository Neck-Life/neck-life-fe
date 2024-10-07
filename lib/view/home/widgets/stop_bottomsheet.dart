
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/button.dart';
import 'package:mocksum_flutter/theme/component/person_icon.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/util/time_convert.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:provider/provider.dart';

class StopDetectionSheet extends StatelessWidget {
  
  final void Function() onStop;

  const StopDetectionSheet({
    super.key,
    required this.onStop
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    final GlobalTimer globalTimer = context.watch();

    return Container(
      width: res.percentWidth(90),
      height: 330,
      margin: EdgeInsets.only(bottom: res.percentHeight(5)),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(res.percentWidth(5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextDefault(
                        content: 'home_widgets.stop_bottomsheet.stop_detection'.tr(),
                        fontSize: 24,
                        isBold: true
                    ),
                    SizedBox(height: res.percentHeight(1),),
                    TextDefault(
                      //content: '탐지 시간: ${TimeConvert.sec2Min(globalTimer.useSec)}',
                      content: 'home_widgets.stop_bottomsheet.detection_time'.tr(args: [TimeConvert.sec2Min(globalTimer.useSec)]),
                      fontSize: 16,
                      isBold: false,
                      fontColor: const Color(0xFF236EF3),
                    ),
                    SizedBox(height: res.percentHeight(3),),
                    Center(
                      child: PersonIcon(size: res.percentWidth(6),),
                    )
                  ],
                ),
              ),
              Positioned(
                left: res.percentWidth(79),
                top: res.percentWidth(3),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: res.percentWidth(8),
                    height: res.percentWidth(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFF8991A0),
                        borderRadius: BorderRadius.circular(res.percentWidth(5))
                    ),
                    alignment: Alignment.center,
                    child: AssetIcon('close', color: Colors.white, size: res.percentWidth(1),),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: res.percentHeight(1),),
          Container(
            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Button(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'home_widgets.stop_bottomsheet.continue'.tr(),
                  backgroundColor: const Color(0xFF8991A0),
                  color: Colors.white,
                  width: res.percentWidth(38),
                  padding: res.percentWidth(3.5),
                ),
                Button(
                  onPressed: () {
                    onStop();
                    Navigator.pop(context);
                  },
                  text: 'home_widgets.stop_bottomsheet.stop'.tr(),
                  backgroundColor: const Color(0xFF236EF3),
                  color: Colors.white,
                  width: res.percentWidth(38),
                  padding: res.percentWidth(3.5),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

}