import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../theme/component/text_default.dart';
import '../../../util/responsive.dart';

import 'dart:math';

class BlurredMan extends StatefulWidget {
  final bool? isBlurred;

  const BlurredMan({super.key, this.isBlurred});

  @override
  State<StatefulWidget> createState() => _BlurredManState();
}

class _BlurredManState extends State<BlurredMan> with SingleTickerProviderStateMixin {

  // late AnimationController _controller;
  // late CurvedAnimation _curve;
  // late Animation<double> _pitchAnimation;
  // late Animation<double> _rotateAnimation;


  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat(reverse: true);
    //
    // _controller.addStatusListener((status) {
    //   switch (_controller.status) {
    //     case AnimationStatus.dismissed:
    //       _controller.forward();
    //       break;
    //     case AnimationStatus.completed:
    //       Future.delayed(const Duration(milliseconds: 1500), () {
    //         _controller.value = 0;
    //       });
    //
    //       break;
    //     default:
    //   }
    // });


    // _curve = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    // _pitchAnimation = Tween<double>(begin: 0, end: 0.8).animate(_curve);

    // _rotateAnimation = Tween<double>(begin: 0.5, end: 0).animate(_curve);
    // _controller.forward();
  }

  double _cosWithWeight(double d, double offset) {
    return d >= 0 ? (1-cos(d))*(offset*(10*cos(4*d)+d*20)) : (cos(d)-1)*offset-offset/5;
  }


  @override
  void dispose() {
    // _controller.stop();
    // _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return Container(
      width: res.percentWidth(45),
      height: res.percentWidth(45),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(res.percentWidth(25))
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(res.percentWidth(25)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: res.percentHeight(7.5),
              child: Transform.rotate(
                angle: 0, // **calculate based on head pos
                origin: Offset(0, -res.percentWidth(1)),
                child: Container(
                  width: res.percentWidth(5.5),
                  height: res.percentWidth(85)*0.3,
                  decoration: const BoxDecoration(
                      color: Color(0xFFFFB59E),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                  ),
                ),
              ),
            ),
            Positioned(
              top: res.percentHeight(12),
              left: res.percentWidth(11),
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
                top: res.percentWidth(30)*0.15+sin(0).abs()*res.percentWidth(30)*0.15,
                left: res.percentWidth(30)*0.5-res.percentWidth(30)*0.03+_cosWithWeight(0, res.percentWidth(5)),
                child: Transform.rotate(
                    angle: 0, // **calculated by pitch
                    origin: Offset(-res.percentWidth(25)*0.5+res.percentWidth(10), res.percentWidth(25)*0.5-res.percentWidth(5)),
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
            Positioned(
                left: res.percentWidth(22.5),
                child: Container(
                  width: 2,
                  height: 300,
                  color: const Color(0xFF3077F4),
                )
            ),
            widget.isBlurred == true ? Positioned(
              // left: res.percentWidth(25),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      width: res.percentWidth(75),
                      height: res.percentHeight(75),
                      color: Colors.black.withOpacity(0),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextDefault(content: context.locale.languageCode == 'ko' ? '이미지 준비 중' : 'Preparing Image', fontSize: 14, isBold: true),
                        ],
                      ),
                    ),
                  ),
                )
            ) : const SizedBox()
          ],
        ),
      ),
    );
  }
}