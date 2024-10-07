import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/button.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/util/open_url_helper.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:flutter/services.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/view/setting/subpages/paywall/widgets/explain_item.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

import '../../../../page_navbar.dart';
import '../../../../theme/asset_icon.dart';
import '../../../../theme/component/text_default.dart';

class Paywall extends StatefulWidget {
  const Paywall({super.key});

  @override
  State<StatefulWidget> createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {

  Package? _premiumSubscription;
  final AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();
  final OpenUrlHelper openUrlHelper = OpenUrlHelper();
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();

    _amplitudeEventManager.viewEvent('paywall');

    Future.delayed(Duration.zero, () {
      _initPlatformState();
    });
  }

  Future<void> _initPlatformState() async {

    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        // Display packages for sale
        // print(offerings.current!.availablePackages);
        setState(() {
          _premiumSubscription = offerings.current!.availablePackages[0];
        });
      }
    } on PlatformException catch (e) {
      print(e);
      // optional error handling
    }
  }

  Future<bool> _purchaseSupscription(UserStatus userStatus) async {
    try {
      if (_premiumSubscription == null) {
        throw PlatformException(code: 'subscription information is not loaded');
      }
      setState(() {
        _isLoading = true;
      });
      CustomerInfo customerInfo = await Purchases.purchasePackage(_premiumSubscription!);
      if (customerInfo.entitlements.all["necklife"]!.isActive) {
        // Unlock that great "pro" content
        // Provider.of<UserStatus>(context, listen: false).setIsPremium(true);
        print('payed');
        setState(() {
          _isLoading = false;
        });
        userStatus.setIsPremium(true);
        _amplitudeEventManager.actionEvent('paywall', 'purchase');
        Navigator.push(context, MaterialPageRoute(builder: (
            context) => const PageNavBar()));
        return true;
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print(e);
        _showErrorPopUp();
      }
    }
    setState(() {
      _isLoading = false;
    });
    return false;
  }

  void _showErrorPopUp() {
    showDialog(
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
  }


  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    UserStatus userStatus = context.watch();

    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
                backgroundColor: const Color(0xFFF4F4F7),
                centerTitle: true,
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const AssetIcon('close', color: Color(0xFF8991A0), size: 6,)
                )
            ),
          ),
          body: SizedBox(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: res.percentWidth(5),),
                    Image.asset('assets/cliped_logo.png', width: res.percentWidth(15)),
                    SizedBox(width: res.percentWidth(3),),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            TextDefault(
                              content: 'NeckLife Premium',
                              fontSize: 24,
                              isBold: true,
                              fontColor: Color(0xFF236EF3),
                            ),
                            TextDefault(
                              content: '과',
                              fontSize: 24,
                              isBold: true,
                              fontColor: Colors.black,
                            )
                          ],
                        ),
                        TextDefault(
                          content: '함께 더욱 풍부한 기능을\n체험해보세요!',
                          fontSize: 24,
                          isBold: true,
                          fontColor: Colors.black,
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(height: res.percentHeight(5),),
                const ExplainItem(icon: 'dt', title: '제한 없는 거북목 탐지', content: '에어팟을 이용한 실시간 모니터링\n시간 제한 없음'),
                const ExplainItem(icon: 'ad', title: '광고 제거', content: '앱 내의 광고 배너 제거'),
                const ExplainItem(icon: 'other', title: '더 많은 추가 기능', content: '앞으로 탑재될 여러 부가 기능 우선 제공'),
                const Spacer(),
                Button(
                  onPressed: () async {
                    bool isPremium = await Provider.of<UserStatus>(context, listen: false).getUserIsPremium();
                    if (isPremium) {
                      return;
                    }
                    await _purchaseSupscription(userStatus);
                  },
                  text: '월 \$0.99 프리미엄 플랜 시작하기',
                  backgroundColor: const Color(0xFF236EF3),
                  color: Colors.white,
                  width: res.percentWidth(90),
                  padding: res.percentWidth(4),
                ),
                SizedBox(height: res.percentHeight(1),),
                GestureDetector(
                  onTap: () async {
                    await openUrlHelper.openPrivacyPolicy();
                  },
                  child: const TextDefault(content: '개인정보 처리방침', fontSize: 12, isBold: false, fontColor: Color(0xFF64646F),),
                ),
                // Text('    '),
                GestureDetector(
                  onTap: () async {
                    await openUrlHelper.openTermOfService();
                  },
                  child: const TextDefault(content: '이용 약관', fontSize: 12, isBold: false, fontColor: Color(0xFF64646F),),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: res.percentHeight(2), bottom: res.percentHeight(5)),
                    width: res.deviceWidth,
                    alignment: Alignment.center,
                    child: const TextDefault(content: '무료 플랜으로 계속하기', fontSize: 16, isBold: true, fontColor: Color(0xFF64646F),),
                  ),
                )
              ],
            ),
          ),
        ),
        _isLoading ? Container(
          width: res.deviceWidth,
          height: res.deviceHeight,
          decoration: const BoxDecoration(
              color: Color(0x90000000)
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ) : const SizedBox()
      ],
    );
  }

}