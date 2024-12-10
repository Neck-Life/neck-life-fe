import 'dart:math';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mocksum_flutter/service/goal_provider.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/view/goal/date_cell.dart';
import 'package:mocksum_flutter/view/goal/streak_explain.dart';
import 'package:mocksum_flutter/view/goal/subpage/goal_setting.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/view/goal/subpage/widget/goal_list_item.dart';
import 'package:mocksum_flutter/view/history/history_view.dart';
import 'package:mocksum_flutter/view/today_history/today_history_view.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../service/history_provider.dart';
import '../../theme/blur_to_login.dart';
import '../../util/ad_manager.dart';
import '../home/widgets/app_bar.dart';
import '../home/widgets/banner_carousel.dart';


class Goal extends StatefulWidget {
  const Goal({super.key});

  @override
  State<StatefulWidget> createState() => _GoalState();
}

class _GoalState extends State<Goal> {
  // static const storage = FlutterSecureStorage();

  Map<String, dynamic> _goalMap = {
    'score': {},
    'time': {}
  };

  List<int> _goalRateList = List.filled(30, 0);
  int _nowStreak = 0;
  late BannerAd _ad;
  bool _addGoalPressed = false;

  @override
  void initState() {
    if (UserStatus.sIsLogged) {
      getGoalStatus();
    }
    _ad = AdManager().getBannerAd(true, 2);
    _ad.load();

    super.initState();
  }

  Future<void> getGoalStatus() async {
    // print('getsore');
    try {
      String? accessToken = await storage.read(key: 'accessToken');

      if (accessToken != null && accessToken != '') {
        HistoryStatus.dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response goalInfoRes = await HistoryStatus.dio.get(
          '${HistoryStatus.serverAddress}/goals');

      Response successInfoRes = await HistoryStatus.dio.get(
          '${HistoryStatus.serverAddress}/goals/history');

      Response streakInfoRes = await HistoryStatus.dio.get(
          '${HistoryStatus.serverAddress}/goals/recent30');

      // Response streakInfoRes = await HistoryStatus.dio.get(
      //     '${HistoryStatus.serverAddress}/goals/streak');
      //
      // print(streakInfoRes.data);

      Map<String, dynamic> goalMap = {
        'score': {},
        'time': {}
      };
      List<int> goalRateList = List.filled(30, 0);

      // print(goalInfoRes.data);
      // print(successInfoRes.data);
      if (streakInfoRes.data['code'] == 'success') {
        int idx = 0;
        for (var obj in streakInfoRes.data['data']) {
          goalRateList[idx++] = obj['point'];
        }
      }
      if (goalInfoRes.data['code'] == 'success') {
        for (var goalObj in goalInfoRes.data['data']['goals']) {
          // print('loop $goalObj');
          if (goalObj['type'] == 'MEASUREMENT') {
            goalMap['time'] = goalObj;
          } else if (goalObj['type'] == 'SCORE') {
            goalMap['score'] = goalObj;
          }
        }
      } else {
        throw Exception();
      }

      // List<double> goalRateList = List.filled(30, 0);
      // print(successInfoRes.data['data']['goalHistories']);
      if (successInfoRes.data['code'] == 'success') {
        DateTime now = DateTime.now();
        String today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        successInfoRes.data['data']['goalHistories'].forEach((key, value) {
          if (key == today) {
            if (value['SCORE'] != null) {
              goalMap['score']['achieved_rate'] = value['SCORE'];
            }
            if (value['MEASUREMENT'] != null) {
              goalMap['time']['achieved_rate'] = value['MEASUREMENT'];
            }
          }
        });

        // now = now.subtract(const Duration(days: 29));
        // for (int i = 0; i <= 29; i++, now = now.add(const Duration(days: 1))) {
        //   String dateStr = '${now.year.toString()}-${now.month.toString().padLeft(
        //       2, '0')}-${now.day.toString().padLeft(2, '0')}';
        //   double rate = 0;
        //   if (successInfoRes.data['data']['goalHistories'].containsKey(dateStr)) {
        //     final rateMap = successInfoRes.data['data']['goalHistories'][dateStr];
        //     if (rateMap != null) {
        //       rate = (rateMap['SCORE'] ?? 0) + (rateMap['MEASUREMENT'] ?? 0);
        //       if (rateMap['SCORE'] != null && rateMap['MEASUREMENT'] != null) {
        //         rate /= 2;
        //       }
        //     }
        //   }
        //   goalRateList[i] = rate;
        // }
      } else {
        throw Exception();
      }

      // print(goalMap);
      int streak = 0;

      for (int i = 28; i >= 0; i--) {
        if (goalRateList[i] >= 1) {
          streak += 1;
        } else {
          break;
        }
      }
      if (goalRateList[29] >= 1) {
        streak += 1;
      }
      setState(() {
        _goalMap = goalMap;
        _goalRateList = goalRateList;
        _nowStreak = streak;
      });

      print(goalRateList);

      context.read<GoalProvider>().updateGoalMap(goalMap);
      if (goalMap['score']['type'] != null) {
        context.read<GoalProvider>().addSettedGoalTypes(GoalType.score);
      }
      if (goalMap['time']['type'] != null) {
        context.read<GoalProvider>().addSettedGoalTypes(GoalType.time);
      }

    } on Exception catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    GoalProvider goalState = context.watch();
    UserStatus userStatus = context.watch();

    return Scaffold(
        appBar:  const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: HomeAppBar()
        ),
        // appBar: PreferredSize(
        //     preferredSize: const Size.fromHeight(60),
        //     child: userStatus.isLogged ? const BannerCarousel() : const HomeAppBar()
        // ),
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.only(top: res.percentHeight(3.5)),
            padding: EdgeInsets.only(left: res.percentWidth(7.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextDefault(content: 'goal_view.goal_txt1'.tr(), fontSize: 26, isBold: true, fontColor: const Color(0xFF101010),),
                TextDefault(content: 'goal_view.goal_txt2'.tr(), fontSize: 26, isBold: true, fontColor: const Color(0xFF236EF3),),
                SizedBox(height: res.percentHeight(2),),
                Stack(
                  children: [
                    Column(
                      children: [
                        GoalListItem(
                          goalType: GoalType.score,
                          targetValue: goalState.goalMap['score']['targetValue'] != null ? goalState.goalMap['score']['targetValue'].toDouble() : 85,
                          isSet: goalState.goalMap['score']['targetValue'] != null,
                          achieveRate: goalState.goalMap['score']['achieved_rate'] ?? 0,
                        ),
                        SizedBox(height: res.percentHeight(1),),
                        GoalListItem(
                          goalType: GoalType.time,
                          targetValue: goalState.goalMap['time']['targetValue'] != null ? goalState.goalMap['time']['targetValue'].toDouble() : 900,
                          isSet: goalState.goalMap['time']['targetValue'] != null,
                          achieveRate: goalState.goalMap['time']['achieved_rate'] ?? 0
                        )
                      ],
                    ),
                    !userStatus.isLogged ? const Positioned(
                      // left: res.percentWidth(25),
                        child: BlurToLogin(width: 90, height: 17.5, tab: 'goal')
                    ) : const SizedBox()
                  ],
                ),
                SizedBox(height: res.percentHeight(3),),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (todayHistoryPage != null) {
                          Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => todayHistoryPage!));
                        }
                      },
                      child: WhiteContainer(
                        padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: context.locale.languageCode == 'ko' ? [
                                TextDefault(content: '$_nowStreak일 ', fontSize: 18, isBold: true, fontColor: const Color(0xFF236EF3),),
                                const TextDefault(content: '연속 출석 중!', fontSize: 18, isBold: true),
                                SizedBox(width: res.percentWidth(2),),
                                GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          useSafeArea: false,
                                          builder: (context) {
                                            return const StreakExplain();
                                          });
                                    },
                                    child: AssetIcon('help', color: const Color(0xFF8991A0), size: res.percentWidth(1.25),)
                                )
                              ] : [
                                const TextDefault(content: 'Hit ', fontSize: 18, isBold: true),
                                TextDefault(content: '${_nowStreak == 1 ? 'a' : _nowStreak } ${_nowStreak == 1 ? 'Day' : 'Days'} ', fontSize: 18, isBold: true, fontColor: const Color(0xFF236EF3),),
                                const TextDefault(content: 'in a Row!', fontSize: 18, isBold: true),
                                SizedBox(width: res.percentWidth(2),),
                                GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          useSafeArea: false,
                                          builder: (context) {
                                            return const StreakExplain();
                                          });
                                    },
                                    child: AssetIcon('help', color: const Color(0xFF8991A0), size: res.percentWidth(1.25),)
                                )
                              ],
                            ),
                            SizedBox(height: res.percentHeight(1),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _goalRateList.sublist(0, 10).map((val) {
                                return DateCell(rate: val/100);
                              }).toList(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _goalRateList.sublist(10, 20).map((val) {
                                return DateCell(rate: val/100);
                              }).toList(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(10, (idx) {
                                return DateCell(rate: _goalRateList[20+idx]/100, isToday: idx == 9,);
                              }),
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: _goalRateList.sublist(21, 28).map((val) {
                            //     return DateCell(rate: val);
                            //   }).toList(),
                            // )
                          ],
                        ),
                      ),
                    ),
                    !userStatus.isLogged ? const Positioned(
                      // left: res.percentWidth(25),
                        child: BlurToLogin(width: 90, height: 20, tab: 'goal')
                    ) : const SizedBox()
                  ],
                ),
                userStatus.isPremium ? const SizedBox() : Container(
                  margin: EdgeInsets.only(left: max((res.deviceWidth-_ad.size.width.toDouble())/2-res.percentWidth(7.5), 0), top: res.percentHeight(1.5)),
                  width: _ad.size.width.toDouble(),
                  height: _ad.size.height.toDouble(),
                  alignment: Alignment.center,
                  child: AdWidget(ad: _ad),
                ),
                const Spacer(),
                GestureDetector(
                  onTapUp: (details) {
                    setState(() {
                      _addGoalPressed = false;
                    });
                    if (userStatus.isLogged) {
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) => const GoalSetting()));
                    }
                  },
                  onTapDown: (details) {
                    setState(() {
                      _addGoalPressed = true;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _addGoalPressed = false;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: res.percentHeight(3), left: res.percentWidth(context.locale.languageCode == 'ko' ? 57.5 : 54.5)),
                    width: res.percentWidth(context.locale.languageCode == 'ko' ? 30 : 33),
                    // height: res.percentHeight(5),
                    padding: EdgeInsets.symmetric(horizontal: res.percentWidth(3.25), vertical: res.percentHeight(1.75)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: _addGoalPressed ? const Color(0xFF236EF3).withOpacity(0.7) : const Color(0xFF236EF3)
                    ),
                    child: Row(
                      children: [
                        AssetIcon('plus', size: res.percentWidth(1.25), color: Colors.white,),
                        SizedBox(width: res.percentWidth(1),),
                        TextDefault(content: 'goal_view.add_goal'.tr(), fontSize: 16, isBold: true, fontColor: Colors.white,)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }

}