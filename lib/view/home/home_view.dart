import 'dart:developer';

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
import 'package:mocksum_flutter/view/home/banner/survey_banner.dart';
import 'package:mocksum_flutter/view/home/subpage/connect_guide/connect_guide.dart';
import 'package:mocksum_flutter/view/home/widgets/airpod_modal.dart';
import 'package:mocksum_flutter/view/home/widgets/app_bar.dart';
import 'package:mocksum_flutter/view/home/widgets/banner_carousel.dart';
import 'package:mocksum_flutter/view/home/widgets/bottomsheet.dart';
import 'package:mocksum_flutter/view/home/widgets/neck.dart';
import 'package:mocksum_flutter/view/home/widgets/start_button.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/view/home/widgets/start_button_msg.dart';
import 'package:mocksum_flutter/view/home/widgets/stop_bottomsheet.dart';
import 'package:mocksum_flutter/view/loading.dart';
import 'package:mocksum_flutter/view/use_env_ask/user_env_ask_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mocksum_flutter/util/localization_string.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:live_activities/live_activities.dart';

import '../../main.dart';
import '../../page_navbar.dart';
import '../../service/stretching_timer.dart';
import '../../theme/component/button.dart';
import '../../util/ad_manager.dart';
import '../setting/subpages/alarm_setting/alarm_setting_view.dart';
import '../start_position/start_position_view.dart';
import '../../util/responsive.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver {

  final appLinks = AppLinks();

  // static const storage = FlutterSecureStorage();
  static MyAudioHandler? audioHandler;
  final InAppReview inAppReview = InAppReview.instance;
  final AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();
  // final DynamicIslandManager diManager = DynamicIslandManager(channelKey: 'NECKLIFEDI');
  // final _liveActivitiesPlugin = LiveActivities();
  String? activityID;

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
    WidgetsBinding.instance.addObserver(this);
    final now = DateTime.now();
    _initLocalNotification();
    if (audioHandler == null) {
      _setAudioHandler();
    }
    _amplitudeEventManager.viewEvent('mainpage');
    setState(() {
      _isLabMode = DetectStatus.isLabMode;
    });

    // _liveActivitiesPlugin.init(appGroupId: "group.necklifewidget");

    _ad = AdManager().getBannerAd(true, 0);
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
                    context) => UserEnvAsk(onStart: (useTimeLimit, detectionMin) async {
                  audioHandler?.play();

                  DetectStatus detectStatus = Provider.of<DetectStatus>(context, listen: false);
                  _amplitudeEventManager.actionEvent('mainpage', 'startdetection', detectionMin, 0, {
                    'sensitivity': detectStatus.sensitivity,
                    'alarmGap': detectStatus.alarmGap,
                    'bgSoundActive': detectStatus.bgSoundActive,
                    'volume': detectStatus.soundVolume,
                    'pushNotiActive': detectStatus.pushNotiAvtive,
                    'useHorizontalMove': detectStatus.useHorizontalMove,
                    'env': detectStatus.userEnvType.typeString
                  });

                  String? refreshToken = await storage.read(key: 'refreshToken');
                  if (refreshToken != null) {
                    Response resForToken = await HistoryStatus
                        .dio.post(
                        '${HistoryStatus.serverAddress}/members/token',
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
                  // final id = await _liveActivitiesPlugin.createActivity(
                  //     DynamicIslandStopwatchDataModel(
                  //         elapsedSeconds: 0,
                  //         useTimeLimit: useTimeLimit,
                  //         detectionMin: detectionMin
                  //     ).toMap()
                  // );
                  // setState(() {
                  //   activityID = id;
                  // });
                },)));
          }
        });
      }
    });

    GlobalTimer.timeEventStream.listen((useSec) {

      // if (activityID != null) {
      //   _liveActivitiesPlugin.updateActivity(
      //     activityID!,
      //     DynamicIslandStopwatchDataModel(
      //         elapsedSeconds: useSec - Provider
      //             .of<GlobalTimer>(context, listen: false)
      //             .secOnStart,
      //         useTimeLimit: Provider
      //             .of<DetectStatus>(context, listen: false)
      //             .useTimeLimit,
      //         detectionMin: Provider
      //             .of<DetectStatus>(context, listen: false)
      //             .detectionMin
      //     ).toMap()
      //   );
      // }
      // print(useSec);
      if (!Provider.of<UserStatus>(context, listen: false).isPremium && useSec >= 3600) {
        Provider.of<GlobalTimer>(context, listen: false).stopTimer();
        Provider.of<StretchingTimer>(context, listen: false).cancelTimer();
        Provider.of<DetectStatus>(context, listen: false).endDetecting();
        audioHandler?.pause();
        _amplitudeEventManager.actionEvent('mainpage', 'enddetection', Provider.of<GlobalTimer>(context, listen: false).getDetectionTime(), GlobalTimer.alarmCount);
        // _liveActivitiesPlugin.endAllActivities();
        // setState(() {
        //   activityID = null;
        // });
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Loading()));
        _showPushAlarm();
      }

      if (Provider.of<DetectStatus>(context, listen: false).useTimeLimit &&
          useSec - Provider.of<GlobalTimer>(context, listen: false).secOnStart >= Provider.of<DetectStatus>(context, listen: false).detectionMin*60) {
        Provider.of<GlobalTimer>(context, listen: false).stopTimer();
        Provider.of<StretchingTimer>(context, listen: false).cancelTimer();
        Provider.of<DetectStatus>(context, listen: false).endDetecting();
        audioHandler?.pause();
        _amplitudeEventManager.actionEvent('mainpage', 'enddetection', Provider.of<GlobalTimer>(context, listen: false).getDetectionTime(), GlobalTimer.alarmCount);
        // _liveActivitiesPlugin.endAllActivities();
        // setState(() {
        //   activityID = null;
        // });
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Loading()));
        _showPushAlarm2();
      }

    });

    DetectStatus.detectAvailableEventStream.listen((flag) {
      if (!flag) {
        if (Provider.of<DetectStatus>(context, listen: false).nowDetecting) {
          Provider.of<GlobalTimer>(context, listen: false).stopTimer();
          // _liveActivitiesPlugin.endAllActivities();
          if (!_stopSheetOpened) {
            _stopSheetOpened = true;
            showAirpodsBottomSheet();
          }
        }
      } else {
        if (Provider.of<DetectStatus>(context, listen: false).nowDetecting) {
          Provider.of<GlobalTimer>(context, listen: false).restartTimer();
        }
      }
    });

    DetectStatus.soundSettingEventStream.listen((event) {
      List<String> eventParse = event.split(' ');
      print(eventParse);
      if (eventParse[0] == 'file') {
        audioHandler?.changeSound(eventParse[1]);
        print('sound changed');
      } else if (eventParse[0] == 'volume') {
        audioHandler?.changeVolume(double.parse(eventParse[1]));
        print('volume changed');
      }
    });

    // _decideShowReviewPopup();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state){
      case AppLifecycleState.resumed:
        print('resume');
        break;
      case AppLifecycleState.inactive:
        print('inactive');
        break;
      case AppLifecycleState.detached:
        print('deteched');
        break;
      case AppLifecycleState.paused:
        print('paused');
        audioHandler!.resume();
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
    }

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

  Future<void> _showPushAlarm2() async {
    FlutterLocalNotificationsPlugin localNotification =
    FlutterLocalNotificationsPlugin();

    await localNotification.show(0,
        '탐지가 종료되었어요',// LS.tr('home_view.today_free_time_end'),
        '탐지 결과를 앱에서 확인해보세요!',
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
    audioHandler ??= await AudioService.init(
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
          await audioHandler?.pause();
          print('end detection');
          _amplitudeEventManager.actionEvent('mainpage', 'enddetection', Provider.of<GlobalTimer>(context, listen: false).getDetectionTime(), GlobalTimer.alarmCount);
          Provider.of<GlobalTimer>(context, listen: false).stopTimer();
          Provider.of<StretchingTimer>(context, listen: false).cancelTimer(); //스트레칭 알리미 종료
          // _liveActivitiesPlugin.endAllActivities();
          // Provider.of<DetectStatus>(context, listen: false).init();
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
    WidgetsBinding.instance.removeObserver(this);
    // _liveActivitiesPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    DetectStatus detectStatus = context.watch();
    UserStatus userStatus = context.watch();
    GlobalTimer globalTimer = context.watch();
    StretchingTimer stretchingTimer = context.watch();

    return Scaffold(
      appBar:  const PreferredSize(
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
                        // SizedBox(height: res.percentHeight(2),),
                        // userStatus.isLogged ? const BannerCarousel() : const HomeAppBar(),
                        SizedBox(height: res.percentHeight(2),),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                          height: !detectStatus.detectAvailable ? res.percentWidth(85)*0.3 : 0,
                          child: SingleChildScrollView(
                            child: GestureDetector(
                              onTap: () {
                                // if (!detectStatus.detectAvailable) {
                                //   switch (OpenSettingsPlus.shared) {
                                //     case OpenSettingsPlusIOS settings: settings.bluetooth();
                                //     default: throw Exception('Platform not supported');
                                //   }
                                // }
                                _amplitudeEventManager.actionEvent('clicked', 'show_connectguide');
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
                                          if (!detectStatus.detectAvailable && !detectStatus.nowDetecting) {
                                            showSnackbar(LS.tr('home_view.airpods_connect_ask'));
                                          } else if (!detectStatus.nowDetecting) {
                                            if (!userStatus.isPremium && globalTimer.useSec >= 3600) {
                                              showSnackbar(LS.tr('home_view.end_today_free_time'));
                                            } else {
                                              _amplitudeEventManager.actionEvent('mainpage', 'click_startbutton');
                                              Navigator.push(context, MaterialPageRoute(
                                                  builder: (
                                                      context) => UserEnvAsk(onStart: (useTimeLimit, detectionMin) async {
                                                    audioHandler?.play();

                                                    DetectStatus detectStatus = Provider.of<DetectStatus>(context, listen: false);
                                                    _amplitudeEventManager.actionEvent('mainpage', 'startdetection', detectionMin, 0, {
                                                      'sensitivity': detectStatus.sensitivity,
                                                      'alarmGap': detectStatus.alarmGap,
                                                      'bgSoundActive': detectStatus.bgSoundActive,
                                                      'volume': detectStatus.soundVolume,
                                                      'pushNotiActive': detectStatus.pushNotiAvtive,
                                                      'useHorizontalMove': detectStatus.useHorizontalMove,
                                                      'env': detectStatus.userEnvType.typeString
                                                    });

                                                    String? refreshToken = await storage.read(key: 'refreshToken');
                                                    if (refreshToken != null) {
                                                      Response resForToken = await HistoryStatus
                                                          .dio.post(
                                                          '${HistoryStatus.serverAddress}/members/token',
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
                                        useTime: !detectStatus.useTimeLimit ?
                                                  '${TimeConvert.sec2TimeFormat(globalTimer.useSec)}${userStatus.isPremium ? '' : '/1:00:00'}' :
                                                  TimeConvert.sec2TimeFormat(detectStatus.detectionMin*60 - (globalTimer.useSec-globalTimer.secOnStart))
                                    ),
                                    // const StartButtonMsg(message: 'Press Start for bad posture alert!'),
                                    // if (detectStatus.detectAvailable && !detectStatus.nowDetecting)
                                    //   StartButtonMsg(message: 'home_view.start_cta'.tr())
                                    // else if (detectStatus.detectAvailable && detectStatus.nowDetecting)
                                    //   StartButtonMsg(message: 'home_view.stop_cta'.tr())
                                  ],
                                ),
                              ],
                            )
                        ),
                        SizedBox(height: res.percentHeight(2)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (
                                context) => const PageNavBar(pageIdx: 2,))
                            );
                          },
                          child: WhiteContainer(
                            width: 90,
                            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextDefault(content: 'home_view.strch_reminder'.tr(), fontSize: 12, isBold: false),
                                    TextDefault(content: stretchingTimer.selectedStretchingInterval == null ? 'home_view.strch_off' : 'home_view.strch_on'.tr(args: [(stretchingTimer.selectedStretchingInterval! ~/ 60).toString()]), fontSize: 16, isBold: true),
                                  ],
                                ),
                                AssetIcon('arrowNext', size: res.percentWidth(1))
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: res.percentHeight(1),),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => const AlarmSetting()));
                          },
                          child: WhiteContainer(
                            width: 90,
                            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextDefault(content: LS.tr('home_view.alarm_desc1'), fontSize: 12, isBold: false),
                                    TextDefault(content: 'home_view.alarm_desc2'.tr(), fontSize: 16, isBold: true),
                                  ],
                                ),
                                AssetIcon('arrowNext', size: res.percentWidth(1))
                              ],
                            ),
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
          ),
        ),
      );
  }
}