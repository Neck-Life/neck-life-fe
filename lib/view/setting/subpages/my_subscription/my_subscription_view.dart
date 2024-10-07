import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/view/setting/subpages/paywall/paywall_view.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/open_url_helper.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:flutter/services.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

import '../../../../page_navbar.dart';
import '../../../../theme/asset_icon.dart';
import '../../../../theme/component/button.dart';
import '../../../../util/amplitude.dart';

class MySubscription extends StatefulWidget {
  const MySubscription({super.key});

  @override
  State<StatefulWidget> createState() => _MySubscriptionState();
}

class _MySubscriptionState extends State<MySubscription> {

  CustomerInfo? _customerInfo;
  final OpenUrlHelper openUrlHelper = OpenUrlHelper();
  bool _isLoading = false;
  Package? _premiumSubscription;
  final AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();

  @override
  void initState() {
    super.initState();
    _amplitudeEventManager.viewEvent('mysubs');
    _getSubscriptionStatus();
    _initPlatformState();
  }

  Future<void> _getSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      setState(() {
        _customerInfo = customerInfo;
      });
      // access latest customerInfo
      // print(customerInfo);
    } on PlatformException catch (e) {
      // Error fetching customer info
      print(e);
    }
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

  String utc2LocalTime(String timeStr) {
    DateTime utcTime = DateFormat('yyyy-MM-ddTHH:mm:ssZ').parse(timeStr, true);
    DateTime localTime = utcTime.toLocal();

    return '${localTime.year}년 ${localTime.month}월 ${localTime.day}일';
  }


  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    UserStatus userStatus = Provider.of(context);

    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
                backgroundColor: const Color(0xFFF4F4F7),
                title: const TextDefault(
                  content: '내 구독',
                  fontSize: 16,
                  isBold: false,
                  fontColor: Color(0xFF64646F),
                ),
                centerTitle: true,
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const AssetIcon('arrowBack', color: Color(0xFF8991A0), size: 6,)
                )
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: res.percentHeight(5),),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: res.percentWidth(5),),
                  Image.asset('assets/cliped_logo.png', width: res.percentWidth(15)),
                  SizedBox(width: res.percentWidth(3),),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextDefault(
                        content: _customerInfo != null && _customerInfo!.activeSubscriptions.isNotEmpty ? '프리미엄 플랜': '무료 플랜',
                        fontSize: 28,
                        isBold: true,
                        fontColor: const Color(0xFF236EF3),
                      ),
                      const TextDefault(
                        content: '구독 중',
                        fontSize: 28,
                        isBold: true,
                        fontColor: const Color(0xFF101010),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: res.percentHeight(2),),
              WhiteContainer(
                width: 90,
                padding: EdgeInsets.symmetric(horizontal: res.percentWidth(7), vertical: res.percentHeight(3)),
                radius: 20,
                child: (_customerInfo != null && _customerInfo!.activeSubscriptions.isNotEmpty) ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextDefault(
                      content: '다음 결제일',
                      fontSize: 14,
                      isBold: false,
                      fontColor: Color(0xFF8991A0),
                    ),
                    SizedBox(height: res.percentHeight(0.5),),
                    TextDefault(
                      content: _customerInfo == null ? '---' : utc2LocalTime(_customerInfo!.entitlements.all['necklife']!.expirationDate!),
                      fontSize: 18,
                      isBold: true,
                      fontColor: const Color(0xFF323238),
                    ),
                  ],
                ) : const TextDefault(
                  content: '플랜을 업그레이드하면\n더 풍부한 기능을 체험할 수 있어요!',
                  fontSize: 18,
                  isBold: true,
                  fontColor: const Color(0xFF323238),
                ),
              ),
              (_customerInfo != null && _customerInfo!.activeSubscriptions.isNotEmpty) ?
              Container(
                margin: EdgeInsets.only(top: res.percentHeight(2)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextDefault(
                      content: '프리미엄 플랜 구독을 취소하려면 ',
                      fontSize: 14,
                      isBold: false,
                      fontColor: Color(0xFF8991A0),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await openUrlHelper.openUrl('https://support.apple.com/ko-kr/118223');
                      },
                      child: const TextDefault(
                        content: '여기를',
                        fontSize: 14,
                        isBold: false,
                        fontColor: Color(0xFF8991A0),
                        underline: true,
                      ),
                    ),
                    const TextDefault(
                      content: ' 참고해주세요',
                      fontSize: 14,
                      isBold: false,
                      fontColor: Color(0xFF8991A0),
                    ),
                  ],
                ),
              ) : const SizedBox(),
              const Spacer(),
              !(_customerInfo != null && _customerInfo!.activeSubscriptions.isNotEmpty) ? Container(
                width: res.deviceWidth,
                // height: res.percentHeight(20),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Button(
                      onPressed: () async {
                        if (_customerInfo == null) {
                          _showErrorPopUp();
                          return;
                        }
                        bool isPremium = _customerInfo!.entitlements.all["necklife"]!.isActive;
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
                    // SizedBox()
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Paywall()));
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: res.percentHeight(2), bottom: res.percentHeight(5)),
                        width: res.deviceWidth,
                        alignment: Alignment.center,
                        child: const TextDefault(content: '프리미엄 플랜 자세히보기', fontSize: 16, isBold: true, fontColor: Color(0xFF64646F),),
                      ),
                    )
                  ],
                ),
              ) : const SizedBox()
            ],
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

