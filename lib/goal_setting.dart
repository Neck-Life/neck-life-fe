import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/service/history_provider.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:provider/provider.dart';


class GoalSetting extends StatefulWidget {
  const GoalSetting({super.key});

  @override
  State<StatefulWidget> createState() => _GoalSettingState();
}

class _GoalSettingState extends State<GoalSetting> {

  AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();
  late Map<String, int> poseCount;

  List<Map<String, dynamic>> _weeklySuccessGoalRatio = [
    {'day': 'Mon', 'ratio':0},
    {'day': 'Tue', 'ratio':0},
    {'day': 'Wed', 'ratio':0},
    {'day': 'Thu', 'ratio':0},
    {'day': 'Fri', 'ratio':0},
    {'day': 'Sat', 'ratio':0},
    {'day': 'Sun', 'ratio':0}
  ];

  Map<String, dynamic> _chosenSettingMap = {
    'MEASUREMENT': {
      'chosen': false,
      'id': 0,
    },
    'SCORE': {
      'chosen': false,
      'id': 0,
    }
  };

  int _nowStreak = 0;

  void _changeGoalSetting(String type, int value, String desc, HistoryStatus hsObj) async {
    setState(() {
      _chosenSettingMap[type]['chosen'] = !_chosenSettingMap[type]['chosen'];
    });

    bool success = false;
    if (_chosenSettingMap[type]['chosen']) {
      success = await hsObj.addGoalSetting(type, value, desc);
      print(success);
    } else {
      success = await hsObj.deleteGoalSetting(_chosenSettingMap[type]['id']);
      print(success);
    }

  }

  @override
  void initState() {
    super.initState();
    _amplitudeEventManager.viewEvent('goalsetting');
    Future.delayed(Duration.zero, () async {
      List<dynamic> chosenList = Provider.of<HistoryStatus>(context, listen: false).goalsList()?['goals'];
      print('chosen $chosenList');

      for (Map<String, dynamic> item in chosenList) {
        print(item);
        setState(() {
          _chosenSettingMap[item['type']]['chosen'] = true;
          _chosenSettingMap[item['type']]['id'] = item['order'];
        });
      }
      print(_chosenSettingMap);

      Map<String, dynamic> goalHistory = await Provider.of<HistoryStatus>(context, listen: false).getGoalHistory();
      DateTime now = DateTime.now();

      if (goalHistory['success']) {
        for (int weekday = now.weekday; weekday >= 1; weekday--,
        now = now.subtract(const Duration(days: 1))) {
          if (goalHistory['goalHistories'].containsKey('${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}')) {
            setState(() {
              _weeklySuccessGoalRatio[weekday - 1]['ratio'] = goalHistory['goalHistories']['${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'];
            });
          }
        }
      }

      int nowStreak = await Provider.of<HistoryStatus>(context, listen: false).getGoalStreak();
      setState(() {
        _nowStreak = nowStreak;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    HistoryStatus historyStatus = Provider.of(context);

    return Scaffold(
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: responsive.percentHeight(7.5), left: responsive.percentWidth(7.5)),
                child: Text(
                  '목표를 설정하고 동기를 유지해보세요!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: responsive.fontSize(18),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: responsive.percentWidth(85),
                // height: responsive.percentWidth(85)*0.3,
                margin: EdgeInsets.only(top: responsive.percentHeight(2.5), left: responsive.percentWidth(7.5)),
                padding: EdgeInsets.only(left: responsive.percentWidth(7.5), top: responsive.percentHeight(1), bottom: responsive.percentHeight(1)),
                alignment: Alignment.centerLeft,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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
                child: Text(
                  _nowStreak > 0 ? '$_nowStreak일 연속 목표 달성 중!' : '오늘의 목표를 달성해보세요!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: responsive.fontSize(20),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: responsive.percentWidth(85),
                // height: responsive.percentWidth(85)*0.3,
                margin: EdgeInsets.only(top: responsive.percentHeight(2), left: responsive.percentWidth(7.5)),
                padding: EdgeInsets.only(top: responsive.percentHeight(2), bottom: responsive.percentHeight(2)),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                    _weeklySuccessGoalRatio.map((item) {
                      return Column(
                        children: [
                          SizedBox(
                            width: responsive.percentWidth(7),
                            height: responsive.percentWidth(7),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: item['ratio'].toDouble(),
                                  strokeWidth: 4,
                                  backgroundColor: const Color(0xFFE2E2E2),
                                  color: const Color(0xFF03A000),
                                ),
                                Center(
                                  child: item['ratio'] == 1 ? const Icon(Icons.check, color: Color(0xFF03A000)) : const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.percentHeight(1),),
                          Text(
                            item['day'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: responsive.fontSize(12),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                ),
              ),
              Container(
                width: responsive.percentWidth(85),
                // height: responsive.percentWidth(85)*0.3,
                margin: EdgeInsets.only(top: responsive.percentHeight(2), left: responsive.percentWidth(7.5)),
                padding: EdgeInsets.only(bottom: responsive.percentWidth(5)),
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
                  children: [
                    SizedBox(height: responsive.percentHeight(2),),
                    Container(
                      width: responsive.percentWidth(85),
                      padding: EdgeInsets.only(left: responsive.percentWidth(5)),
                      child: Text(
                        '목표 설정',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: responsive.fontSize(18),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _changeGoalSetting('MEASUREMENT', 2, '하루에 2시간 이상 측정', historyStatus);
                      },
                      child: Container(
                        width: responsive.percentWidth(70),
                        // height: responsive.percentWidth(85)*0.3,
                        margin: EdgeInsets.only(top: responsive.percentHeight(2)),
                        padding: EdgeInsets.only(left: responsive.percentWidth(7.5), right: responsive.percentWidth(5), top: responsive.percentWidth(2), bottom: responsive.percentWidth(2)),
                        decoration: BoxDecoration(
                            color: const Color(0xFFECECEC),
                            borderRadius: BorderRadius.circular(20),
                            border: _chosenSettingMap['MEASUREMENT']['chosen'] ? Border.all(color: Colors.black) : null
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '하루에 2시간 이상 측정',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(14),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              _chosenSettingMap['MEASUREMENT']['chosen'] ? '-': '+',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(20),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w300,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _changeGoalSetting('SCORE', 80, '오늘의 자세 점수 80점 이상 달성', historyStatus);
                      },
                      child: Container(
                        width: responsive.percentWidth(70),
                        // height: responsive.percentWidth(85)*0.3,
                        margin: EdgeInsets.only(top: responsive.percentHeight(2)),
                        padding: EdgeInsets.only(left: responsive.percentWidth(7.5), right: responsive.percentWidth(5), top: responsive.percentWidth(2), bottom: responsive.percentWidth(2)),
                        decoration: BoxDecoration(
                            color: const Color(0xFFECECEC),
                            borderRadius: BorderRadius.circular(20),
                            border: _chosenSettingMap['SCORE']['chosen'] ? Border.all(color: Colors.black) : null
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '오늘의 자세 점수 80점 이상 달성',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(14),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              _chosenSettingMap['SCORE']['chosen'] ? '-': '+',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.fontSize(20),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w300,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     historyStatus.changeGoalSetting('continueOption');
                    //   },
                    //   child: Container(
                    //     width: responsive.percentWidth(70),
                    //     // height: responsive.percentWidth(85)*0.3,
                    //     margin: EdgeInsets.only(top: responsive.percentHeight(2)),
                    //     padding: EdgeInsets.only(left: responsive.percentWidth(7.5), right: responsive.percentWidth(5), top: responsive.percentWidth(2), bottom: responsive.percentWidth(2)),
                    //     decoration: BoxDecoration(
                    //         color: const Color(0xFFECECEC),
                    //         borderRadius: BorderRadius.circular(20),
                    //         border: historyStatus.chosenGoalSetting()['continueOption']['chosen'] ? Border.all(color: Colors.black) : null
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Text(
                    //           '${historyStatus.chosenGoalSetting()['continueOption']['setting']}분 동안 자세 무너지지 않기',
                    //           style: TextStyle(
                    //             color: Colors.black,
                    //             fontSize: responsive.fontSize(14),
                    //             fontFamily: 'Inter',
                    //             fontWeight: FontWeight.w300,
                    //           ),
                    //         ),
                    //         Text(
                    //           historyStatus.chosenGoalSetting()['continueOption']['chosen'] ? '-': '+',
                    //           style: TextStyle(
                    //             color: Colors.black,
                    //             fontSize: responsive.fontSize(20),
                    //             fontFamily: 'Inter',
                    //             fontWeight: FontWeight.w300,
                    //           ),
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }

}