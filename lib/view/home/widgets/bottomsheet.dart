
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/view/home/widgets/airpod_modal.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';

class AirpodsConnectlessSheet extends StatelessWidget {
  const AirpodsConnectlessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return Container(
      width: res.percentWidth(90),
      height: 330,
      margin: EdgeInsets.only(bottom: res.percentHeight(5)),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(res.percentWidth(5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextDefault(
                  content: '에어팟 연결이 끊겼어요.\n다시 연결해주세요.',
                  fontSize: 24,
                  isBold: true
                ),
                SizedBox(height: res.percentHeight(1),),
                const TextDefault(
                  content: '연결 기기 없음',
                  fontSize: 16,
                  isBold: false,
                  fontColor: Color(0xFF236EF3),
                ),
                SizedBox(height: res.percentHeight(3),),
                Center(
                  child: AirpodsModal(isRotating: true, width: res.percentWidth(7),),
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
    );
  }

}