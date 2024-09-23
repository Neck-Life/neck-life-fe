import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
/**
 * TODO
 * 크레딧을 보여주는것보다는 사용시간을 보여주기
 * 오늘 하루가 지나면 사라지기
 * -> prepare브랜치가 dev브랜치로 pr된 뒤에 다시 구현 예정
 *
 * */

class RewardedAdManager {
  RewardedAd? _rewardedAd;
  int credits = 0;
  final int bonusTimePerCredit = 30; //크레딧 하나당 추가 체험시간 30분

  RewardedAdManager() {
    loadRewardedAd(); // 클래스가 생성될 때 광고 로드
    _loadCredits(); // 스토리지에서 크레딧 로드
  }

  // 크레딧을 스토리지에서 불러오기
  Future<void> _loadCredits() async {
    String? storedCredits = await storage.read(key: 'credits');
    if (storedCredits != null) {
      credits = int.parse(storedCredits);
    }
  }

  // 크레딧을 스토리지에 저장
  Future<void> _saveCredits() async {
    await storage.write(key: 'credits', value: credits.toString());
  }

  // 리워드 광고 로드
  void loadRewardedAd() {
    RewardedAd.load(
      /**
       * adUnitId에 진짜 ID 넣어야함
       * dotenv에 넣던가 해야할듯
       * 광고계정이 바뀌면, info.plist에 있는 내용도 바꿔야함
       * info.plist
       * <key>GADApplicationIdentifier</key>
          <string>ca-app-pub-4299841579411814~1457604906</string> //유성이 광고 계정
       * */
      adUnitId: 'ca-app-pub-3940256099942544/1712485313', // 테스트 광고 ID
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          print('Failed to load rewarded ad: $error');
        },
      ),
    );
  }

  // 리워드 광고 표시
  void showRewardedAd(BuildContext context, Function updateCredits) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
        credits += 1; // 크레딧 지급
        await _saveCredits(); // 크레딧을 스토리지에 저장
        updateCredits(); // UI 업데이트 콜백 호출
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('크레딧 1개가 추가되었습니다. 현재 크레딧: $credits')),
        );
        // 광고가 끝난 후 광고 다시 로드
        loadRewardedAd();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('광고를 불러오는 중입니다. 잠시 후 다시 시도하세요.')),
      );
    }
  }

  int getBonusTime(){
    return bonusTimePerCredit * credits;
  }

}

class RewardedAdButton extends StatefulWidget {
  final RewardedAdManager adManager;

  const RewardedAdButton({Key? key, required this.adManager}) : super(key: key);

  @override
  _RewardedAdButtonState createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  int currentCredits = 0;

  @override
  void initState() {
    super.initState();
    _loadCredits(); // 화면 초기화 시 크레딧 불러오기
  }

  Future<void> _loadCredits() async {
    // 스토리지에서 크레딧 불러오기
    await widget.adManager._loadCredits();
    setState(() {
      currentCredits = widget.adManager.credits;
    });
  }

  void _updateCredits() {
    setState(() {
      currentCredits = widget.adManager.credits;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('추가 체험시간 : +${widget.adManager.getBonusTime()}분'),
          ElevatedButton(
            onPressed: () {
              widget.adManager.showRewardedAd(context, _updateCredits); // 광고 시청 후 크레딧 업데이트
            },

            child: Text('리워드 광고 보기'),
          ),
          // const SizedBox(width: 20), // 버튼과 크레딧 사이의 간격
          // Text('현재 크레딧: $currentCredits', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}