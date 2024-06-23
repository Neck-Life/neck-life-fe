import 'package:flutter/material.dart';

class StartPosition  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 390,
          height: 844,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Color(0xFFF9F9F9)),
          child: Stack(
            children: [
              Positioned(
                left: 60,
                top: 113,
                child: Text(
                  '바른 자세를 5초 동안 \n유지해주세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 60,
                top: 295,
                child: Container(
                  width: 253,
                  height: 253,
                  decoration: ShapeDecoration(
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
              ),
              Positioned(
                left: 70,
                top: 305,
                child: Container(
                  width: 234,
                  height: 234,
                  decoration: ShapeDecoration(
                    color: Color(0xFF636363),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 161,
                top: 372,
                child: Text(
                  '5',
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
            ],
          ),
        ),
      ],
    );
  }
}