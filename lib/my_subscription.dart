import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:flutter/services.dart';
import 'package:mocksum_flutter/widgets/text_default.dart';
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
      print(customerInfo);
    } on PlatformException catch (e) {
      // Error fetching customer info
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: responsive.percentHeight(7.5),),
            Container(
              // width: responsive.percentWidth(85),
              margin: EdgeInsets.only(bottom: 10, left: responsive.percentWidth(7.5)),
              child: const TextDefault(
                content: "내 구독",
                fontSize: 24,
                isBold: true,
              )
            ),
            Container(
              // width: responsive.percentWidth(85),
              margin: EdgeInsets.only(bottom: 10, left: responsive.percentWidth(7.5)),
              child: const TextDefault(
                content: "계정",
                fontSize: 20,
                isBold: true,
              )
            ),
            Container(
              // width: responsive.percentWidth(85),
              margin: EdgeInsets.only(bottom: 10, left: responsive.percentWidth(7.5)),
              child: _customerInfo == null ?
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ) : TextDefault(
                content: _customerInfo!.originalAppUserId,
                fontSize: 20,
                isBold: true,
              )
            ),
            Container(
              // width: responsive.percentWidth(85),
                margin: EdgeInsets.only(bottom: 10, left: responsive.percentWidth(7.5)),
                child: const TextDefault(
                  content: "구독 상태",
                  fontSize: 20,
                  isBold: true,
                )
            ),
            Container(
              // width: responsive.percentWidth(85),
                margin: EdgeInsets.only(bottom: 10, left: responsive.percentWidth(7.5)),
                child: const TextDefault(
                  content: "구독 상태",
                  fontSize: 20,
                  isBold: true,
                )
            ),
          ],
        ),
      ),
    );
  }

}

