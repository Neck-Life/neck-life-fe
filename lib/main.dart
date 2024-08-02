import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/home.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
import 'package:mocksum_flutter/util/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter/services.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initializeAudioSession();

  runApp(MyApp());
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
        ChangeNotifierProvider<UserStatus>(create: (_) => UserStatus())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NeckLife',
        theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF9F9F9)
        ),
        home: UpgradeAlert(
          child: const Home(),
        )
      )
    );
  }
}

Future<void> initializeAudioSession() async {
  final AudioSession audioSession = await AudioSession.instance;
  await audioSession.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.music,
      usage: AndroidAudioUsage.media,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
  ));
}