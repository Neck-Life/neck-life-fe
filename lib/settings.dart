import 'package:flutter/material.dart';
import 'package:mocksum_flutter/tutorials.dart';
import 'package:mocksum_flutter/util/user_provider.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'util/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mocksum_flutter/setting_subpages/alarm_setting.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<Settings> {

  final Uri _fomrUrl = Uri.parse('https://forms.gle/bi2YK5wfAFXQN4DKA');
  final Uri _ToSUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Term-of-service-a040519dd560492c95ecf320c857c66a');
  final Uri _PPUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Privacy-Policy-f50f241b48d44e74a4ffe9bbc9f87dcf?pvs=4');

  void _showDeleteAccountAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text('정말 탈퇴하시겠습니까?',
              style: TextStyle(
                color: const Color(0xFF434343),
                fontSize: MediaQuery.of(context).size.width*0.05,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w300,
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    UserStatus userStatus2 = Provider.of<UserStatus>(context, listen: false);
                    bool success = await userStatus2.deleteAccount();
                    print(success);
                    if (success) {
                      Navigator.push(context, MaterialPageRoute(builder: (
                          context) => const LoginPage()));
                      userStatus2.cleanAll();
                    } else {
                      await showDialog(
                        context: context,
                        builder: (contextIn) {
                          return AlertDialog(
                            content: Text('오류가 발생했습니다.\n다시 시도해주세요.',
                              style: TextStyle(
                                color: const Color(0xFF434343),
                                fontSize: MediaQuery.of(context).size.width*0.05,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('닫기')
                              )
                            ],
                          );
                        }
                      );

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('네')
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('아니오')
              ),
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
    UserStatus userStatus = Provider.of(context);

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
          // Container(
          //   width: responsive.deviceWidth,
          //   height: responsive.deviceWidth*0.25,
          //   alignment: Alignment.centerLeft,
          //   padding: const EdgeInsets.only(left: 20),
          //   decoration: const BoxDecoration(
          //     color: Colors.white
          //   ),
          //   child: Text('안녕하세요',
          //     style: TextStyle(
          //       color: const Color(0xFF434343),
          //       fontSize: responsive.fontSize(20),
          //       fontFamily: 'Inter',
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
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
          // Container(
          //   width: responsive.deviceWidth,
          //   height: 50,
          //   alignment: Alignment.centerLeft,
          //   padding: const EdgeInsets.only(left: 15),
          //   decoration: BoxDecoration(
          //       color: Colors.white,
          //       border: Border(
          //         // bottom: BorderSide(color: Colors.grey),
          //           top: BorderSide(color: Colors.grey.withOpacity(0.3))
          //       )
          //   ),
          //   child: Text('회원정보 수정',
          //     style: TextStyle(
          //       color: const Color(0xFF434343),
          //       fontSize: responsive.fontSize(17),
          //       fontFamily: 'Inter',
          //       fontWeight: FontWeight.w300,
          //     ),
          //   ),
          // ),
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
              userStatus.cleanAll();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          ),
          GestureDetector(
            onTap: () async {
              _showDeleteAccountAlert(context);
            },
            child: Container(
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
            ),
          )
        ]
      ),
    );
  }

}