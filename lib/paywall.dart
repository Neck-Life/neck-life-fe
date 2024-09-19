import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:flutter/services.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
import 'package:mocksum_flutter/util/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

class Paywall extends StatefulWidget {
  const Paywall({super.key});

  @override
  State<StatefulWidget> createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {

  Package? _premiumSubscription = null;
  AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();

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
        print(offerings.current!.availablePackages);
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
      CustomerInfo customerInfo = await Purchases.purchasePackage(_premiumSubscription!);
      if (customerInfo.entitlements.all["necklife"]!.isActive) {
        // Unlock that great "pro" content
        // Provider.of<UserStatus>(context, listen: false).setIsPremium(true);
        print('payed');
        userStatus.setIsPremium(true);
        _amplitudeEventManager.actionEvent('paywall', 'purchase');
        return true;
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print(e);
        _showErrorPopUp();
      }
    }
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
    Responsive responsive = Responsive(context);
    UserStatus userStatus = Provider.of(context);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: responsive.percentHeight(7.5),),
          Center(
            child: Column(
              children: [
                Text('NeckLife',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF000000),
                    fontSize: responsive.fontSize(36),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.percentHeight(5),),
                Text('프리미엄 플랜으로\n더 많은 기능을 누려보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF000000),
                    fontSize: responsive.fontSize(20),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: responsive.deviceWidth,
            padding: EdgeInsets.only(left: responsive.percentWidth(7.5)),
            margin: EdgeInsets.only(top: responsive.percentHeight(5), bottom: 10),
            child: Text('핵심 기능',
              style: TextStyle(
                color: const Color(0xFF000000),
                fontSize: responsive.fontSize(20),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: responsive.deviceWidth,
            height: responsive.percentHeight(45),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  Container(
                      width: responsive.percentWidth(85),
                      height: responsive.percentWidth(85)*0.3,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                            spreadRadius: 3,
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                              left: responsive.percentWidth(5),
                              top: responsive.percentWidth(7),
                              child: Image.asset("assets/head_icon.png", width: responsive.percentWidth(12.5),)
                          ),
                          Positioned(
                            left: responsive.percentWidth(25),
                            top: responsive.percentWidth(7),
                            child: Text(
                              '실시간 거북목 탐지',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(18),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Positioned(
                            left: responsive.percentWidth(25),
                            top: responsive.percentWidth(7)+25,
                            child: Text(
                              '시간 제한 없는 실시간 자세 모니터링',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(14),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  SizedBox(height: responsive.percentHeight(2),),
                  Container(
                      width: responsive.percentWidth(85),
                      height: responsive.percentWidth(85)*0.3,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                            spreadRadius: 3,
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                              left: responsive.percentWidth(5),
                              top: responsive.percentWidth(7),
                              child: Image.asset("assets/bg_icon.png", width: responsive.percentWidth(12.5),)
                          ),
                          Positioned(
                            left: responsive.percentWidth(25),
                            top: responsive.percentWidth(7),
                            child: Text(
                              '백그라운드 알림',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(18),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Positioned(
                            left: responsive.percentWidth(25),
                            top: responsive.percentWidth(7)+25,
                            child: Text(
                              '백그라운드에서도 동작하는 자세 탐지',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(14),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  SizedBox(height: responsive.percentHeight(2),),
                  Container(
                      width: responsive.percentWidth(85),
                      height: responsive.percentWidth(85)*0.3,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                            spreadRadius: 3,
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: responsive.percentWidth(5),
                            top: responsive.percentWidth(7),
                            child: Image.asset("assets/bg_icon.png", width: responsive.percentWidth(12.5),)
                          ),
                          Positioned(
                            left: responsive.percentWidth(25),
                            top: responsive.percentWidth(6),
                            child: Text(
                              '탐지 기록 및 통계 제공',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(18),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Positioned(
                            left: responsive.percentWidth(25),
                            top: responsive.percentWidth(7)+25,
                            child: Text(
                              '자세 모니터링 기록을 이용하여 \n자세에 대한 다양한 정보와 통계 제공',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(14),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w300,
                                height: 1.0
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  SizedBox(height: responsive.percentHeight(2),),
                  Container(
                      width: responsive.percentWidth(85),
                      height: responsive.percentWidth(85)*0.3,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                            spreadRadius: 3,
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                              left: responsive.percentWidth(8),
                              top: responsive.percentWidth(2),
                              child: Text(
                                '+',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: responsive.fontSize(50),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                          ),
                          Positioned(
                            left: responsive.percentWidth(25),
                            top: responsive.percentWidth(7),
                            child: Text(
                              '더 많은 추가 기능',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(18),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Positioned(
                            left: responsive.percentWidth(25),
                            top: responsive.percentWidth(7)+25,
                            child: Text(
                              '앞으로 다양한 부가 기능 탑재 계획',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(14),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  const SizedBox(height: 10,),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: responsive.deviceWidth,
            height: responsive.percentHeight(15),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: responsive.percentHeight(1),),
                ElevatedButton(
                  onPressed: () async {
                    bool isPremium = await Provider.of<UserStatus>(context, listen: false).getUserIsPremium();
                    if (isPremium) {
                      return;
                    }
                    await _purchaseSupscription(userStatus);
                    // if (success) {
                    //   userStatus.setIsPremium(true);
                    // }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(responsive.percentWidth(70), 35),
                    backgroundColor: const Color(0xFFD9D9D9),
                    surfaceTintColor: Colors.white,
                    shadowColor: const Color(0x19000000),
                    side: const BorderSide(
                      width: 1,
                      color: Colors.black
                    )
                  ),
                  child: _premiumSubscription == null ?
                    const SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(),
                    ) :
                    Text(
                      '프리미엄 플랜 시작하기 (\$0.99/월)',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: responsive.fontSize(14),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ),
                SizedBox(height: responsive.percentHeight(1),),
              ],
            ),
          )
        ],
      ),
    );
  }

}