
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  List<String> bannerIdList = [
    'ca-app-pub-8228957074402081/8163221235',
    'ca-app-pub-8228957074402081/5346047288',
    'ca-app-pub-8228957074402081/3018705763',
    'ca-app-pub-8228957074402081/5453297411'
  ];

  // List<String> bannerIdList = [
  //   'ca-app-pub-4299841579411814/1760857231',
  //   'ca-app-pub-4299841579411814/8948635978',
  //   'ca-app-pub-4299841579411814/6474192470',
  //   'ca-app-pub-4299841579411814/3614163217'
  // ];

  String testAdId = 'ca-app-pub-3940256099942544/2934735716';

  BannerAd getBannerAd(bool isTest, int id) {
    String bannerID = dotenv.get('BANNER_ID${id+1}');
    return BannerAd(
        size: AdSize.banner,
        adUnitId: isTest ? testAdId : bannerID, //
        listener: BannerAdListener(
            onAdLoaded: (_) {
              log('loaded');
            },
            onAdFailedToLoad: (ad, error) {
              print(error);
              ad.dispose();
            }
        ),
        request: const AdRequest()
    );
  }
}