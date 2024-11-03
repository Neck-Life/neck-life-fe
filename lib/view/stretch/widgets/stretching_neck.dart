import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../service/status_provider.dart';
import '../../../util/responsive.dart';

/**
 * 캐릭터 모델
 * Pitch, roll버전
 * */
class NeckModel extends StatefulWidget {
  const NeckModel({Key? key}) : super(key: key);

  @override
  NeckModelState createState() => NeckModelState();
}

class NeckModelState extends State<NeckModel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double degree = 0;

  // 자식 클래스에서 이 메서드를 오버라이드하여 각도 값 업데이트
  void updateAnimationValues() {}

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50))
      ..addListener(() {
        setState(() {
          updateAnimationValues(); // 자식 클래스에서 정의
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return Container(
      width: res.percentWidth(35),
      height: res.percentWidth(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(res.percentWidth(25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(res.percentWidth(25)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: res.percentHeight(7.5),
              child: Container(
                width: res.percentWidth(5.5),
                height: res.percentWidth(85) * 0.3,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB59E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
            Positioned(
              top: res.percentHeight(12),
              left: res.percentWidth(6),
              child: SizedBox(
                width: res.percentWidth(22),
                child: Image.asset(
                  'assets/body.png',
                  width: res.percentWidth(30),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
                top: res.percentWidth(30) * 0.15,
                left: res.percentWidth(20) * 0.5 - res.percentWidth(20) * 0.03,
                child: Transform.rotate(
                    angle: degree, // **calculated by pitch
                    origin: Offset(
                        -res.percentWidth(25) * 0.5 + res.percentWidth(10),
                        res.percentWidth(25) * 0.5 - res.percentWidth(5)),
                    child: SizedBox(
                        width: res.percentWidth(17.5),
                        height: res.percentWidth(17.5),
                        child: Image.asset(
                          "assets/head.png",
                          width: res.percentWidth(25),
                          height: res.percentWidth(25),
                          fit: BoxFit.contain,
                        )
                    )
                )
            ),
          ],
        ),
      ),
    );
  }
}

class NeckPitch extends NeckModel {
  const NeckPitch({Key? key}) : super(key: key);

  @override
  NeckPitchState createState() => NeckPitchState();
}

class NeckPitchState extends NeckModelState {
  @override
  void updateAnimationValues() {
    degree = -DetectStatus.nowPitch; // Pitch 값을 업데이트, pitch방향이 현실과 반대로 작용됨
  }
}

class NeckRoll extends NeckModel {
  const NeckRoll({Key? key}) : super(key: key);

  @override
  NeckRollState createState() => NeckRollState();
}

class NeckRollState extends NeckModelState {
  @override
  void updateAnimationValues() {
    degree = DetectStatus.nowRoll; // Pitch 값을 업데이트
  }
}
