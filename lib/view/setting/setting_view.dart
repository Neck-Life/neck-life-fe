import 'package:easy_localization/easy_localization.dart';
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
  List<String>_deleteReasonList = ['setting_view.delete_reason1'.tr(), 'setting_view.delete_reason2'.tr(), 'setting_view.delete_reason3'.tr(),
    'setting_view.delete_reason4'.tr(), 'setting_view.delete_reason5'.tr()];
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
            title: 'setting_view.really_quit'.tr(),
            content: 'setting_view.quit_ask'.tr(),
            btnStr: 'setting_view.quit_cancel'.tr(),
            secondBtnStr: 'setting_view.quit_quit'.tr(),
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
          title: 'setting_view.really_logout'.tr(),
          btnStr: 'setting_view.logout_cancel'.tr(),
          secondBtnStr: 'setting_view.logout_logout'.tr(),
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
                      TextDefault(
                          content: 'setting_view.delete_reason_ask'.tr(),
                          fontSize: 18,
                          isBold: true
                      ),
                      ListTile(
                        title: TextDefault(
                          content: "setting_view.delete_reason1".tr(),
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
                        title: TextDefault(
                          content: "setting_view.delete_reason2".tr(),
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
                        title: TextDefault(
                          content: "setting_view.delete_reason3".tr(),
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
                        title: TextDefault(
                          content: "setting_view.delete_reason4".tr(),
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
                        title:TextDefault(
                          content: "setting_view.delete_reason5".tr(),
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
                          decoration: InputDecoration(
                              hintText: 'setting_view.delete_reason6'.tr(),
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
                                      content: Text('setting_view.error'.tr(),
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
                                            child: Text('setting_view.close'.tr())
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
                          child: TextDefault(content: 'setting_view.submit'.tr(), fontSize: 15, isBold: true)
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
      return  CustomPopUp(text: 'setting_view.error'.tr());
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
              return CustomPopUp(text: 'setting_view.feedback_thanx'.tr());
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
                child: TextDefault(
                    content: 'setting_view.setting'.tr(),
                    fontSize: 24,
                    isBold: true
                ),
              ),
              MenuItem(iconStr: 'Bookmark', text: 'setting_view.my_subscriptions'.tr(), isPremium: userStatus.isPremium, onTap: () {
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
                child: TextDefault(content: 'setting_view.service'.tr(), fontSize: 14, isBold: true),
              ),
              MenuItem(iconStr: 'Notification', text: 'setting_view.forward_notification_setting'.tr(), onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (
                    context) => const AlarmSetting()));
              }),
              MenuItem(iconStr: 'Document', text:'setting_view.tutorial'.tr(), onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (
                    context) => const Tutorials()));
              }),
              MenuItem(iconStr: 'Chat', text:'setting_view.feedback'.tr(), onTap: () {
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
                child: TextDefault(content: 'setting_view.terms_of_service'.tr(), fontSize: 14, isBold: true),
              ),
              MenuItem(iconStr: 'justify', text: 'setting_view.terms_of_service'.tr(), onTap: () async {
                await openUrlHelper.openTermOfService();
              }),
              MenuItem(iconStr: 'justify', text: 'setting_view.privacy_policy'.tr(), onTap: () async {
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
                  text: 'setting_view.logout'.tr(),
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
                  TextDefault(content: 'setting_view.if_quit'.tr(), fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0),),
                  GestureDetector(
                    onTap: () {
                      _showDeleteAccountAlert();
                    },
                    child:  TextDefault(content: 'setting_view.here'.tr(), fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0), underline: true,),
                  ),
                   TextDefault(content: ' ${'setting_view.click'.tr()}', fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0),),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}