import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

class Paywall extends StatefulWidget {
  const Paywall({super.key});

  @override
  State<StatefulWidget> createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;

    configuration = PurchasesConfiguration('appl_cITGFaxfFmfrUEYToWETNmfDITU');
    await Purchases.configure(configuration);

    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      print(customerInfo);
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        // Display packages for sale
        print(offerings.current!.availablePackages);
      }
    } on PlatformException catch (e) {
      print(e);
      // optional error handling
    }
  }


  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

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
                Text('넥라이프와 함께\n목 건강을 지켜보세요!',
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
                      '에어팟을 활용한 실시간 자세 모니터링',
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
                  child: Text(
                    '넥라이프 시작하기 (1,100₩/월)',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: responsive.fontSize(14),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: responsive.percentHeight(1),),
                Text(
                  '무료 체험 기간 7일 제공',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: responsive.fontSize(14),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}