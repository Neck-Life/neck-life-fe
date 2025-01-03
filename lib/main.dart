import 'dart:developer';

import 'package:audio_session/audio_session.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mocksum_flutter/page_navbar.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/service/goal_provider.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/service/stretching_timer.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/util/NotificationService.dart';
import 'package:mocksum_flutter/view/home/home_view.dart';
// import 'package:mocksum_flutter/util/NotificationService.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter/services.dart';

const storage = FlutterSecureStorage(iOptions: IOSOptions(
  accessibility: KeychainAccessibility.first_unlock,
  synchronizable: true,
));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env"); // Firebase 초기화
  print('env loaded');
  await EasyLocalization.ensureInitialized();
  print('localization init');
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  print('setPreferredOrientations setted');
  await initializeAudioSession();
  print('audio session init');
  await initGoogleMobileAds();
  try {
    await Firebase.initializeApp();

    NotificationService notificationService = NotificationService();
    await notificationService.initFirebaseMessaging();
  } catch (e) {
    print(e);
  }

  runApp(EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KR')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp()
  ));
  // runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DetectStatus>(create: (_) => DetectStatus()),
        ChangeNotifierProvider<UserStatus>(create: (_) => UserStatus()),
        ChangeNotifierProvider<GoalProvider>(create: (_) => GoalProvider()),
        ChangeNotifierProvider<GlobalTimer>(create: (_) => GlobalTimer()),
        ChangeNotifierProvider<StretchingTimer>(create: (_) => StretchingTimer()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'NeckLife',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF4F4F7),
          bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent)
        ),
        home: UpgradeAlert(
          child: const PageNavBar(),
        )
      )
    );
  }
}

Future<InitializationStatus> initGoogleMobileAds() {
  return MobileAds.instance.initialize();
}

Future<void> initializeAudioSession() async {
  final AudioSession audioSession = await AudioSession.instance;
  await audioSession.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
    // avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.independent,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.music,
      usage: AndroidAudioUsage.media,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
  ));


  audioSession.becomingNoisyEventStream.listen((_) async {
    print('airpods unplugged ${HomeState.audioHandler != null ? HomeState.audioHandler!.isPlaying : 'um'}');
    if (HomeState.audioHandler != null && HomeState.audioHandler!.isPlaying) {
      await HomeState.audioHandler!.resume();
    }
  });
  // audioSession.interruptionEventStream.listen((event) {
  //   if (event.begin) {
  //     print('begin');
  //     switch (event.type) {
  //       case AudioInterruptionType.duck:
  //       // Another app started playing audio and we should duck.
  //         break;

  //       case AudioInterruptionType.pause:
  //       case AudioInterruptionType.unknown:
  //       // Another app started playing audio and we should pause.
  //         log('audio session paused');
  //         break;
  //     }
  //   } else {
  //     switch (event.type) {
  //       case AudioInterruptionType.duck:
  //       // The interruption ended and we should unduck.
  //       print('unduck');
  //         break;
  //       case AudioInterruptionType.pause:
  //       // The interruption ended and we should resume.
  //       print('resume!!');
  //       case AudioInterruptionType.unknown:
  //         print('end unknown');
  //       // The interruption ended but we should not resume.
  //         break;
  //     }
  //   }
  // });
}