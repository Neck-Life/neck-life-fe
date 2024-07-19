import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mocksum_flutter/home.dart';
import 'util/responsive.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocksum_flutter/tutorials.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  static const _kFontFam = 'MyFlutterApp';
  static const String? _kFontPkg = null;

  static const IconData apple = IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData google = IconData(0xf1a0, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  final Uri _ToSUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Term-of-service-a040519dd560492c95ecf320c857c66a');
  final Uri _PPUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Privacy-Policy-f50f241b48d44e74a4ffe9bbc9f87dcf?pvs=4');

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: LoginPage.scopes,
  );

  GoogleSignInAccount? _currentUser;
  bool _isFirstLaunch = false;

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch');
    }
  }

  void _getNowIsFirstLaunch() async {
    final storage = FlutterSecureStorage();
    String? first = await storage.read(key: 'first');
    if (first == null) {
      _isFirstLaunch = true;
      await storage.write(key: 'first', value: '1');
    }
  }

  void _showTutorial(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: const Tutorials(),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('튜토리얼 끝내기')
              )
            ],
          );
        }
    );
  }

  Future<void> _handleSignIn(context) async {
    try {
      await _googleSignIn.signIn();
      _checkLogin(context);
    } catch (error) {
      print(error);
    }
  }

  void _checkLogin(context) async {
    bool isLogged = await _googleSignIn.isSignedIn();
    if (isLogged) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
    }
  }

  @override
  void initState() {
    super.initState();

    _getNowIsFirstLaunch();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      print('asdf');
      bool isAuthorizedTemp = account != null;

      setState(() {
        _currentUser = account;
      });

      GoogleSignInAuthentication? googleAuth = await account?.authentication;


    });

    _googleSignIn.signInSilently();

    Future.delayed(Duration.zero, () {
      if (_isFirstLaunch) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Tutorials()));
      }
      _checkLogin(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            children: [
              SizedBox(height: responsive.percentHeight(10)),
              Container(
                width: responsive.deviceWidth,
                padding: EdgeInsets.only(left: responsive.percentWidth(7.5)),
                child: Text('목숨과 함께\n에어팟만으로\n바른 자세를 유지해보세요',
                  style: TextStyle(
                    color: const Color(0xFF434343),
                    fontSize: responsive.fontSize(28),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: responsive.percentHeight(10),),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: responsive.percentWidth(85),
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Colors.black
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9F9F9)
                    ),
                    child: Text(
                      '소셜 로그인으로 빠르게 시작하기',
                      style: TextStyle(
                        color: const Color(0xFF434343),
                        fontSize: responsive.fontSize(15),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: responsive.percentHeight(2.5),),
              ElevatedButton.icon(
                onPressed: () {

                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(responsive.percentWidth(85), 40),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  shadowColor: const Color(0x19000000),
                  side: const BorderSide(
                    width: 1,
                    color: Colors.black
                  )
                ),
                label: Text(
                  '애플 로그인',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: responsive.fontSize(18),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(apple, color: Colors.black)
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _handleSignIn(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(responsive.percentWidth(85), 40),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  shadowColor: const Color(0x19000000),
                  side: const BorderSide(
                    width: 1,
                    color: Colors.black
                  )
                ),
                label: Text(
                  '구글 로그인',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: responsive.fontSize(18),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(google, color: Colors.black)
              ),
              Container(
                width: responsive.percentWidth(85),
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        '로그인 시 본 서비스의 이용 약관과 개인정보 처리방침에\n동의한 것으로 간주됩니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: responsive.fontSize(12),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w200,
                        )
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      child: Text(
                          '이용 약관',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: responsive.fontSize(12),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w200,
                            decoration: TextDecoration.underline,
                          )
                      ),
                      onTap: () {
                        _launchUrl(_ToSUrl);
                      },
                    ),
                    GestureDetector(
                      child: Text(
                        '개인정보 처리방침',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: responsive.fontSize(12),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w200, decoration: TextDecoration.underline
                        )
                      ),
                      onTap: () {
                        _launchUrl(_PPUrl);
                      },
                    )
                  ],
                ),
              )
            ],
          )
        ),
      )
    );
  }

}