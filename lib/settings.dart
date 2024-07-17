import 'package:flutter/material.dart';
import 'package:mocksum_flutter/tutorials.dart';
import 'login.dart';
import 'util/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mocksum_flutter/setting_subpages/alarm_setting.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<Settings> {

  final Uri _fomrUrl = Uri.parse('https://forms.gle/bi2YK5wfAFXQN4DKA');
  final Uri _ToSUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Term-of-service-a040519dd560492c95ecf320c857c66a');
  final Uri _PPUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Privacy-Policy-f50f241b48d44e74a4ffe9bbc9f87dcf?pvs=4');

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: LoginPage.scopes,
  );

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

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch');
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          SizedBox(height: responsive.percentHeight(7)),
          Container(
            width: responsive.percentWidth(85),
            margin: EdgeInsets.only(bottom: 10, left: responsive.percentWidth(7.5)),
            child: Text('설정',
              style: TextStyle(
                color: const Color(0xFF434343),
                fontSize: responsive.fontSize(18),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: responsive.deviceWidth,
            height: responsive.deviceWidth*0.25,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
              color: Colors.white
            ),
            child: Text('안녕하세요, 안유성님',
              style: TextStyle(
                color: const Color(0xFF434343),
                fontSize: responsive.fontSize(20),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: responsive.percentHeight(3)),
          GestureDetector(
            child: Container(
              width: responsive.deviceWidth,
              height: 50,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    // bottom: BorderSide(color: Colors.grey),
                      top: BorderSide(color: Colors.grey.withOpacity(0.3))
                  )
              ),
              child: Text('거북목 알림 설정',
                style: TextStyle(
                  color: const Color(0xFF434343),
                  fontSize: responsive.fontSize(17),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (
                  context) => const AlarmSetting()));
            },
          ),
          GestureDetector(
            child: Container(
              width: responsive.deviceWidth,
              height: 50,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    // bottom: BorderSide(color: Colors.grey),
                      top: BorderSide(color: Colors.grey.withOpacity(0.3))
                  )
              ),
              child: Text('튜토리얼 보기',
                style: TextStyle(
                  color: const Color(0xFF434343),
                  fontSize: responsive.fontSize(17),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (
                  context) => const Tutorials()));
            },
          ),
          GestureDetector(
            child: Container(
              width: responsive.deviceWidth,
              height: 50,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    // bottom: BorderSide(color: Colors.grey),
                      top: BorderSide(color: Colors.grey.withOpacity(0.3))
                  )
              ),
              child: Text('문의/피드백 보내기',
                style: TextStyle(
                  color: const Color(0xFF434343),
                  fontSize: responsive.fontSize(17),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            onTap: () {
              _launchUrl(_fomrUrl);
            },
          ),
          Container(
            width: responsive.deviceWidth,
            height: 50,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  // bottom: BorderSide(color: Colors.grey),
                    top: BorderSide(color: Colors.grey.withOpacity(0.3))
                )
            ),
            child: Text('회원정보 수정',
              style: TextStyle(
                color: const Color(0xFF434343),
                fontSize: responsive.fontSize(17),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              width: responsive.deviceWidth,
              height: 50,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    // bottom: BorderSide(color: Colors.grey),
                      top: BorderSide(color: Colors.grey.withOpacity(0.3))
                  )
              ),
              child: Text('이용 약관',
                style: TextStyle(
                  color: const Color(0xFF434343),
                  fontSize: responsive.fontSize(17),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            onTap: () {
              _launchUrl(_ToSUrl);
            },
          ),
          GestureDetector(
            child: Container(
              width: responsive.deviceWidth,
              height: 50,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    // bottom: BorderSide(color: Colors.grey),
                      top: BorderSide(color: Colors.grey.withOpacity(0.3))
                  )
              ),
              child: Text('개인정보 처리방침',
                style: TextStyle(
                  color: const Color(0xFF434343),
                  fontSize: responsive.fontSize(17),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            onTap: () {
              _launchUrl(_PPUrl);
            },
          ),
          GestureDetector(
            child: Container(
              width: responsive.deviceWidth,
              height: 50,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    // bottom: BorderSide(color: Colors.grey),
                      top: BorderSide(color: Colors.grey.withOpacity(0.3))
                  )
              ),
              child: Text('로그아웃',
                style: TextStyle(
                  color: const Color(0xFF434343),
                  fontSize: responsive.fontSize(17),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            onTap: () async {
              await _googleSignIn.signOut();

              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          ),
          Container(
            width: responsive.deviceWidth,
            height: 50,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  top: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  
                )
            ),
            child: Text('회원 탈퇴',
              style: TextStyle(
                color: const Color(0xFF434343),
                fontSize: responsive.fontSize(17),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w300,
              ),
            ),
          )
        ]
      ),
    );
  }

}