import 'package:app_links/app_links.dart';
import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:mocksum_flutter/view/home/banner/survey_banner.dart';
import 'package:mocksum_flutter/view/home/subpage/connect_guide/connect_guide.dart';
import 'package:mocksum_flutter/view/home/widgets/airpod_modal.dart';
import 'package:mocksum_flutter/view/home/widgets/app_bar.dart';
import 'package:mocksum_flutter/view/home/widgets/bottomsheet.dart';
import 'package:mocksum_flutter/view/home/widgets/neck.dart';
import 'package:mocksum_flutter/view/home/widgets/start_button.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/view/home/widgets/start_button_msg.dart';
import 'package:mocksum_flutter/view/home/widgets/stop_bottomsheet.dart';
import 'package:mocksum_flutter/view/loading.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mocksum_flutter/util/localization_string.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../theme/component/button.dart';
import '../start_position/start_position_view.dart';
import '../../util/responsive.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final appLinks = AppLinks();

  static const storage = FlutterSecureStorage();
  static MyAudioHandler? _audioHandler;
  final InAppReview inAppReview = InAppReview.instance;
  final AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();

  late BannerAd _ad;
  bool _isAdLoaded = false;
  // bool _isPremium = false;
  bool _isLabMode = true;
  bool _stopSheetOpened = false;
  bool _startWidgetClicked = false;


  @override
  void initState() {
    super.initState();
    // print('sadf');
    _initLocalNotification();
    if (_audioHandler == null) {
      _setAudioHandler();
    }
    _amplitudeEventManager.viewEvent('mainpage');
    setState(() {
      _isLabMode = DetectStatus.isLabMode;
    });

    _ad = BannerAd(
        size: AdSize.banner,
        adUnitId: 'ca-app-pub-3940256099942544/2934735716', // 'ca-app-pub-4299841579411814/8948635978',
        listener: BannerAdListener(
            onAdLoaded: (_) {
              setState(() {
                _isAdLoaded = true;
              });
            },
            onAdFailedToLoad: (ad, error) {
              print(error);
              ad.dispose();
            }
        ),
        request: const AdRequest()
    );

    _ad.load();

    final sub = appLinks.uriLinkStream.listen((uri) {
      print(uri);
      if (uri.toString().split('//')[1] == 'start' && !_startWidgetClicked) {
        _startWidgetClicked = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (!Provider.of<UserStatus>(context, listen: false).isLogged && !Provider.of<DetectStatus>(context, listen: false).nowDetecting) {
            return;
          }
          if (Provider.of<DetectStatus>(context, listen: false).detectAvailable) {
            print('push');
            _startWidgetClicked = false;
            Navigator.push(context, MaterialPageRoute(
                builder: (
                    context) => StartPosition(onStart: () {
                  _audioHandler?.play();
                  _amplitudeEventManager.actionEvent('mainpage', 'startdetection');
                },)));
          }
        });
      }
    });

    GlobalTimer.timeEventStream.listen((useSec) {
      // print(useSec);
      if (!Provider.of<UserStatus>(context, listen: false).isPremium && useSec >= 3600) {
        Provider.of<DetectStatus>(context, listen: false).endDetecting();
        _audioHandler?.pause();
        Provider.of<GlobalTimer>(context, listen: false).stopTimer();
        _showPushAlarm();
      }
    });

    DetectStatus.detectAvailableEventStream.listen((flag) {
      if (!flag) {
        if (Provider.of<DetectStatus>(context, listen: false).nowDetecting) {
          Provider.of<GlobalTimer>(context, listen: false).stopTimer();
          if (!_stopSheetOpened) {
            _stopSheetOpened = true;
            showAirpodsBottomSheet();
          }
        }
      } else {
        if (Provider.of<DetectStatus>(context, listen: false).nowDetecting) {
          Provider.of<GlobalTimer>(context, listen: false).startTimer();
        }
      }
    });

    // _decideShowReviewPopup();
  }

  Future<void> _decideShowReviewPopup() async {
    // const storage = FlutterSecureStorage();
    String? hasWroteReview = await storage.read(key: 'hasWroteReview');
    String? executeCount = await storage.read(key: 'executeCount');
    int exeCnt = 0;
    if (executeCount != null) {
      // await storage.write(key: 'executeCount', value: int.parse(executeCount).toString());
      exeCnt = int.parse(executeCount);
    } else {
      await storage.write(key: 'executeCount', value: '1');
      exeCnt = 1;
    }

    print('$exeCnt $hasWroteReview');
    if (exeCnt >= DetectStatus.reviewRequestCount && hasWroteReview != '1') {
      await storage.write(key: 'hasWroteReview', value: '1');
      await showReviewRequestPopUp(context);
    }
  }

  Future<void> _showPushAlarm() async {
    FlutterLocalNotificationsPlugin localNotification =
    FlutterLocalNotificationsPlugin();

    await localNotification.show(0,
        LS.tr('home_view.today_free_time_end'),
        LS.tr('home_view.today_free_time_end_premium'),
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
    setState(() {
      _stopSheetOpened = true;
    });
    showModalBottomSheet(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return const AirpodsConnectlessSheet();
      }
    ).whenComplete(() {
      setState(() {
        _stopSheetOpened = false;
      });
      showSnackbar(LS.tr('home_view.airpods_disconnect_detection_end'));
    });
  }

  void showStopDetectionSheet() async {
    showModalBottomSheet(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return StopDetectionSheet(onStop: () async {
          await Provider.of<DetectStatus>(context, listen: false).endDetecting();
          print('end detection2');
          await _audioHandler?.pause();
          print('end detection');
          _amplitudeEventManager.actionEvent('mainpage', 'enddetection', Provider.of<GlobalTimer>(context, listen: false).getDetectionTime(), GlobalTimer.alarmCount);
          Provider.of<GlobalTimer>(context, listen: false).stopTimer();
          // const storage = FlutterSecureStorage();
          String? executeCount = await storage.read(key: 'executeCount');
          await storage.write(key: 'executeCount', value: (int.parse(executeCount ?? '0')+1).toString());
          Navigator.push(
              context, MaterialPageRoute(builder: (
              context) => const Loading()));
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

  Future<void> showReviewRequestPopUp(BuildContext context) async {
    Responsive res = Responsive(context);
    print(DetectStatus.hasWroteReview);
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
                child: TextDefault(content: LS.tr('home_view.review'), fontSize: 18, isBold: true),
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
                        text: LS.tr('home_view.review_later')
                      ),
                      Button(
                        onPressed: () async {
                          DetectStatus.setHasWroteReview(true);
                          inAppReview.openStoreListing(appStoreId: '6553973734');
                          Navigator.of(context).pop();
                        },
                        backgroundColor: const Color(0xFF236EF3),
                        color: Colors.white,
                        width: res.percentWidth(33),
                        padding: res.percentWidth(4),
                        text: LS.tr('home_view.review_ok')
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

    return Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: HomeAppBar()
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: res.deviceWidth,
                  // decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
                  child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: res.percentHeight(2),),
                          GestureDetector(
                            onTap: () {
                              // if (!detectStatus.detectAvailable) {
                              //   switch (OpenSettingsPlus.shared) {
                              //     case OpenSettingsPlusIOS settings: settings.bluetooth();
                              //     default: throw Exception('Platform not supported');
                              //   }
                              // }
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (
                                  context) => const ConnectGuide()));
                            },
                            child: SizedBox(
                                width: res.percentWidth(85),
                                height: res.percentWidth(85)*0.3,
                                child: Stack(
                                  children: [
                                    Positioned(
                                        child: Row(
                                          children: [
                                            const AssetIcon('infoCircle', size: 4, color: Color(0xFF236EF3),),
                                            const SizedBox(width: 5,),
                                            TextDefault(
                                              content: 'connect_guide.guide'.tr(),
                                              fontSize: 13,
                                              isBold: false,
                                              fontColor: const Color(0xFF236EF3),
                                            ),
                                          ],
                                        )
                                    ),
                                    Positioned(
                                      // left: responsive.percentWidth(7.5),
                                      top: res.percentWidth(6),
                                      child: AirpodsModal(isRotating: !detectStatus.detectAvailable,),
                                    ),
                                    Positioned(
                                      left: res.percentWidth(23),
                                      top: res.percentWidth(9),
                                      child: TextDefault(
                                        content: detectStatus.detectAvailable ? LS.tr('home_view.airpods_connected') : LS.tr('home_view.airpods_disconnected'),
                                        fontSize: 18,
                                        isBold: true,
                                      ),
                                    ),
                                    Positioned(
                                      left: res.percentWidth(23),
                                      top: res.percentWidth(9)+25,
                                      child: TextDefault(
                                        content: detectStatus.detectAvailable ? LS.tr('home_view.sensor_operation') : LS.tr('home_view.sensor_no_device'),
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
                                      content: detectStatus.nowDetecting ? LS.tr('home_view.detection_doing') : LS.tr('home_view.detection_start_ask'),
                                      fontSize: 27,
                                      isBold: true,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: res.percentHeight(2.5),),
                                  const Neck(),
                                  SizedBox(height: res.percentHeight(2),),
                                  Stack(
                                    children: [
                                      StartButton(
                                          onPressed: () async {
                                            print('asdf');
                                            if (!detectStatus.detectAvailable && !detectStatus.nowDetecting) {
                                              showSnackbar(LS.tr('home_view.airpods_connect_ask'));
                                            } else if (!detectStatus.nowDetecting) {
                                              if (!userStatus.isPremium && globalTimer.useSec >= 3600) {
                                                showSnackbar(LS.tr('home_view.end_today_free_time'));
                                              } else {
                                                Navigator.push(context, MaterialPageRoute(
                                                    builder: (
                                                        context) => StartPosition(onStart: () async {
                                                      _audioHandler?.play();
                                                      _amplitudeEventManager.actionEvent('mainpage', 'startdetection');

                                                      String? refreshToken = await storage.read(key: 'refreshToken');
                                                      if (refreshToken != null) {
                                                        Response resForToken = await HistoryStatus
                                                            .dio.post(
                                                            '$HistoryStatus.serverAddress/members/token',
                                                            data: {
                                                              'refreshToken': refreshToken
                                                            });
                                                        if (resForToken.statusCode! ~/
                                                            100 == 2) {
                                                          String accessTokenNew = resForToken
                                                              .data['data']['accessToken'] ??
                                                              '';
                                                          String refreshTokenNew = resForToken
                                                              .data['data']['refreshToken'] ??
                                                              '';

                                                          if (accessTokenNew != '') {
                                                            HistoryStatus.dio.options
                                                                .headers["authorization"] =
                                                            "bearer $accessTokenNew";
                                                            await storage.write(
                                                                key: 'accessToken',
                                                                value: accessTokenNew);
                                                            await storage.write(
                                                                key: 'refreshToken',
                                                                value: refreshTokenNew);
                                                          }
                                                        }
                                                      }
                                                    })));
                                              }
                                            } else {
                                              showStopDetectionSheet();
                                            }
                                          },
                                          isDisabled: !detectStatus.detectAvailable,
                                          isRunning: detectStatus.nowDetecting,
                                          useTime: '${TimeConvert.sec2TimeFormat(globalTimer.useSec)}${userStatus.isPremium ? '' : '/1:00:00'}'
                                      ),
                                      // const StartButtonMsg(message: 'Press Start for bad posture alert!'),
                                      if (detectStatus.detectAvailable && !detectStatus.nowDetecting)
                                        const StartButtonMsg(message: 'Press Start for bad posture alert!')
                                      else if (detectStatus.detectAvailable && detectStatus.nowDetecting)
                                        const StartButtonMsg(message: 'Pressing \'Stop\' will analyse your posture!')
                                    ],
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
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        const AssetIcon('maximize', size: 6,),
                                        const SizedBox(width: 5,),
                                        TextDefault(
                                          content: LS.tr('home_view.turtle_neck_forward_backward_detection'),
                                          fontSize: 14,
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
                          SizedBox(height: res.percentHeight(2),),
                          // const SurveyBanner()
                        ],
                      )
                  ),
                )
            )
        ),
      );
  }
}