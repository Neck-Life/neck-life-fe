import 'package:easy_localization/easy_localization.dart';
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
            content: Text('setting_subpages.paywall.paywall_view.error'.tr(),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            TextDefault(
                              content: 'setting_subpages.paywall.paywall_view.neckLife_premium'.tr(),
                              fontSize: 24,
                              isBold: true,
                              fontColor: Color(0xFF236EF3),
                            ),
                            TextDefault(
                              content: 'setting_subpages.paywall.paywall_view.and'.tr(),
                              fontSize: 24,
                              isBold: true,
                              fontColor: Colors.black,
                            )
                          ],
                        ),
                        TextDefault(
                          content: 'setting_subpages.paywall.paywall_view.more_contents'.tr(),
                          fontSize: 24,
                          isBold: true,
                          fontColor: Colors.black,
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(height: res.percentHeight(5),),
                ExplainItem(icon: 'dt', title: 'setting_subpages.paywall.paywall_view.dt_title'.tr(), content: 'setting_subpages.paywall.paywall_view.dt_content'.tr()),
                ExplainItem(icon: 'ad', title: 'setting_subpages.paywall.paywall_view.ad_title'.tr(), content: 'setting_subpages.paywall.paywall_view.ad_content'.tr()),
                ExplainItem(icon: 'other', title: 'setting_subpages.paywall.paywall_view.other_title'.tr(), content: 'setting_subpages.paywall.paywall_view.other_content'.tr()),
                const Spacer(),
                Button(
                  onPressed: () async {
                    bool isPremium = await Provider.of<UserStatus>(context, listen: false).getUserIsPremium();
                    if (isPremium) {
                      return;
                    }
                    await _purchaseSupscription(userStatus);
                  },
                  text: 'setting_subpages.paywall.paywall_view.subscription_price'.tr(),
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
                  child: TextDefault(content: 'setting_subpages.paywall.paywall_view.privacy_policy'.tr(), fontSize: 12, isBold: false, fontColor: Color(0xFF64646F),),
                ),
                // Text('    '),
                GestureDetector(
                  onTap: () async {
                    await openUrlHelper.openTermOfService();
                  },
                  child: TextDefault(content:'setting_subpages.paywall.paywall_view.terms_of_service'.tr(), fontSize: 12, isBold: false, fontColor: Color(0xFF64646F),),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: res.percentHeight(2), bottom: res.percentHeight(5)),
                    width: res.deviceWidth,
                    alignment: Alignment.center,
                    child: TextDefault(content: 'setting_subpages.paywall.paywall_view.continue_free_plan'.tr(), fontSize: 16, isBold: true, fontColor: Color(0xFF64646F),),
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