import 'package:flutter/material.dart';
import 'package:mocksum_flutter/start_position.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
import 'neck.dart';
import 'util/responsive.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_settings_plus/open_settings_plus.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  MainState createState() => MainState();
}

class MainState extends State<MainPage> {
  // bool _firstLaunch = false;

  Future<void> _initLocalNotification() async {
    FlutterLocalNotificationsPlugin localNotification =
    FlutterLocalNotificationsPlugin();
    AndroidInitializationSettings initSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings initSettingsIOS =
    const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );
    await localNotification.initialize(
      initSettings,
    );
  }

  @override
  void initState() {
    super.initState();
    _initLocalNotification();
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    DetectStatus detectStatus = Provider.of(context);

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: responsive.deviceWidth,
          decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
          child: Center(
              child: Column(
                children: [
                  SizedBox(height: responsive.percentHeight(7)),
                  Container(
                    width: responsive.percentWidth(85),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text('에어팟 연결 상태',
                      style: TextStyle(
                        color: const Color(0xFF434343),
                        fontSize: responsive.fontSize(18),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!detectStatus.detectAvailable) {
                        switch (OpenSettingsPlus.shared) {
                          case OpenSettingsPlusIOS settings: settings.bluetooth();
                          default: throw Exception('Platform not supported');
                        }
                      }
                    },
                    child: Container(
                        width: responsive.percentWidth(85),
                        height: responsive.percentWidth(85)*0.3,
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
                                top: responsive.percentWidth(7),
                                child: Image.asset("assets/airpod.png")
                            ),
                            Positioned(
                              left: responsive.percentWidth(30),
                              top: responsive.percentWidth(7),
                              child: Text(
                                detectStatus.detectAvailable ? '에어팟이 연결되었어요' : '에어팟을 연결해주세요',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: responsive.fontSize(18),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Positioned(
                              left: responsive.percentWidth(30),
                              top: responsive.percentWidth(7)+25,
                              child: Text(
                                detectStatus.detectAvailable ? '센서 작동 중' : '센서를 찾을 수 없어요',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: responsive.fontSize(14),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        )
                    ),
                  ),
                  const Neck(),
                  SizedBox(height: 20+responsive.percentHeight(5)),
                  Container(
                      decoration: ShapeDecoration(
                        color: detectStatus.detectAvailable ? Colors.white : Colors.grey,
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
                          if (!detectStatus.detectAvailable) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('에어팟을 연결해주세요'),
                                duration: Duration(seconds: 2),
                              )
                            );
                          } else if (!detectStatus.nowDetecting) {
                            Navigator.push(context, MaterialPageRoute(builder: (
                                context) => const StartPosition()));
                          } else {
                            detectStatus.endDetecting();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(responsive.percentWidth(85), 40),
                            backgroundColor: detectStatus.detectAvailable ? Colors.white : Colors.grey,
                            surfaceTintColor: Colors.white,
                            shadowColor: const Color(0x19000000)
                        ),
                        label: Text(
                          detectStatus.nowDetecting ? '거북목 탐지 중지' : '거북목 탐지 시작',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: responsive.fontSize(18),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: detectStatus.nowDetecting ? const Icon(Icons.pause, color: Colors.black) : const Icon(Icons.play_arrow, color: Colors.black,),
                      )
                  ),
                  // SizedBox(height: responsive.percentHeight(10)),
                ],
              )
          ),
        )
    );
  }
}