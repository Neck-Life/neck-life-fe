import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

//...

// Future<void> initPlatformState() async {
//   await Purchases.setLogLevel(LogLevel.debug);
//
//   PurchasesConfiguration configuration;
//
//   configuration = PurchasesConfiguration('appl_cITGFaxfFmfrUEYToWETNmfDITU');
//   await Purchases.configure(configuration);
//
//   try {
//     Offerings offerings = await Purchases.getOfferings();
//     if (offerings.current != null) {
//       // Display current offering with offerings.current
//     }
//   } on PlatformException catch (e) {
//     // optional error handling
//     print(e);
//   }
//
// }
//
// Future<void> purchaseSubs() async {
//   try {
//     CustomerInfo customerInfo = await Purchases.purchasePackage(package);
//     if (customerInfo.entitlements.all["my_entitlement_identifier"].isActive) {
//       // Unlock that great "pro" content
//     }
//   } on PlatformException catch (e) {
//     var errorCode = PurchasesErrorHelper.getErrorCode(e);
//     if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
//       showError(e);
//     }
//   }
// }