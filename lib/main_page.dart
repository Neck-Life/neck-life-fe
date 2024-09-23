import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/start_position.dart';
import 'package:mocksum_flutter/util/audio_handler.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
import 'neck.dart';
import 'util/responsive.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'util/adMob/reward_admob.dart'; // 분리된 RewardedAdButton import

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  MainState createState() => MainState();
}

class MainState extends State<MainPage> {

  final RewardedAdManager adManager = RewardedAdManager(); // RewardedAdManager 생성

  bool _isHelpTextOpend = false;
  // LocationHandler? _locationHandler;
  late MyAudioHandler _audioHandler;
  // final AudioPlayer _nodiAudioPlayer = AudioPlayer();

  // var item = const MediaItem(
  //   id: 'assets/noti.mp3',
  //   title: 'noti_sound',
  // );

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

  // void _setNotiAudioHandler() async {
  //   await _nodiAudioPlayer.setAsset('assets/noti.mp3');
  // }

  void _setAudioHandler() async {
    _audioHandler = await AudioService.init(
        builder: () => MyAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
          androidNotificationChannelName: 'Music playback',
        )
    );

    // _audioHandler.addQueueItem(item);

    // _notiAudioHandler = await AudioService.init(
    //     builder: () => NotiAudioHandler(),
    //     config: const AudioServiceConfig(
    //       androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
    //       androidNotificationChannelName: 'Music playback',
    //     )
    // );

    // _audioHandler.play();
    // _audioHandler?.setRepeatMode(AudioServiceRepeatMode.one);
    _audioHandler.customEventStream.listen((data) {
      print(data);
      if (data == 'turtle') {
        // _nodiAudioPlayer.play();
        // _audioHandler.skipToNext();
        // _audioHandler.play();
      }
      if (data == 'end') {
        // _audioHandler.pause();
      }
    });
    // _notiAudioHandler?.play();
  }

  // void _skiptonect() {
  //   if (_audioHandler != null) {
  //     _audioHandler.skipToNext();
  //     print('fuck');
  //   }
  // }


  @override
  void initState() {
    super.initState();
    _initLocalNotification();
    _setAudioHandler();
    // _setNotiAudioHandler();
    // _locationHandler = LocationHandler();
    // _setAudioHandler();

  }

  @override
  void dispose() {
    // _locationHandler?.endAllDetection();
    // _locationHandler = null;
    super.dispose();
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
                              // _locationHandler?.startBackgroundDetection();
                              _audioHandler.play();
                              // _skiptonect();
                              Navigator.push(context, MaterialPageRoute(builder: (
                                  context) => const StartPosition()));
                            } else {
                              detectStatus.endDetecting();
                              // _locationHandler?.endBackgroundDetection();
                              _audioHandler.pause();
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
                    SizedBox(height: responsive.percentHeight(7)),
                    // 리워드 광고 버튼 (별도의 파일에서 가져옴)
                    RewardedAdButton(adManager: adManager),
                    // GestureDetector(
                    //   child: Text(
                    //     '* 에어팟을 연결해도 작동이 안되나요?',
                    //     style: TextStyle(
                    //       color: Colors.black,
                    //       fontSize: responsive.fontSize(12),
                    //       fontFamily: 'Inter',
                    //       fontWeight: FontWeight.w300,
                    //     ),
                    //   ),
                    //   onTap: () {
                    //     setState(() {
                    //       _isHelpTextOpend = !_isHelpTextOpend;
                    //     });
                    //   },
                    // ),
                    // Text(
                    //   _isHelpTextOpend ? '- 현재 아이폰 외에 다른 기기와도 에어팟이 연결되어있다면 이를 끊어주세요' : '',
                    //   style: TextStyle(
                    //     color: Colors.black,
                    //     fontSize: responsive.fontSize(10),
                    //     fontFamily: 'Inter',
                    //     fontWeight: FontWeight.w300,
                    //   ),
                    // ),
                    // Text(
                    //   _isHelpTextOpend ? '- 위 사항의 문제가 아니라면 음악이나 영상을 틀어 \n소리 재생을 확인한 후 앱을 켜보세요' : '',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     color: Colors.black,
                    //     fontSize: responsive.fontSize(10),
                    //     fontFamily: 'Inter',
                    //     fontWeight: FontWeight.w300,
                    //   ),
                    // ),
                  ],
                )
            ),
          )
      ),
    );
  }
}