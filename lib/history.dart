import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocksum_flutter/goal_setting.dart';
import 'package:mocksum_flutter/today_history.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/util/history_provider.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/widgets/line_chart.dart';
import 'package:mocksum_flutter/widgets/text_default.dart';
import 'package:provider/provider.dart';


class History extends StatefulWidget {
  const History({required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  late Map<String, int> poseCount;
  late final _internetCheckListener;
  bool _isInternetConnected = true;

  @override
  void initState() {
    // setState(() async {
    //   _isInternetConnected = await InternetConnection().hasInternetAccess;
    // });
    _internetCheckListener = InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          setState(() {
            _isInternetConnected = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            _isInternetConnected = false;
          });
          break;
      }
    });
    super.initState();
    // _historyStatus = HistoryStatus();
    // Future.delayed(Duration.zero, () {
    //   _chosenGoalSetting = HistoryStatus.chosenGoalSetting;
    // });
  }


  @override
  void dispose() {
    _internetCheckListener.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    HistoryStatus historyStatus = Provider.of(context);

    return SizedBox(
      width: responsive.deviceWidth,
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(height: responsive.percentHeight(7.5),),
             !_isInternetConnected ?
              Container(
                width: responsive.deviceWidth,
                // margin: EdgeInsets.only(top: responsive.percentHeight(7.5)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFFFF4545),
                ),
                child: Text('인터넷 연결을 확인해주세요. 정보가 최신 버전이 아닐 수 있습니다.'),
              ) : const SizedBox(),
              FutureBuilder(
                future: historyStatus.getTodayHistoryData(),
                builder: (context, snapshot) {
                  print('draw');
                  if (snapshot.hasData == false) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('해당 날짜의 데이터를 찾을 수 없습니다.'),
                    );
                  } else {
                    return Column(
                      children: [
                        Container(
                            width: responsive.percentWidth(85),
                            height: responsive.percentWidth(85)*0.3,
                            margin: EdgeInsets.only(top: responsive.percentHeight(1)),
                            padding: EdgeInsets.only(left: responsive.percentWidth(7.5), right: responsive.percentWidth(7.5)),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const TextDefault(content: '내 자세 점수', fontSize: 20, isBold: true),
                                SizedBox(
                                  width: responsive.percentWidth(15),
                                  height: responsive.percentWidth(15),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CircularProgressIndicator(
                                        value: snapshot.data?['success'] ? (snapshot.data?['point'] / 100) : 0,
                                        strokeWidth: 6,
                                        backgroundColor: const Color(0xFFE2E2E2),
                                        color: const Color(0xFF03A000),
                                      ),
                                      Center(
                                        child: TextDefault(
                                          content: snapshot.data?['success'] ? '${snapshot.data?['point']}점' : '',
                                          fontSize: 16,
                                          isBold: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                        ),
                        Container(
                          width: responsive.percentWidth(85),
                          // height: responsive.percentWidth(85)*0.3,
                          margin: EdgeInsets.only(top: responsive.percentHeight(2)),
                          padding: EdgeInsets.only(bottom: responsive.percentHeight(3)),
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
                              Container(
                                width: responsive.percentWidth(85),
                                padding: EdgeInsets.only(left: responsive.percentWidth(5), top: responsive.percentHeight(2)),
                                child: GestureDetector(
                                  child: const TextDefault(content: '오늘의 기록 >', fontSize: 16, isBold: true),
                                  onTap: () {
                                    // if (snapshot.data?['success']) {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => const TodayHistory()));
                                    // }
                                  },
                                ),
                              ),
                              SizedBox(height: responsive.percentHeight(3),),
                              !snapshot.data?['success']?
                              const TextDefault(content: '오늘의 자세를 기록해보세요!', fontSize: 20, isBold: true) :
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset("assets/history_icon.png"),
                                  TextDefault(
                                    content: '거북목 ${snapshot.data?['poseCountMap']['FORWARD'] ?? 0}회',
                                    fontSize: 20,
                                    isBold: true,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                }
              ),
              FutureBuilder(
                future: historyStatus.getScoreSeries(),
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('해당 날짜의 데이터를 찾을 수 없습니다.'),
                    );
                  } else {
                    return Container(
                      width: responsive.percentWidth(85),
                      // height: responsive.percentWidth(85)*0.3,
                      margin: EdgeInsets.only(top: responsive.percentHeight(2)),
                      // padding: EdgeInsets.only(left: responsive.percentWidth(7.5), right: responsive.percentWidth(7.5)),
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
                            child: const TextDefault(content: '점수의 변화를 확인해보세요', fontSize: 16, isBold: true,),
                          ),
                          snapshot.data?['success'] ?
                          ScoreChart(scoreValues: snapshot.data?['historyPointMap']) :
                            Container(
                              margin: EdgeInsets.only(top: responsive.percentHeight(2), bottom: responsive.percentHeight(2)),
                              child: const TextDefault(content: '자세를 기록해보세요!', fontSize: 16, isBold: true),
                            )
                        ],
                      ),
                    );
                  }
                }
              ),
              Container(
                width: responsive.percentWidth(85),
                // height: responsive.percentWidth(85)*0.3,
                margin: EdgeInsets.only(top: responsive.percentHeight(2)),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const GoalSetting()));
                      },
                      child: Container(
                        width: responsive.percentWidth(85),
                        padding: EdgeInsets.only(left: responsive.percentWidth(5)),
                        child: const TextDefault(content: '목표 설정 >', fontSize: 16, isBold: true),
                      ),
                    ),
                    historyStatus.goalsList() != null ?
                    Column(
                      children: historyStatus.goalsList()?['goals'].map<Widget>((item) {
                        return Container(
                          width: responsive.percentWidth(70),
                          // height: responsive.percentWidth(85)*0.3,
                          margin: EdgeInsets.only(
                              top: responsive.percentHeight(2)),
                          padding: EdgeInsets.only(
                              left: responsive.percentWidth(7.5),
                              top: responsive.percentWidth(2),
                              bottom: responsive.percentWidth(2)),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFECECEC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 4,
                                offset: Offset(0, 0),
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: TextDefault(
                            content: item['description'],
                            fontSize: 14,
                            isBold: false,
                          ),
                        );
                      }).toList()
                    ) :
                    FutureBuilder(
                      future: historyStatus.getUserGoalSetting(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData == false) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text('목표 정보를 불러올 수 없습니다.'),
                          );
                        } else {
                          if (snapshot.data?['success'] == false) {
                            return const SizedBox();
                          }
                          return Column(
                            children: (snapshot.data?['goals'].map<Widget>((item) {
                              return Container(
                                width: responsive.percentWidth(70),
                                // height: responsive.percentWidth(85)*0.3,
                                margin: EdgeInsets.only(
                                    top: responsive.percentHeight(2)),
                                padding: EdgeInsets.only(
                                    left: responsive.percentWidth(7.5),
                                    top: responsive.percentWidth(2),
                                    bottom: responsive.percentWidth(2)),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFECECEC),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 0),
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                                child: TextDefault(
                                  content: item['description'],
                                  fontSize: 14,
                                  isBold: false,
                                ),
                              );
                            }).toList()),
                          );
                        }
                      }
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10,)
            ],
          )
        )
      );
  }

}