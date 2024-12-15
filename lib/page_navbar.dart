import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/theme/popup.dart';
import 'package:mocksum_flutter/view/goal/goal_view.dart';
import 'package:mocksum_flutter/view/login/login_view.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/view/start_position/start_position_view.dart';
import 'package:mocksum_flutter/view/stretch/stretching.dart';
import 'package:mocksum_flutter/view/tutorial/tutorial_view.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/view/home/home_view.dart';
import 'package:mocksum_flutter/view/use_env_ask/user_env_ask_view.dart';
import 'package:mocksum_flutter/view/use_env_ask/widget/env_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mocksum_flutter/view/history/history_view.dart';
import 'package:mocksum_flutter/view/setting/setting_view.dart';
import 'package:app_settings/app_settings.dart';
import 'main.dart';

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
      // WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) => _initATTPlugin());
      await _updateIsFirstLaunch();

      bool isLogged = await Provider.of<UserStatus>(context, listen: false)
          .checkAndUpdateToken();
      Provider.of<UserStatus>(context, listen: false).setIsLogged(isLogged);

      print('login checked');

      if (_isFirstLaunch) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Tutorials()));
      }

      // if (isLogged) {
      await _amplitudeEventManager.initAmplitude();
      // }
      if (isLogged) {
        await _amplitudeEventManager.setUserID(Provider.of<UserStatus>(context, listen: false).email);
      }

      // final sensorPermission = await Permission.sensors.status;
      // if (sensorPermission.isDenied || sensorPermission.isPermanentlyDenied) {
      //   await showSensorPermissionDialog(context);
      //   AppSettings.openAppSettings();
      // }

      DetectStatus.lanCode = context.locale.languageCode;
    });
    super.initState();
  }

  // Future<void> _initATTPlugin() async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   final TrackingStatus status =
  //   await AppTrackingTransparency.trackingAuthorizationStatus;
  //   // If the system can show an authorization request dialog
  //   if (status == TrackingStatus.notDetermined) {
  //     await showCustomTrackingDialog(context);
  //     // Wait for dialog popping animation
  //     await Future.delayed(const Duration(milliseconds: 200));
  //     // Request system's tracking authorization dialog
  //     final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();
  //   }
  // }


  Future<void> showSensorPermissionDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => CustomPopUp(text: 'permission_msg'.tr()),
      );


  Future<void> showCustomTrackingDialog(BuildContext context) async =>
    await showDialog<void>(
      context: context,
      builder: (context) => CustomPopUp(text: 'att_msg'.tr()),
    );


  Future<void> _updateIsFirstLaunch() async {
    // const storage = FlutterSecureStorage();
    String? first = await storage.read(key: 'first');
    if (first == null) {
      _isFirstLaunch = true;
      /**
       * 기존 기본옵션으로 저장된 스토리지키들 전부 삭제
       * 동일키 다른옵션으로 저장되어있으면 충돌되는 이슈 존재
       * written by ryu
       **/
      await storage.deleteAll(iOptions: const IOSOptions());
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
              return Scaffold(
                body: IndexedStack(
                  index: _index,
                  children: const [Home(), History(), Stretching(), Goal(), Settings()], // History(key: UniqueKey(),)
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
                      type: BottomNavigationBarType.fixed,
                      items: [
                        BottomNavigationBarItem(icon: AssetIcon('home', size: 4.5, color: _index == 0 ? const Color(0xFF101010) : const Color(0xFFCFCFD8)), label: context.locale.languageCode == 'ko' ? '홈' : 'Home'),
                        BottomNavigationBarItem(icon: AssetIcon('graph', size: 4.5, color: _index == 1 ? const Color(0xFF101010) : const Color(0xFFCFCFD8)), label: context.locale.languageCode == 'ko' ? '기록' : 'History'),
                        BottomNavigationBarItem(icon: AssetIcon('strch', size: 4.5, color: _index == 2 ? const Color(0xFF101010) : const Color(0xFFCFCFD8)), label: context.locale.languageCode == 'ko' ? '스트레칭' : 'Stretching'),
                        BottomNavigationBarItem(icon: AssetIcon('activity', size: 4.5, color: _index == 3 ? const Color(0xFF101010) : const Color(0xFFCFCFD8)), label: context.locale.languageCode == 'ko' ? '목표' : 'Goals'),
                        BottomNavigationBarItem(icon: AssetIcon('setting', size: 4.5, color: _index == 4 ? const Color(0xFF101010) : const Color(0xFFCFCFD8)), label: context.locale.languageCode == 'ko' ? '설정' : 'Settings')
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
                            _amplitudeEventManager.viewEvent('stretching');
                          } else if (_index == 3) {
                            _amplitudeEventManager.viewEvent('goal');
                          } else if (_index == 4) {
                            _amplitudeEventManager.viewEvent('setting');
                          }
                        });

                        try {
                          if (newIndex == 0) {
                            if (userStatus.isLogged) {
                              bool isPremium = await userStatus
                                  .getUserIsPremium();
                              userStatus.setIsPremium(isPremium);
                            }
                          }
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                  ),
                ),
              );
          }
          return const Scaffold();
          // return MainPage();
        },
      )
      // userStatus.isLogged ?  : LoginPage()
    );
  }

}