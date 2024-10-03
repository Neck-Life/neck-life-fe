import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/service/history_provider.dart';
import 'package:mocksum_flutter/view/login/login_view.dart';
// import 'package:mocksum_flutter/settings.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/view/tutorial/tutorial_view.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/view/home/home_view.dart';
import 'package:provider/provider.dart';
import 'package:mocksum_flutter/view/history/history_view.dart';
import 'package:mocksum_flutter/view/setting/setting_view.dart';
// import 'history.dart';

class PageNavBar extends StatefulWidget {
  final int? pageIdx;

  const PageNavBar({
    super.key,
    this.pageIdx
  });

  @override
  State<StatefulWidget> createState() => _PageNavBarState();
}

class _PageNavBarState extends State<PageNavBar> {
  int _index = 0;
  bool _isFirstLaunch = false;
  final AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();

  @override
  void initState() {
    setState(() {
      _index = widget.pageIdx ?? 0;
    });
    Future.delayed(Duration.zero, () async {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) => _initATTPlugin());
      await _updateIsFirstLaunch();

      bool isLogged = await Provider.of<UserStatus>(context, listen: false)
          .checkAndUpdateToken();
      print(isLogged);
      Provider.of<UserStatus>(context, listen: false).setIsLogged(isLogged);

      if (_isFirstLaunch) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Tutorials()));
      }

      if (!isLogged) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      } else {
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
        future: userStatus.checkAndUpdateToken(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              return Scaffold(
                body: IndexedStack(
                  index: _index,
                  children: const [Home(), History(), Settings()], // History(key: UniqueKey(),)
                ),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFFE5E5EB)
                    )
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: BottomNavigationBar(
                      backgroundColor: const Color(0xFFF9F9F9),
                      selectedLabelStyle: const TextStyle(color: Color(0xFF101010)),
                      items: [
                        BottomNavigationBarItem(icon: AssetIcon('home', size: 4.5, color: _index == 0 ? const Color(0xFF101010) : const Color(0xFFCFCFD8)), label: '홈'),
                        BottomNavigationBarItem(icon: AssetIcon('graph', size: 4.5, color: _index == 1 ? const Color(0xFF101010) : const Color(0xFFCFCFD8)), label: '기록'),
                        BottomNavigationBarItem(icon: AssetIcon('setting', size: 4.5, color: _index == 2 ? const Color(0xFF101010) : const Color(0xFFCFCFD8)), label: '설정')
                      ],
                      currentIndex: _index,
                      onTap: (newIndex) async {
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

                        if (newIndex == 0) {
                          bool isPremium = await userStatus.getUserIsPremium();
                          userStatus.setIsPremium(isPremium);
                        }
                      },
                    ),
                  ),
                ),
              );
            } else {
              return const LoginPage();
            }
          }
          return const SizedBox();
          // return MainPage();
        },
      )
      // userStatus.isLogged ?  : LoginPage()
    );
  }

}