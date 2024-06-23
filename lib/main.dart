import 'package:flutter/material.dart';
import 'package:mocksum_flutter/start_position.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
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
                left: 30,
                top: 66,
                child: Container(
                  width: 330,
                  height: 102,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 4,
                        offset: Offset(2, 2),
                        spreadRadius: 3,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 30,
                top: 603,
                child: Container(
                  width: 330,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 4,
                        offset: Offset(2, 2),
                        spreadRadius: 3,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 30,
                top: 192,
                child: Container(
                  width: 330,
                  height: 247,
                  decoration: ShapeDecoration(
                    color: Color(0xFFFFE1DD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 4,
                        offset: Offset(2, 2),
                        spreadRadius: 3,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 37,
                top: 36,
                child: Text(
                  '현재 연결중인 이어폰',
                  style: TextStyle(
                    color: Color(0xFF434343),
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 144,
                top: 95,
                child: Text(
                  '유성의 AirPod 2 Pro',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 144,
                top: 117,
                child: Text(
                  '센서 작동 중',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w300,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 195,
                top: 244,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  child: Container(
                    width: 167,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignCenter,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 76,
                top: 411,
                child: Container(
                  width: 231,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 165,
                top: 332,
                child: Container(
                  width: 63,
                  height: 78,
                  decoration: ShapeDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 51,
                top: 615,
                child: Container(width: 23, height: 23, child: Stack()),
              ),
              Positioned(
                left: 119,
                top: 618,
                child: Text(
                  '거북목 탐지 시작/중지',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 30,
                top: 603,
                child: Container(
                  width: 330,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 4,
                        offset: Offset(2, 2),
                        spreadRadius: 3,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 51,
                top: 615,
                child: Container(width: 23, height: 23, child: Stack()),
              ),
              Positioned(
                left: 119,
                top: 618,
                child: Text(
                  '거북목 탐지 시작/중지',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 133,
                top: 93,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(3.14),
                  child: Container(
                    width: 79,
                    height: 42,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://via.placeholder.com/79x42"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 30,
                top: 675,
                child: Container(
                  width: 330,
                  height: 48,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 330,
                          height: 48,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 4,
                                offset: Offset(2, 2),
                                spreadRadius: 3,
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 136,
                        top: 13,
                        child: Text(
                          '사용 설정',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 151,
                top: 463,
                child: Text(
                  '00:00',
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
                left: 201.05,
                top: 285,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.18),
                  child: Container(
                    width: 13,
                    height: 57,
                    decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                  ),
                ),
              ),
              Positioned(
                left: 240,
                top: 272,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.black),
                ),
              ),
              Positioned(
                left: 222,
                top: 290,
                child: Container(
                  width: 22,
                  height: 3,
                  decoration: BoxDecoration(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}