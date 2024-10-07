import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mocksum_flutter/page_navbar.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../theme/component/button.dart';
import '../../theme/component/text_default.dart';
import '../../theme/popup.dart';
import '../../util/responsive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final Uri _ToSUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Term-of-service-a040519dd560492c95ecf320c857c66a');
  final Uri _PPUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Privacy-Policy-f50f241b48d44e74a4ffe9bbc9f87dcf?pvs=4');

  static const List<String> scopes = <String>[
    'email',
  ];

  // @override
  // void initState() {
  //   super.initState();
  //
  //   });
  // }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch');
    }
  }

  // void _getNowIsFirstLaunch() async {
  //   const storage = FlutterSecureStorage();
  //   String? first = await storage.read(key: 'first');
  //   if (first == null) {
  //     _isFirstLaunch = true;
  //     await storage.write(key: 'first', value: '1');
  //   }
  // }

  Future<String?> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: scopes).signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    return googleAuth?.idToken;
  }

  void _openErrorPopUp() {
    showDialog(context: context, builder: (ctx) {
      return const CustomPopUp(text: '오류가 발생했습니다.\n다시 시도해주세요.');
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    UserStatus userStatus = context.watch();

    return PopScope(
        canPop: false,
        child: Scaffold(
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: res.percentWidth(7.5), top: res.percentHeight(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: res.percentWidth(12.5),
                      height: res.percentWidth(12.5),
                      child: Image.asset('assets/cliped_logo.png', width: res.percentWidth(15), fit: BoxFit.cover),
                    ),
                    SizedBox(height: res.percentHeight(2),),
                    const Row(
                      children: [
                        TextDefault(
                          content: '넥라이프',
                          fontSize: 28,
                          isBold: true,
                          fontColor: Color(0xFF236EF3),
                        ),
                        TextDefault(
                          content: '와 함께',
                          fontSize: 28,
                          isBold: true,
                          fontColor: Color(0xFF323238),
                        )
                      ],
                    ),
                    const TextDefault(
                      content: '에어팟만으로 바른 자세를\n유지해보세요',
                      fontSize: 28,
                      isBold: true,
                      fontColor: Color(0xFF323238),
                    ),
                    SizedBox(height: res.percentHeight(40),),
                    const TextDefault(content: '소셜 로그인으로 빠르게 시작해보세요', fontSize: 16, isBold: true, fontColor: Color(0xFF323238)),
                    SizedBox(height: res.percentHeight(3),),
                  ],
                ),
              ),
              Button(
                onPressed: () async {
                  print('asdfasdfasdf');
                  try {
                    final credential = await SignInWithApple
                        .getAppleIDCredential(
                      scopes: [
                        AppleIDAuthorizationScopes.email,
                      ],
                    );
                    print(credential);
                    bool success = await userStatus.socialLogin(
                        credential.authorizationCode, 'apple');
                    print('test $success');
                    if (success) {

                      Navigator.push(
                          context, MaterialPageRoute(builder: (
                          context) => const PageNavBar()));
                    } else {
                      _openErrorPopUp();
                    }
                  } on Exception catch (e) {
                    print(e);
                    _openErrorPopUp();
                  }
                },
                icon: 'Apple',
                text: 'Apple 로그인',
                backgroundColor: Colors.black,
                color: Colors.white,
                width: res.percentWidth(85),
                padding: res.percentWidth(4),
              ),
              SizedBox(height: res.percentHeight(3),),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TextDefault(content: '회원 가입 시  ', fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0),),
                  GestureDetector(
                    onTap: () async {
                      await _launchUrl(_ToSUrl);
                    },
                    child: const TextDefault(content: '서비스 이용 약관', fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0), underline: true,),
                  ),
                  const TextDefault(content: '과', fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0),),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _launchUrl(_PPUrl);
                    },
                    child: const TextDefault(content: '개인정보 처리방침', fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0), underline: true,),
                  ),
                  const TextDefault(content: '에 동의한 것으로 간주됩니다.', fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0),),
                ],
              )
            ],
          ),
        )
    );
  }

}