import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/page_navbar.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/service/audio_handler.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/service/history_provider.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/util/time_convert.dart';
import 'package:mocksum_flutter/view/history/history_view.dart';
import 'package:mocksum_flutter/view/home/widgets/airpod_modal.dart';
import 'package:mocksum_flutter/view/home/widgets/app_bar.dart';
import 'package:mocksum_flutter/view/home/widgets/bottomsheet.dart';
import 'package:mocksum_flutter/view/home/widgets/neck.dart';
import 'package:mocksum_flutter/view/home/widgets/start_button.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/view/home/widgets/stop_bottomsheet.dart';
import 'package:mocksum_flutter/view/loading.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../theme/component/button.dart';
import '../start_position/start_position_view.dart';
import '../../util/responsive.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  MyAudioHandler? _audioHandler;
  final InAppReview inAppReview = InAppReview.instance;
  final AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();

  late BannerAd _ad;
  bool _isAdLoaded = true;
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
        adUnitId: 'ca-app-pub-3940256099942544/6300978111', //'ca-app-pub-4299841579411814/1760857231',
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
        request: const AdRequest()
    );

    _ad.load();

    GlobalTimer.timeEventStream.listen((useSec) {
      if (useSec >= 3600) {
        Provider.of<DetectStatus>(context, listen: false).endDetecting();
        _audioHandler?.pause();
        Provider.of<GlobalTimer>(context, listen: false).stopTimer();
        Provider.of<HistoryStatus>(context, listen: false).resetShouldChangeData();
        _showPushAlarm();
      }
    });

    DetectStatus.detectAvailableEventStream.listen((flag) {
      if (!flag) {
        showAirpodsBottomSheet();
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

  void showAirpodsBottomSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return const AirpodsConnectlessSheet();
      }
    ).whenComplete(() {
      showSnackbar('에어팟 연결이 끊겨서 탐지가 중단됐어요.');
    });
  }

  void showStopDetectionSheet() {
    showModalBottomSheet(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return StopDetectionSheet(onStop: () async {
          int executeCount = await Provider.of<DetectStatus>(context, listen: false).endDetecting();
          await _audioHandler?.pause();
          _amplitudeEventManager.actionEvent('mainpage', 'enddetection');
          Provider.of<GlobalTimer>(context, listen: false).stopTimer();
          Navigator.push(
              context, MaterialPageRoute(builder: (
              context) => const Loading()));
          if (executeCount >= DetectStatus.reviewRequestCount) {
            showReviewRequestPopUp(context);
          }
        });
      }
    );
  }

  void showSnackbar(String msg) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: const Color(0xFFF25959),
                borderRadius: BorderRadius.circular(10)
            ),
            alignment: Alignment.center,
            child: const AssetIcon('close', color: Colors.white, size: 20,),
          ),
          const SizedBox(width: 10,),
          TextDefault(
            content: msg,
            fontSize: 16,
            isBold: false,
            fontColor: Colors.white,
          )
        ],
      ),
      backgroundColor: const Color(0xFF323238),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showReviewRequestPopUp(BuildContext context) {
    Responsive res = Responsive(context);

    if (!DetectStatus.hasWroteReview) {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              content: Container(
                margin: EdgeInsets.only(top: res.percentHeight(0.5)),
                child: const TextDefault(content: '앱 리뷰를 남겨주세요!\n여러분의 리뷰는 개발자에게 큰 힘이 됩니다.', fontSize: 18, isBold: true),
              ),
              actions: [
                SizedBox(
                  width: res.percentWidth(80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Button(
                          onPressed: () {
                            DetectStatus.setHasWroteReview(false);
                            Navigator.of(context).pop();
                          },
                          backgroundColor: const Color(0xFF8991A0),
                          color: Colors.white,
                          width: res.percentWidth(33),
                          padding: res.percentWidth(4),
                          text: '괜찮아요'
                      ),
                      Button(
                          onPressed: () async {
                            DetectStatus.setHasWroteReview(true);
                            inAppReview.openStoreListing(appStoreId: '6553973734');
                          },
                          backgroundColor: const Color(0xFF236EF3),
                          color: Colors.white,
                          width: res.percentWidth(33),
                          padding: res.percentWidth(4),
                          text: '좋아요'
                      ),
                    ],
                  ),
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
    Responsive res = Responsive(context);
    DetectStatus detectStatus = context.watch();
    UserStatus userStatus = context.watch();
    GlobalTimer globalTimer = context.watch();

    return SafeArea(
      child: Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: HomeAppBar()
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: res.deviceWidth,
              // decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
              child: Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!detectStatus.detectAvailable) {
                            switch (OpenSettingsPlus.shared) {
                              case OpenSettingsPlusIOS settings: settings.bluetooth();
                              default: throw Exception('Platform not supported');
                            }
                          }
                        },
                        child: SizedBox(
                          width: res.percentWidth(85),
                          height: res.percentWidth(85)*0.3,
                          child: Stack(
                            children: [
                              Positioned(
                                // left: responsive.percentWidth(7.5),
                                top: res.percentWidth(5),
                                child: AirpodsModal(isRotating: !detectStatus.detectAvailable,),
                              ),
                              Positioned(
                                left: res.percentWidth(23),
                                top: res.percentWidth(8),
                                child: TextDefault(
                                  content: detectStatus.detectAvailable ? '에어팟을 연결했어요' : '에어팟을 연결해주세요',
                                  fontSize: 18,
                                  isBold: true,
                                ),
                              ),
                              Positioned(
                                left: res.percentWidth(23),
                                top: res.percentWidth(8)+25,
                                child: TextDefault(
                                  content: detectStatus.detectAvailable ? '센서 작동 중' : '연결 기기 없음',
                                  fontSize: 14,
                                  isBold: false,
                                  fontColor: const Color(0xFF236EF3),
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                      Container(
                          width: res.percentWidth(90),
                          height: res.percentWidth(97),
                          margin: const EdgeInsets.only(top: 20),
                          decoration: BoxDecoration(
                            color: !detectStatus.isNowTurtle ? const Color(0xFFD8E2F9) : const Color(0xFFF25959),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: res.percentWidth(85),
                                padding: EdgeInsets.only(top: res.percentWidth(7.5), left: res.percentWidth(7.5)),
                                child: TextDefault(
                                  content: detectStatus.nowDetecting ? '자세 탐지를\n하고 있어요' : '자세 탐지를\n시작할까요?',
                                  fontSize: 27,
                                  isBold: true,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: res.percentHeight(2.5),),
                              const Neck(),
                              SizedBox(height: res.percentHeight(2),),
                              StartButton(
                                onPressed: () async {
                                  print('asdf');
                                  if (!detectStatus.detectAvailable) {
                                    showSnackbar('에어팟을 연결해주세요.');
                                  } else if (!detectStatus.nowDetecting) {
                                    if (!userStatus.isPremium && globalTimer.useSec >= 3600) {
                                      showSnackbar('오늘의 사용 제한 시간이 끝났습니다.');
                                    } else {
                                      _audioHandler?.play();
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (
                                              context) => const StartPosition()));
                                      _amplitudeEventManager.actionEvent('mainpage', 'startdetection');
                                    }
                                  } else {
                                    showStopDetectionSheet();
                                  }
                                },
                                isDisabled: !detectStatus.detectAvailable,
                                isRunning: detectStatus.nowDetecting,
                                useTime: '${TimeConvert.sec2TimeFormat(globalTimer.useSec)}${userStatus.isPremium ? '' : '/1:00:00'}'
                              ),
                            ],
                          )
                      ),
                      SizedBox(height: res.percentHeight(2)),
                      WhiteContainer(
                        width: 90,
                        padding: EdgeInsets.symmetric(horizontal: res.percentWidth(3), vertical: res.percentHeight(1)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Row(
                                  children: [
                                    AssetIcon('maximize', size: 6,),
                                    SizedBox(width: 5,),
                                    TextDefault(
                                      content: '거북목, 뒤로 빠짐 이동 감지',
                                      fontSize: 16,
                                      isBold: false,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            CupertinoSwitch(
                              value: _isLabMode,
                              activeColor: CupertinoColors.activeBlue,
                              onChanged: (bool value) {
                                setState(() {
                                  _isLabMode = value;
                                  DetectStatus.isLabMode = value;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      userStatus.isPremium ? const SizedBox() : Container(
                        margin: EdgeInsets.only(top: res.percentHeight(1.5)),
                        width: _ad.size.width.toDouble(),
                        height: _ad.size.height.toDouble(),
                        alignment: Alignment.center,
                        child: AdWidget(ad: _ad),
                      ),
                    ],
                  )
              ),
            )
        ),
      )
    );
  }
}