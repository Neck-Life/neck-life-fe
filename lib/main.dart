
import 'package:flutter/material.dart';
import 'package:turtleneck/start_position.dart';
import 'util/responsive.dart';

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
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9)
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  MainState createState() => MainState();
}

class MainState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
        body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: responsive.deviceWidth,
          height: responsive.deviceHeight,
          decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Container(
                  width: responsive.percentWidth(85),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: const Text('현재 연결 중인 이어폰',
                    style: TextStyle(
                      color: Color(0xFF434343),
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                ),
                Container(
                  width: responsive.percentWidth(85),
                  height: 100,
                  decoration: ShapeDecoration(
                    color: Colors.white,
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
                  child: Stack(
                    children: [
                      Positioned(
                          left: responsive.percentWidth(5),
                          top: 30,
                          child: Image.asset("assets/airpod.png")
                      ),
                      Positioned(
                        left: responsive.percentWidth(30),
                        top: 30,
                        child: const Text(
                          '유성의 AirPod 2 Pro',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Positioned(
                        left: responsive.percentWidth(30),
                        top: 55,
                        child: const Text(
                          '센서 작동 중',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  )
                ),
                Container(
                  width: responsive.percentWidth(85),
                  height: 250,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFE2DD),
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
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 50),
                  child: const Text(
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
                Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
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
                  child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const StartPosition()));
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(responsive.percentWidth(85), 40),
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        shadowColor: const Color(0x19000000)
                      ),
                      label: const Text(
                        '거북목 탐지 시작',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 0,
                        ),
                      ),
                    icon: const Icon(Icons.play_arrow, color: Colors.black,),
                  )
                )
              ],
            )
          ),
        )
      )
    );
  }
}
