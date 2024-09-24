import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/login.dart';
import 'package:mocksum_flutter/settings.dart';
import 'package:mocksum_flutter/tutorials.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/util/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'main_page.dart';
import 'history.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _index = 0;
  bool _isFirstLaunch = false;
  AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) => _initATTPlugin());
      await _updateIsFirstLaunch();

      bool isLogged = await Provider.of<UserStatus>(context, listen: false)
          .verifyToken();
      // print(isLogged);
      Provider.of<UserStatus>(context, listen: false).setIsLogged(isLogged);

      if (_isFirstLaunch) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Tutorials()));
      }

      if (!isLogged) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      } else {
        print('email ${Provider.of<UserStatus>(context, listen: false).email}');
        await _amplitudeEventManager.initAmplitude(Provider.of<UserStatus>(context, listen: false).email);
      }
    });
    super.initState();
  }

  Future<void> _initATTPlugin() async {
    await Future.delayed(const Duration(seconds: 1));
    final TrackingStatus status =
    await AppTrackingTransparency.trackingAuthorizationStatus;
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      await showCustomTrackingDialog(context);
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
          '본 앱은 보다 편리하고 개인화된 서비스를 위해 이메일 주소, 자세 측정 기록 등의 데이터를 사용할 수 있습니다.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속'),
          ),
        ],
      ),
    );


  Future<void> _updateIsFirstLaunch() async {
    const storage = FlutterSecureStorage();
    String? first = await storage.read(key: 'first');
    if (first == null) {
      _isFirstLaunch = true;
      await storage.write(key: 'first', value: '1');
    }
    // _isFirstLaunch = true;
  }

  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of(context);
    return PopScope(
      canPop: false,
      child: FutureBuilder(
        future: userStatus.verifyToken(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              return Scaffold(
                body: IndexedStack(
                  index: _index,
                  children: [const MainPage(), History(key: UniqueKey(),), const Settings()],
                ),
                bottomNavigationBar: BottomNavigationBar(
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  backgroundColor: const Color(0xFFF9F9F9),
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
                    BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'history'),
                    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'setting')
                  ],
                  currentIndex: _index,
                  onTap: (newIndex) {
                    setState(() {
                      _index = newIndex;
                      if (_index == 0) {
                        _amplitudeEventManager.viewEvent('mainpage');
                      } else if (_index == 1) {
                        _amplitudeEventManager.viewEvent('history');
                      } else if (_index == 2) {
                        _amplitudeEventManager.viewEvent('setting');
                      }
                    });
                  },
                ),
              );
            } else {
              return const LoginPage();
            }
          }
          return const Scaffold();
          // return MainPage();
        },
      )
      // userStatus.isLogged ?  : LoginPage()
    );
  }

}