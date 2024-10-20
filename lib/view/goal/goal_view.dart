
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/service/goal_provider.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/view/goal/subpage/goal_setting.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/view/goal/subpage/widget/goal_list_item.dart';
import 'package:provider/provider.dart';
import '../../service/history_provider.dart';
import '../home/widgets/app_bar.dart';


class Goal extends StatefulWidget {
  const Goal({super.key});

  @override
  State<StatefulWidget> createState() => _GoalState();
}

class _GoalState extends State<Goal> {

  Map<String, dynamic> _goalMap = {
    'score': {},
    'time': {}
  };

  @override
  void initState() {
    // if (UserStatus.sIsLogged) {
    getGoalStatus();
    // }
    super.initState();
  }


  Future<void> getGoalStatus() async {
    // print('getsore');
    const storage = FlutterSecureStorage();
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        HistoryStatus.dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response goalInfoRes = await HistoryStatus.dio.get(
          '${HistoryStatus.serverAddress}/goals');

      Response successInfoRes = await HistoryStatus.dio.get(
          '${HistoryStatus.serverAddress}/goals/history');

      Map<String, dynamic> goalMap = {
        'score': {},
        'time': {}
      };

      print(goalInfoRes.data);
      print(successInfoRes.data);
      if (goalInfoRes.data['code'] == 'success') {
        for (var goalObj in goalInfoRes.data['data']['goals']) {
          print('loop $goalObj');
          if (goalObj['type'] == 'MEASUREMENT') {
            goalMap['time'] = goalObj;
          } else if (goalObj['type'] == 'SCORE') {
            goalMap['score'] = goalObj;
          }
        }
      } else {
        throw Exception();
      }

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
      } else {
        throw Exception();
      }

      print(goalMap);
      setState(() {
        _goalMap = goalMap;
      });

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

    return SafeArea(
        child: Scaffold(
            appBar:  const PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: HomeAppBar()
            ),
            body: Container(
              margin: EdgeInsets.only(top: res.percentHeight(3.5)),
              padding: EdgeInsets.only(left: res.percentWidth(7.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextDefault(content: 'goal_view.goal_txt1'.tr(), fontSize: 26, isBold: true, fontColor: const Color(0xFF101010),),
                  TextDefault(content: 'goal_view.goal_txt2'.tr(), fontSize: 26, isBold: true, fontColor: Color(0xFF236EF3),),
                  SizedBox(height: res.percentHeight(2),),
                  GoalListItem(
                    goalType: GoalType.score,
                    targetValue: goalState.goalMap['score']['targetValue'] != null ? goalState.goalMap['score']['targetValue'].toDouble() : 85,
                    isSet: goalState.goalMap['score']['targetValue'] != null,
                    achieveRate: goalState.goalMap['score']['achieved_rate'] ?? 0,
                  ),
                  SizedBox(height: res.percentHeight(1),),
                  GoalListItem(
                      goalType: GoalType.time,
                      targetValue: goalState.goalMap['time']['targetValue'] != null ? goalState.goalMap['time']['targetValue'].toDouble() : 15,
                      isSet: goalState.goalMap['time']['targetValue'] != null,
                      achieveRate: goalState.goalMap['time']['achieved_rate'] ?? 0
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (
                          context) => const GoalSetting()));
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: res.percentHeight(3), left: res.percentWidth(context.locale.languageCode == 'ko' ? 57.5 : 54.5)),
                      width: res.percentWidth(context.locale.languageCode == 'ko' ? 30 : 33),
                      // height: res.percentHeight(5),
                      padding: EdgeInsets.symmetric(horizontal: res.percentWidth(3.25), vertical: res.percentHeight(1.75)),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xFF236EF3)
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
            )
        )
    );
  }

}