import 'package:amplitude_flutter/amplitude.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/start_position.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/util/audio_handler.dart';
import 'package:mocksum_flutter/util/global_timer.dart';
import 'package:mocksum_flutter/util/history_provider.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
import 'package:mocksum_flutter/util/user_provider.dart';
import 'package:mocksum_flutter/widgets/text_default.dart';
import 'neck.dart';
import 'util/responsive.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  MainState createState() => MainState();
}

class MainState extends State<MainPage> {

  static const _kFontFam = 'MyFlutterApp';
  static const String? _kFontPkg = null;
  static const IconData question_circle_o = IconData(0xf29c, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  MyAudioHandler? _audioHandler;
  final InAppReview inAppReview = InAppReview.instance;
  final AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();

  late BannerAd _ad;
  bool _isAdLoaded = false;
  // bool _isPremium = false;
  bool _isLabMode = false;


  @override
  void initState() {
    super.initState();
    // print('sadf');
    _initLocalNotification();
    _setAudioHandler();
    _amplitudeEventManager.viewEvent('mainpage');

    _ad = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-4299841579411814/1760857231',
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }
      ),
      request: AdRequest()
    );

    _ad.load();

    // Future.delayed(Duration.zero, () {
    //   //showReviewRequestPopUp(context);
    //   // bool isPremium = await UserStatus.getUserIsPremium();
    //   // print('asdf $isPremium');
    //   // setState(() {
    //   //   print('asdf2 $isPremium');
    //   //   _isPremium = isPremium;
    //   // });
    // });
    
    GlobalTimer.timeEventStream.listen((useMin) {
      if (useMin >= 120) {
        Provider.of<DetectStatus>(context, listen: false).endDetecting();
        _audioHandler?.pause();
        Provider.of<GlobalTimer>(context, listen: false).stopTimer();
        Provider.of<HistoryStatus>(context, listen: false).resetShouldChangeData();
        _showPushAlarm();
      }
    });
  }

  Future<void> _showPushAlarm() async {
    FlutterLocalNotificationsPlugin localNotification =
    FlutterLocalNotificationsPlugin();

    await localNotification.show(0,
      '오늘의 무료 사용시간 종료',
      '시간제한 없이 쓰고 싶다면 프리미엄 플랜을 사용해보세요!',
      _details
    );
  }

  final NotificationDetails _details = const NotificationDetails(
      android: AndroidNotificationDetails('temp1', 'asdf'),
      iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true
      )
  );


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


  void _setAudioHandler() async {
    // print('sadfasdf');
    _audioHandler ??= await AudioService.init(
          builder: () => MyAudioHandler(),
          config: const AudioServiceConfig(
            androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
            androidNotificationChannelName: 'Music playback',
          )
      );
  }

  void showReviewRequestPopUp(BuildContext context) {
    if (!DetectStatus.hasWroteReview) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text('앱 리뷰를 남겨주세요!\n여러분의 리뷰는 개발자에게 큰 힘이 됩니다.',
              style: TextStyle(
                color: const Color(0xFF434343),
                fontSize: MediaQuery.of(context).size.width*0.04,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w300,
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 40),
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    shadowColor: const Color(0x19000000),
                    side: const BorderSide(
                        width: 1,
                        color: Colors.black
                    )
                ),
                onPressed: () async {
                  DetectStatus.setHasWroteReview(true);
                  inAppReview.openStoreListing(appStoreId: '6553973734');
                },
                child: const Text('좋아요')
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 40),
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    shadowColor: const Color(0x19000000),
                    side: const BorderSide(
                        width: 1,
                        color: Colors.black
                    )
                ),
                onPressed: () {
                  DetectStatus.setHasWroteReview(false);
                  Navigator.of(context).pop();
                },
                child: const Text('다음에 할게요')
              ),
            ],
          );
        }
      );
    }
  }

  void goToStoreReview() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.openStoreListing(appStoreId: '6553973734');
    }
  }

  @override
  void dispose() {
    _ad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    DetectStatus detectStatus = Provider.of(context);
    UserStatus userStatus = Provider.of(context);
    HistoryStatus historyStatus = Provider.of(context);
    GlobalTimer globalTimer = Provider.of(context);

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
                      child: const TextDefault(content: '에어팟 연결 상태', fontSize: 18, isBold: true),
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
                                child: TextDefault(
                                  content: detectStatus.detectAvailable ? '에어팟이 연결되었어요' : '에어팟을 연결해주세요',
                                  fontSize: 18,
                                  isBold: true,
                                ),
                              ),
                              Positioned(
                                left: responsive.percentWidth(30),
                                top: responsive.percentWidth(7)+25,
                                child: TextDefault(
                                  content: detectStatus.detectAvailable ? '센서 작동 중' : '센서를 찾을 수 없어요',
                                  fontSize: 14,
                                  isBold: false,
                                ),
                              ),
                            ],
                          )
                      ),
                    ),
                    const Neck(),
                    SizedBox(height: responsive.percentHeight(5)),
                    !userStatus.isPremium ?
                    Container(
                      margin: EdgeInsets.only(bottom: responsive.percentHeight(1)),
                      alignment: Alignment.center,
                      child: TextDefault(content: '사용 시간: ${globalTimer.useMin}/120분', fontSize: 15, isBold: false,)
                    ) : const SizedBox(),
                    // SizedBox(height: responsive.percentHeight(7)),

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
                          onPressed: () async {
                            if (!detectStatus.detectAvailable) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('에어팟을 연결해주세요'),
                                  duration: Duration(seconds: 2),
                                )
                              );
                            } else if (!detectStatus.nowDetecting) {
                              if (globalTimer.useMin >= 120) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('오늘의 2시간 무료사용시간이 종료되었습니다.'),
                                      duration: Duration(seconds: 2),
                                    )
                                );
                              } else {
                                _audioHandler?.play();
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (
                                        context) => const StartPosition()));
                                _amplitudeEventManager.actionEvent('mainpage', 'startdetection');
                              }
                            } else {
                              int executeCount = await detectStatus.endDetecting();
                              _audioHandler?.pause();
                              _amplitudeEventManager.actionEvent('mainpage', 'enddetection');
                              globalTimer.stopTimer();
                              historyStatus.resetShouldChangeData();
                              if (executeCount >= DetectStatus.reviewRequestCount) {
                                showReviewRequestPopUp(context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(responsive.percentWidth(85), 40),
                            backgroundColor: detectStatus.detectAvailable ? Colors.white : Colors.grey,
                            surfaceTintColor: Colors.white,
                            shadowColor: const Color(0x19000000)
                          ),
                          label: TextDefault(
                            content: detectStatus.nowDetecting ? '거북목 탐지 중지' : '거북목 탐지 시작',
                            fontSize: 18,
                            isBold: true,
                          ),
                          icon: detectStatus.nowDetecting ? const Icon(Icons.pause, color: Colors.black) : const Icon(Icons.play_arrow, color: Colors.black,),
                        )
                    ),

                    Container(
                      width: responsive.percentWidth(85),
                      margin: EdgeInsets.only(bottom: responsive.percentHeight(2), top: responsive.percentHeight(1)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              TextDefault(
                                content: '(Beta) 고개 수평이동 감지',
                                fontSize: 16,
                                isBold: true,
                              ),
                              // const SizedBox(width: 2,),
                              // GestureDetector(
                              //   onTap: () {
                              //
                              //   },
                              //   child: const Icon(question_circle_o, color: Colors.black),
                              // )
                            ],
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _isLabMode,
                              onChanged: (bool value) {
                                setState(() {
                                  _isLabMode = value;
                                  DetectStatus.isLabMode = value;
                                });
                              },
                            )
                          ),
                        ],
                      ),
                    ),
                    userStatus.isPremium ? const SizedBox() : Container(
                      child: AdWidget(ad: _ad),
                      width: _ad.size.width.toDouble(),
                      height: _ad.size.height.toDouble(),
                      alignment: Alignment.center,
                    ),
                  ],
                )
            ),
          )
      ),
    );
  }
}