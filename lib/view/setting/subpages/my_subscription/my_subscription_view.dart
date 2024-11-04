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
import '../../../../util/localization_string.dart';

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
            content: Text(LS.tr('setting_subpages.my_subscription.my_subscription_view.error'),
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
                  child: Text('setting_subpages.my_subscription.my_subscription_view.close'.tr())
              )
            ],
          );
        }
    );
  }

  String utc2LocalTime(String timeStr) {
    DateTime utcTime = DateFormat('yyyy-MM-ddTHH:mm:ssZ').parse(timeStr, true);
    DateTime localTime = utcTime.toLocal();

    // return '${localTime.year}년 ${localTime.month}월 ${localTime.day}일';
    return 'setting_subpages.my_subscription.my_subscription_view.year_month_date'
        .tr(args: [localTime.year.toString(), localTime.month.toString(), localTime.day.toString()]);
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
                title: TextDefault(
                  content: 'setting_subpages.my_subscription.my_subscription_view.my_subscription'.tr(),
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
                        content: _customerInfo != null && _customerInfo!.activeSubscriptions.isNotEmpty ?
                        'setting_subpages.my_subscription.my_subscription_view.premium_plan'.tr():
                        'setting_subpages.my_subscription.my_subscription_view.free_plan'.tr(),
                        fontSize: 28,
                        isBold: true,
                        fontColor: const Color(0xFF236EF3),
                      ),
                      TextDefault(
                        content: 'setting_subpages.my_subscription.my_subscription_view.subscription_ongoing'.tr(),
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
                    TextDefault(
                      content: 'setting_subpages.my_subscription.my_subscription_view.next_payment'.tr(),
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
                ) : TextDefault(
                  content: LS.tr('setting_subpages.my_subscription.my_subscription_view.subscription_suggestion'),
                  fontSize: 18,
                  isBold: true,
                  fontColor: const Color(0xFF323238),
                ),
              ),
              (_customerInfo != null && _customerInfo!.activeSubscriptions.isNotEmpty) ?
              Container(
                margin: EdgeInsets.only(top: res.percentHeight(2)),
                child: context.locale.languageCode == 'ko' ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextDefault(
                      content: 'setting_subpages.my_subscription.my_subscription_view.subscription_cancel_if'.tr(),
                      fontSize: 14,
                      isBold: false,
                      fontColor: const Color(0xFF8991A0),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await openUrlHelper.openUrl('https://support.apple.com/ko-kr/118223');
                      },
                      child:  TextDefault(
                        content: 'setting_subpages.my_subscription.my_subscription_view.here'.tr(),
                        fontSize: 14,
                        isBold: false,
                        fontColor: const Color(0xFF8991A0),
                        underline: true,
                      ),
                    ),
                     TextDefault(
                      content: 'setting_subpages.my_subscription.my_subscription_view.reference'.tr(),
                      fontSize: 14,
                      isBold: false,
                      fontColor: const Color(0xFF8991A0),
                    ),
                  ],
                ) : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextDefault(
                      content: 'setting_subpages.my_subscription.my_subscription_view.subscription_cancel_if'.tr(),
                      fontSize: 14,
                      isBold: false,
                      fontColor: const Color(0xFF8991A0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await openUrlHelper.openUrl('https://support.apple.com/${context.locale.languageCode}-${context.locale.countryCode}/118223');
                          },
                          child:  TextDefault(
                            content: 'setting_subpages.my_subscription.my_subscription_view.here'.tr(),
                            fontSize: 14,
                            isBold: false,
                            fontColor: const Color(0xFF8991A0),
                            underline: true,
                          ),
                        ),
                        TextDefault(
                          content: 'setting_subpages.my_subscription.my_subscription_view.reference'.tr(),
                          fontSize: 14,
                          isBold: false,
                          fontColor: const Color(0xFF8991A0),
                        ),
                      ],
                    )
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
                        try {
                          print(_customerInfo);
                          bool isPremium = _customerInfo!.entitlements.all["necklife"] != null ? _customerInfo!.entitlements.all["necklife"]!.isActive : false;
                          if (isPremium) {
                            return;
                          }

                          await _purchaseSupscription(userStatus);
                        } on Exception catch(e) {
                          _showErrorPopUp();
                        }
                      },
                      text: 'setting_subpages.my_subscription.my_subscription_view.subscription_price'.tr(),
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
                      child:  TextDefault(content: 'setting_subpages.my_subscription.my_subscription_view.privacy_policy'.tr(), fontSize: 12, isBold: false, fontColor: Color(0xFF64646F),),
                    ),
                    // Text('    '),
                    GestureDetector(
                      onTap: () async {
                        await openUrlHelper.openTermOfService();
                      },
                      child: TextDefault(content: 'setting_subpages.my_subscription.my_subscription_view.terms_of_service'.tr(), fontSize: 12, isBold: false, fontColor: Color(0xFF64646F),),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Paywall()));
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: res.percentHeight(2), bottom: res.percentHeight(5)),
                        width: res.deviceWidth,
                        alignment: Alignment.center,
                        child:  TextDefault(content: 'setting_subpages.my_subscription.my_subscription_view.subscription_detail'.tr(), fontSize: 16, isBold: true, fontColor: Color(0xFF64646F),),
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

