import 'dart:async';

import 'package:flutter/material.dart';
import 'util/responsive.dart';

class StartPosition extends StatefulWidget {
  const StartPosition({super.key});
  @override
  StartPositionState createState() => StartPositionState();
}

class StartPositionState extends State<StartPosition> {

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
            child:Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 70),
                  child: const Text(
                    '바른 자세를 5초 동안 \n유지해주세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  )
                ),
                const SizedBox(height: 70),
                Stack(
                  children: [
                    Container(
                      width: responsive.percentWidth(70),
                      height: responsive.percentWidth(70),
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: OvalBorder(),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 0),
                            spreadRadius: 1,
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        top: 9,
                        left: 9,
                        child: Container(
                          width: responsive.percentWidth(70)-18,
                          height: responsive.percentWidth(70)-18,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF646464),
                            shape: OvalBorder(),
                          ),
                          child: const Center(
                            child: Text(
                              _lastTime,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFEBEBEB),
                                fontSize: 80,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                            ),
                          ),
                        )
                    )
                  ],
                ),
                const SizedBox(height: 70),
                Container(
                  height: 35,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 4,
                        offset: Offset(2, 2),
                        spreadRadius: 3,
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(responsive.percentWidth(40), 30),
                      backgroundColor: const Color(0xFF4A4A4A),
                      surfaceTintColor: const Color(0xFF4A4A4A),
                      shadowColor: const Color(0x19000000)
                    ),
                    child: const Text(
                      '기준 자세 측정',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    )
                  )
                )
              ],
          )
        ),
      )
    );
  }
}
