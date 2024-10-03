import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/util/open_url_helper.dart';
import 'package:mocksum_flutter/view/setting/subpages/my_subscription/my_subscription_view.dart';
import 'package:mocksum_flutter/theme/popup.dart';
import 'package:mocksum_flutter/view/setting/subpages/alarm_setting/alarm_setting_view.dart';
import 'package:mocksum_flutter/theme/component/button.dart';
import 'package:mocksum_flutter/view/tutorial/tutorial_view.dart';
import 'package:mocksum_flutter/service/history_provider.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/view/setting/widgets/feedback_popup.dart';
import 'package:mocksum_flutter/view/setting/widgets/menu_item.dart';
import 'package:mocksum_flutter/view/setting/widgets/two_btn_sheet.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:mocksum_flutter/view/login/login_view.dart';
// import '../../login.dart';
import '../../util/responsive.dart';


class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<Settings> {

  final Uri _ToSUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Term-of-service-a040519dd560492c95ecf320c857c66a');
  final Uri _PPUrl = Uri.parse('https://cheerful-guardian-073.notion.site/Privacy-Policy-f50f241b48d44e74a4ffe9bbc9f87dcf?pvs=4');
  final OpenUrlHelper openUrlHelper = OpenUrlHelper();

  int _deleteAccountReasonIdx = 0;
  List<String>_deleteReasonList = ['자세 측정이 부정확한 거 같아요', '잘 사용하지 않아요', '지원되는 이어폰이 없어요', '배터리 소모량이 부담 돼요', '기타'];
  final _deleteReasonEditController = TextEditingController();


  @override
  void initState() {
    super.initState();

  }

  void _showDeleteAccountAlert() {
    showModalBottomSheet(
        context: context,
        useSafeArea: false,
        builder: (context) {
          return TwoBtnSheet(
            onError: _openErrorPopUp,
            onSuccess: () {},
            title: '넥라이프를 정말 탈퇴할까요?',
            content: '탈퇴 시 사용자의 계정 정보, 자세 탐지 기록 데이터 등의 모든 데이터가 삭제되며, 복구가 불가능합니다.',
            btnStr: '취소할게요',
            secondBtnStr: '탏퇴하기',
            onPress: () async {
              await askDeleteAccountReason(context);
            },
          );
        });
  }

  void _showLogoutAlert() {
    showModalBottomSheet(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return TwoBtnSheet(
          onError: _openErrorPopUp,
          onSuccess: () {},
          title: '넥라이프에서 로그아웃할까요?',
          btnStr: '계속 사용하기',
          secondBtnStr: '로그아웃하기',
          onPress: () async {
            UserStatus userStatus2 = Provider.of<UserStatus>(context, listen: false);
            userStatus2.cleanAll();
            await Purchases.logOut();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            Navigator.push(context, MaterialPageRoute(builder: (
                context) => const LoginPage()));
            userStatus2.cleanAll();
          },
        );
      });
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
                            print(deleteReason);
                            bool success = await userStatus2.deleteAccount(deleteReason);
                            if (success) {
                              const storage = FlutterSecureStorage();
                              storage.deleteAll();
                              userStatus2.cleanAll();
                              Provider.of<HistoryStatus>(context, listen: false).clearAll();
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


  void _openErrorPopUp() {
    showDialog(context: context, builder: (ctx) {
      return const CustomPopUp(text: '오류가 발생했습니다.\n다시 시도해주세요.');
    });
  }


  void _showFeedbackSubmitPopUp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FeedbackPopUp(
          onError: _openErrorPopUp,
          onSuccess: () {
            showDialog(context: context, builder: (ctx) {
              return const CustomPopUp(text: '감사합니다. 앱 발전을 위한 귀중한 자료로 사용하겠습니다.');
            });
          },
          pagePop: () {
            Navigator.of(context).pop();
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    UserStatus userStatus = Provider.of(context);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: res.percentWidth(7.5), top: res.percentHeight(3), bottom: res.percentHeight(3)),
                child: const TextDefault(
                    content: '설정',
                    fontSize: 24,
                    isBold: true
                ),
              ),
              MenuItem(iconStr: 'Bookmark', text: '내 구독', isPremium: userStatus.isPremium, onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (
                    context) => const MySubscription()));
              }),
              Container(
                width: res.deviceWidth,
                height: 2,
                margin: EdgeInsets.only(top: res.percentHeight(3)),
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E5EB)
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: res.percentWidth(6), right: res.percentWidth(6), top: res.percentHeight(3)),
                child: const TextDefault(content: '서비스', fontSize: 14, isBold: true),
              ),
              MenuItem(iconStr: 'Notification', text: '거북목 알림 설정', onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (
                    context) => const AlarmSetting()));
              }),
              MenuItem(iconStr: 'Document', text: '튜토리얼 보기', onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (
                    context) => const Tutorials()));
              }),
              MenuItem(iconStr: 'Chat', text: '문의/피드백 보내기', onTap: () {
                _showFeedbackSubmitPopUp();
              }),
              Container(
                width: res.deviceWidth,
                height: 2,
                margin: EdgeInsets.only(top: res.percentHeight(3)),
                decoration: const BoxDecoration(
                    color: Color(0xFFE5E5EB)
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: res.percentWidth(6), right: res.percentWidth(6), top: res.percentHeight(3)),
                child: const TextDefault(content: '약관 및 정책', fontSize: 14, isBold: true),
              ),
              MenuItem(iconStr: 'justify', text: '이용 약관', onTap: () async {
                await openUrlHelper.openTermOfService();
              }),
              MenuItem(iconStr: 'justify', text: '개인정보 처리방침', onTap: () async {
                await openUrlHelper.openPrivacyPolicy();
              }),
              Container(
                width: res.deviceWidth,
                height: 2,
                margin: EdgeInsets.only(top: res.percentHeight(3)),
                decoration: const BoxDecoration(
                    color: Color(0xFFE5E5EB)
                ),
              ),
              SizedBox(height: res.percentHeight(2.5),),
              Center(
                child: Button(
                  onPressed: () {
                    _showLogoutAlert();
                  },
                  text: '넥라이프 로그아웃',
                  isBorder: true,
                  padding: 15,
                  backgroundColor: Colors.white,
                  width: res.percentWidth(85),
                  borderColor: const Color(0xFF236EF3),
                  color: const Color(0xFF236EF3),
                ),
              ),
              SizedBox(height: res.percentHeight(2),),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TextDefault(content: '넥라이프를 탈퇴하려면 ', fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0),),
                  GestureDetector(
                    onTap: () {
                      _showDeleteAccountAlert();
                    },
                    child: const TextDefault(content: '여기를', fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0), underline: true,),
                  ),
                  const TextDefault(content: ' 눌러주세요', fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0),),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}