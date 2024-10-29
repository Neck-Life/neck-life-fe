import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
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
import '../../util/localization_string.dart';
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

  bool _loginProcessStarted = false;

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
      return CustomPopUp(text: LS.tr('login_view.login_error'));
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    UserStatus userStatus = context.watch();

    return PopScope(
        canPop: true,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: res.percentWidth(7.5), top: res.percentHeight(10)),
                  padding: EdgeInsets.only(right: res.percentWidth(7.5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: res.percentWidth(12.5),
                        height: res.percentWidth(12.5),
                        child: Image.asset('assets/cliped_logo.png', width: res.percentWidth(15), fit: BoxFit.cover),
                      ),
                      SizedBox(height: res.percentHeight(2),),
                      Row(
                        children: [
                          TextDefault(
                            content: 'login_view.neck_life'.tr(),
                            fontSize: 28,
                            isBold: true,
                            fontColor: const Color(0xFF236EF3),
                          ),
                          TextDefault(
                            content: 'login_view.neck_life_with'.tr(),
                            fontSize: 28,
                            isBold: true,
                            fontColor: const Color(0xFF323238),
                          )
                        ],
                      ),
                      TextDefault(
                        content: LS.tr('login_view.neck_life_with_airpods'),
                        fontSize: 28,
                        isBold: true,
                        fontColor: const Color(0xFF323238),
                      ),
                      // const Spacer(),
                      SizedBox(height: res.percentHeight(35),),
                      TextDefault(content: 'login_view.login_with_social'.tr(), fontSize: 16, isBold: true, fontColor: const Color(0xFF323238)),
                      SizedBox(height: res.percentHeight(3),),
                    ],
                  ),
                ),
                Button(
                  onPressed: () async {
                    try {
                      if (!_loginProcessStarted) {
                        _loginProcessStarted = true;
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
                          throw Exception();
                        }
                      }
                    } on Exception catch (e) {
                      print(e);
                      _openErrorPopUp();
                    } finally {
                      _loginProcessStarted = false;
                    }
                  },
                  icon: 'Apple',
                  text: context.locale.languageCode == 'ko' ? 'Apple 로그인' : 'Apple Login',
                  backgroundColor: Colors.black,
                  color: Colors.white,
                  width: res.percentWidth(85),
                  padding: res.percentWidth(4),
                ),
                SizedBox(height: res.percentHeight(1.5),),
                Button(
                  onPressed: () async {
                    try {
                      if (!_loginProcessStarted) {
                        _loginProcessStarted = true;
                        String? idToken = await _signInWithGoogle();

                        if (idToken == null) {
                          throw Exception();
                        }

                        bool success = await userStatus.socialLogin(
                            idToken, 'google');
                        print(success);
                        if (success) {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (
                              context) => const PageNavBar()));
                        } else {
                          _openErrorPopUp();
                        }
                      }
                    } on Exception catch (e) {
                      print(e);
                      _openErrorPopUp();
                    } finally {
                      _loginProcessStarted = false;
                    }
                  },
                  icon: 'Google',
                  text: context.locale.languageCode == 'ko' ? 'Google 로그인' : 'Google Login',
                  backgroundColor: Colors.white,
                  color: const Color(0xFF323238),
                  width: res.percentWidth(85),
                  padding: res.percentWidth(4),
                ),
                SizedBox(height: res.percentHeight(3),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextDefault(content: 'login_view.by_signing_up'.tr(), fontSize: 13, isBold: false, fontColor: const Color(0xFF8991A0),),
                    GestureDetector(
                      onTap: () async {
                        await _launchUrl(_ToSUrl);
                      },
                      child: TextDefault(content: 'login_view.terms_of_service'.tr(), fontSize: 13, isBold: false, fontColor: const Color(0xFF8991A0), underline: true,),
                    ),
                    TextDefault(content: 'login_view.and'.tr(), fontSize: 13, isBold: false, fontColor: const Color(0xFF8991A0),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await _launchUrl(_PPUrl);
                      },
                      child: TextDefault(content: 'login_view.privacy_policy'.tr(), fontSize: 13, isBold: false, fontColor: const Color(0xFF8991A0), underline: true,),
                    ),
                    TextDefault(content: 'login_view.are_agreed'.tr(), fontSize: 13, isBold: false, fontColor: const Color(0xFF8991A0),),
                  ],
                )
              ],
            ),
          ),
        )
    );
  }

}