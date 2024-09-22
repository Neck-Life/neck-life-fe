import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/my_subscription.dart';
import 'package:mocksum_flutter/paywall.dart';
import 'package:mocksum_flutter/tutorials.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/util/history_provider.dart';
import 'package:mocksum_flutter/util/user_provider.dart';
import 'package:mocksum_flutter/widgets/text_default.dart';
// import 'package:mocksum_flutter/util/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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

  final Uri _ToSUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Term-of-service-a040519dd560492c95ecf320c857c66a');
  final Uri _PPUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Privacy-Policy-f50f241b48d44e74a4ffe9bbc9f87dcf?pvs=4');

  int _deleteAccountReasonIdx = 0;
  List<String>_deleteReasonList = ['자세 측정이 부정확한 거 같아요', '잘 사용하지 않아요', '지원되는 이어폰이 없어요', '배터리 소모량이 부담 돼요', '기타'];
  final _deleteReasonEditController = TextEditingController();
  final _feedbackEditController = TextEditingController();
  bool _reasonSelectEnd = false;


  @override
  void initState() {

    super.initState();
  }

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
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 40),
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      shadowColor: const Color(0x19000000),
                      side: const BorderSide(
                          width: 1,
                          color: Colors.black
                      )
                    ),
                    onPressed: () async {
                    await askDeleteAccountReason(context);
                  },
                  child: const Text('네')
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 40),
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      shadowColor: const Color(0x19000000),
                      side: const BorderSide(
                          width: 1,
                          color: Colors.black
                      )
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('아니요')
              ),
            ],
          );
        }
    );
  }

  void _showLogoutAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text('로그아웃하시겠습니까?',
              style: TextStyle(
                color: const Color(0xFF434343),
                fontSize: MediaQuery.of(context).size.width*0.05,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w300,
              ),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 40),
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      shadowColor: const Color(0x19000000),
                      side: const BorderSide(
                          width: 1,
                          color: Colors.black
                      )
                  ),
                  onPressed: () async {
                    UserStatus userStatus2 = Provider.of<UserStatus>(context, listen: false);
                    userStatus2.cleanAll();
                    await Purchases.logOut();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                    Navigator.push(context, MaterialPageRoute(builder: (
                        context) => const LoginPage()));
                    userStatus2.cleanAll();
                  },
                  child: const Text('네')
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 40),
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      shadowColor: const Color(0x19000000),
                      side: const BorderSide(
                          width: 1,
                          color: Colors.black
                      )
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('아니요')
              ),
            ],
          );
        }
    );
  }

  Future<void> askDeleteAccountReason(BuildContext context) async {
    Responsive responsive = Responsive(context);
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: responsive.percentHeight(5),),
                      const TextDefault(
                        content: "계정을 삭제하려는 이유를 말씀해주세요. 제품 개선에 중요한 자료로 사용하겠습니다.",
                        fontSize: 18,
                        isBold: true
                      ),
                      ListTile(
                        title: const TextDefault(
                          content: "자세 측정이 부정확한 거 같아요",
                          fontSize: 15,
                          isBold: false,
                        ),
                        leading: Radio(
                          value: 0,
                          groupValue: _deleteAccountReasonIdx,
                          onChanged: (int? value) {
                            setState(() {
                              _deleteAccountReasonIdx = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const TextDefault(
                          content: "잘 사용하지 않아요",
                          fontSize: 15,
                          isBold: false,
                        ),
                        leading: Radio(
                          value: 1,
                          groupValue: _deleteAccountReasonIdx,
                          onChanged: (int? value) {
                            setState(() {
                              _deleteAccountReasonIdx = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const TextDefault(
                          content: "지원되는 이어폰이 없어요",
                          fontSize: 15,
                          isBold: false,
                        ),
                        leading: Radio(
                          value: 2,
                          groupValue: _deleteAccountReasonIdx,
                          onChanged: (int? value) {
                            // print('asdf $_deleteAccountReasonIdx');
                            setState(() {
                              _deleteAccountReasonIdx = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const TextDefault(
                          content: "배터리 사용량이 부담 돼요",
                          fontSize: 15,
                          isBold: false,
                        ),
                        leading: Radio(
                          value: 3,
                          groupValue: _deleteAccountReasonIdx,
                          onChanged: (int? value) {
                            // print('asdf $_deleteAccountReasonIdx');
                            setState(() {
                              _deleteAccountReasonIdx = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const TextDefault(
                          content: "기타",
                          fontSize: 15,
                          isBold: false,
                        ),
                        leading: Radio(
                          value: 4,
                          groupValue: _deleteAccountReasonIdx,
                          onChanged: (int? value) {
                            setState(() {
                              _deleteAccountReasonIdx = value!;
                            });
                          },
                        ),
                      ),
                      _deleteAccountReasonIdx == 4 ?
                      Padding(
                        padding: EdgeInsets.all(responsive.percentWidth(3)),
                        child: TextField(
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                              hintText: '이유를 입력해주세요',
                              border: OutlineInputBorder()
                          ),
                          controller: _deleteReasonEditController,
                        ),
                      ) :
                      const SizedBox(),
                      ElevatedButton(
                          onPressed: () async {
                            // print(_deleteReasonEditController.text);
                            UserStatus userStatus2 = Provider.of<UserStatus>(context, listen: false);
                            String deleteReason = _deleteAccountReasonIdx == 4 ? _deleteReasonEditController.text : _deleteReasonList[_deleteAccountReasonIdx];
                            bool success = await userStatus2.deleteAccount(deleteReason);
                            if (success) {
                              const storage = FlutterSecureStorage();
                              storage.deleteAll();
                              Navigator.push(context, MaterialPageRoute(builder: (
                                  context) => const LoginPage()));
                              // userStatus2.cleanAll();

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
                                        style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(80, 40),
                                            backgroundColor: Colors.white,
                                            surfaceTintColor: Colors.white,
                                            shadowColor: const Color(0x19000000),
                                            side: const BorderSide(
                                                width: 1,
                                                color: Colors.black
                                            )
                                        ),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const TextDefault(content: '제출', fontSize: 15, isBold: true)
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        }
    );
  }


  void _showFeedbackSubmitPopUp(BuildContext context) {
    Responsive responsive = Responsive(context);
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              content: Center(
                child: Column(
                  children: [
                    SizedBox(height: responsive.percentHeight(5),),
                    const TextDefault(
                        content: "앱의 불편한 점이나 개선 사항 등을 개발자에게 알려주세요!",
                        fontSize: 18,
                        isBold: true
                    ),
                    Padding(
                      padding: EdgeInsets.all(responsive.percentWidth(3)),
                      child: TextField(
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: '자유롭게 전달하고 싶은 내용을 적어주세요',
                          border: OutlineInputBorder()
                        ),
                        controller: _feedbackEditController,
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (_feedbackEditController.text == '') {
                            return;
                          }
                          bool success = await HistoryStatus.sendFeedback(_feedbackEditController.text);
                          await showDialog(
                              context: context,
                              builder: (contextIn) {
                                return AlertDialog(
                                  content: Text(success ? '감사합니다. 앱 발전을 위한 자료로 사용하겠습니다.' : '오류가 발생했습니다.\n다시 시도해주세요.',
                                    style: TextStyle(
                                      color: const Color(0xFF434343),
                                      fontSize: MediaQuery.of(context).size.width*0.05,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(80, 40),
                                            backgroundColor: Colors.white,
                                            surfaceTintColor: Colors.white,
                                            shadowColor: const Color(0x19000000),
                                            side: const BorderSide(
                                                width: 1,
                                                color: Colors.black
                                            )
                                        ),
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const TextDefault(content: '제출', fontSize: 15, isBold: true)
                    )
                  ],
                ),
              ),
            );
          });
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
    // UserStatus userStatus = Provider.of(context);

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
              // _launchUrl(_fomrUrl);
              _showFeedbackSubmitPopUp(context);
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
              child: Text('내 구독',
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
                  context) => const MySubscription()));
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
              _showLogoutAlert(context);
            },
          ),
          GestureDetector(
            onTap: () async {
              _showDeleteAccountAlert(context);
              // askDeleteAccountReason(context);
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