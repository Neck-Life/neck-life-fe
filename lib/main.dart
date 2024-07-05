import 'package:flutter/material.dart';
import 'package:mocksum_flutter/start_position.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
import 'neck.dart';
import 'util/responsive.dart';
import 'package:provider/provider.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mocksum_flutter/tutorials.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetectStatus(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF9F9F9)
        ),
        home: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  MainState createState() => MainState();
}

class MainState extends State<MainPage> {
  final Uri _url = Uri.parse('https://forms.gle/bi2YK5wfAFXQN4DKA');
  bool _firstLaunch = false;

  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          content: const Tutorials(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('튜토리얼 끝내기')
            )
          ],
        );
      }
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch');
    }
  }

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

  void _getNowIsFirstLaunch() async {
    final storage = FlutterSecureStorage();
    String? first = await storage.read(key: 'first');
    if (first == null) {
      _firstLaunch = true;
      await storage.write(key: 'first', value: '1');
    }
    // _firstLaunch = true;
  }

  @override
  void initState() {
    super.initState();
    _initLocalNotification();
    _getNowIsFirstLaunch();
    Future.delayed(Duration.zero, () {
      if (_firstLaunch) {
        _showTutorial(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    DetectStatus detectStatus = Provider.of(context);

    return Scaffold(
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: responsive.deviceWidth,
              decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
              child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: responsive.percentHeight(5)),
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
                            AppSettings.openAppSettings();
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
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: responsive.percentHeight(5)),
                        child: Text(
                          '00:00',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: responsive.fontSize(30),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
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
                              if (!detectStatus.nowDetecting) {
                                Navigator.push(context, MaterialPageRoute(builder: (
                                    context) => const StartPosition()));
                              } else {
                                detectStatus.endDetecting();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(responsive.percentWidth(85), 40),
                                backgroundColor: Colors.white,
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
                      SizedBox(height: responsive.percentHeight(10)),
                      GestureDetector(
                        onTap: _launchUrl,
                        child: const Text("피드백 보내기"),
                      )
                    ],
                  )
              ),
            )
        )
    );
  }
}
