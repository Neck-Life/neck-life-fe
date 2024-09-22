import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/paywall.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:flutter/services.dart';
import 'package:mocksum_flutter/util/user_provider.dart';
import 'package:mocksum_flutter/widgets/text_default.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

class MySubscription extends StatefulWidget {
  const MySubscription({super.key});

  @override
  State<StatefulWidget> createState() => _MySubscriptionState();
}

class _MySubscriptionState extends State<MySubscription> {

  CustomerInfo? _customerInfo;

  @override
  void initState() {
    super.initState();
    _getSubscriptionStatus();
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

  String utc2LocalTime(String timeStr) {
    DateTime utcTime = DateFormat('yyyy-MM-ddTHH:mm:ssZ').parse(timeStr, true);
    DateTime localTime = utcTime.toLocal();

    return localTime.toString();
  }


  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    UserStatus userStatus = Provider.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: responsive.percentHeight(7.5),),
            Container(
              margin: EdgeInsets.only(left: responsive.percentWidth(7.5)),
              child: TextDefault(
                content: '내 구독',
                fontSize: 24,
                isBold: true,
              ),
            ),
            SizedBox(height: responsive.percentHeight(2),),
            Container(
              width: responsive.percentWidth(85),
              height: responsive.percentWidth(85)*0.3,
              margin: EdgeInsets.only(left: responsive.percentWidth(7.5)),
              padding: EdgeInsets.only(left: responsive.percentWidth(5)),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextDefault(
                    content: '현재 사용중인 플랜',
                    fontSize: 20,
                    isBold: false,
                  ),
                  TextDefault(
                    content: userStatus.isPremium ? '프리미엄 플랜' : '무료 플랜',
                    fontSize: 24,
                    isBold: true,
                  ),
                ],
              )
            ),
            !userStatus.isPremium ?
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (
                      context) => const Paywall()));
                },
                child: Container(
                  width: responsive.percentWidth(85),
                  height: responsive.percentWidth(85)*0.15,
                  margin: EdgeInsets.only(left: responsive.percentWidth(7.5), top: responsive.percentHeight(2)),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: responsive.percentWidth(5)),
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
                  child: TextDefault(
                    content: '프리미엄 플랜 알아보기',
                    fontSize: 20,
                    isBold: true,
                  ),
                ),
              ) :
            Container(
              width: responsive.percentWidth(85),
              height: responsive.percentWidth(85)*0.3,
              margin: EdgeInsets.only(left: responsive.percentWidth(7.5), top: responsive.percentHeight(2)),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: responsive.percentWidth(5)),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextDefault(
                    content: '다음 결제일시',
                    fontSize: 20,
                    isBold: false,
                  ),
                  TextDefault(
                    content: _customerInfo == null ? '---' : utc2LocalTime(_customerInfo!.entitlements.all['necklife']!.expirationDate!),
                    fontSize: 20,
                    isBold: true,
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }

}

