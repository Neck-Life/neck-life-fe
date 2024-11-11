import 'package:flutter/material.dart';
import 'package:mocksum_flutter/service/status_provider.dart';

import '../../../theme/asset_icon.dart';
import '../../../theme/component/text_default.dart';
import '../../../theme/component/white_container.dart';
import '../../../util/responsive.dart';

class SensorDataAdjustWidget extends StatelessWidget {
  const SensorDataAdjustWidget({super.key});

  void adjustSensorData(){
    // DetectStatus.initialPitch = DetectStatus.nowPitch;
    // DetectStatus.initialRoll = DetectStatus.nowRoll;
    DetectStatus.initialYaw = DetectStatus.nowYaw; //일단 지금 버전에서는, 절대적기준이 없는 yaw만 재할당 시켜줌
    // print('yaw기준점 재설정됨 : ${DetectStatus.initialYaw}');
  }
  @override
  Widget build(BuildContext context){
    Responsive res = Responsive(context);
    // print('빌드됨 ㅋ');
    return GestureDetector(
      onTap: adjustSensorData,
      child: WhiteContainer(
        width: 50,
        padding: EdgeInsets.symmetric(horizontal: res.percentWidth(2), vertical: res.percentHeight(1)),
        radius: 10,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AssetIcon('info', size: res.percentWidth(1.5,)),
                const SizedBox(width: 8),
                Column(
                  children: [
                    TextDefault(
                      content: '스트레칭 자세 기준이 이상한가요?',
                      fontSize: 10,
                      isBold: false,
                    ),
                    TextDefault(
                      content: '여기를 클릭해주세요.',
                      fontSize: 10,
                      isBold: false,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
