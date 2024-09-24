import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/util/history_provider.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:provider/provider.dart';


class TodayHistory extends StatefulWidget {
  const TodayHistory({super.key});

  @override
  State<StatefulWidget> createState() => _TodayHistoryState();
}

class _TodayHistoryState extends State<TodayHistory> {

  late HistoryStatus historyStatus;
  DateTime now = DateTime.now();
  DateTime date = DateTime.now();
  AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();

  @override
  void initState() {
    _amplitudeEventManager.viewEvent('todayhistory');
    super.initState();
  }

  String second2String(int sec) {

    if (sec == 0) {
      return '0';
    }
    int idx = 0;

    List<String> parts= ['00', '00', '00'];
    while (sec > 0) {
      parts[idx++] = (sec % 60).toString().padLeft(2, '0');
      sec = sec ~/ 60;
    }
    return List.from(parts.reversed).join(':');
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
            SizedBox(height: responsive.percentHeight(7.5),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      date = date.subtract(const Duration(days: 1));
                    });
                  },
                  child: Text(
                    '<',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: responsive.fontSize(20),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${date.month}월 ${date.day}일',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: responsive.fontSize(20),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (date.year == now.year && date.month == now.month && date.day == now.day) {
                      return;
                    }
                    setState(() {
                      date = date.add(const Duration(days: 1));
                    });
                  },
                  child: Text(
                    '>',
                    style: TextStyle(
                      color: date.year == now.year && date.month == now.month && date.day == now.day ? Colors.grey : Colors.black,
                      fontSize: responsive.fontSize(20),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
            FutureBuilder(
              future: historyStatus.getPastHistoryWithDate('${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'),
              builder: (innerContext, snapshot) {
                if (snapshot.hasData == false) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('해당 날짜의 데이터를 찾을 수 없습니다.'),
                  );
                } else {
                  // print('today ${snapshot.data?['history'].keys.toList()[0]}');
                  int abnormalTimeSum = 0;
                  Map<String, dynamic> filteredForwardMap = {};
                  if (snapshot.data?['success'] == true) {
                    snapshot.data?['poseTimerMap'].forEach((key, val) {
                      abnormalTimeSum += val as int;
                    });

                    snapshot.data?['history'].forEach((key, val) {
                      if (val == 'FORWARD') {
                        filteredForwardMap[key] = val;
                      }
                    });
                  }
                  // print('fuck ${snapshot.data?['poseTimerMap']}');

                  return Column(
                    children: [
                      Container(
                          width: responsive.percentWidth(85),
                          height: responsive.percentWidth(85) * 0.3,
                          margin: EdgeInsets.only(top: responsive.percentHeight(
                              2)),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: responsive
                              .percentWidth(7.5), top: responsive.percentWidth(
                              5)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '바른 자세를 유지한 시간',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: responsive.fontSize(14),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                              snapshot.data?['success'] == true ?
                              '${second2String(snapshot.data?['poseTimerMap']['NORMAL'])}/${second2String((snapshot.data?['measurementTime'] ?? 0).round())}'
                                : '기록이 없습니다.',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: responsive.fontSize(28),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                      ),
                      Container(
                        width: responsive.percentWidth(85),
                        // height: responsive.percentWidth(85)*0.3,
                        margin: EdgeInsets.only(top: responsive.percentHeight(
                            2)),
                        padding: EdgeInsets.only(bottom: responsive
                            .percentHeight(3)),
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
                            // Container(
                            //   width: responsive.percentWidth(85),
                            //   padding: EdgeInsets.only(
                            //       left: responsive.percentWidth(5),
                            //       top: responsive.percentHeight(2)),
                            //   child: Text(
                            //     '오늘의 기록 >',
                            //     style: TextStyle(
                            //       color: Colors.black,
                            //       fontSize: responsive.fontSize(16),
                            //       fontFamily: 'Inter',
                            //       fontWeight: FontWeight.w600,
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: responsive.percentHeight(3),),
                            snapshot.data?['success'] ?
                            SizedBox(
                              height: responsive.percentHeight(50 < snapshot.data?['history'].length*10.toDouble() ? 50 : snapshot.data?['history'].length*10.toDouble()),
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: filteredForwardMap.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(left: responsive.percentWidth(3)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Stack(
                                          children: [
                                            Positioned(
                                              left: responsive.percentWidth(7.5),
                                              child: Container(
                                                width: 2,
                                                height: responsive.percentHeight(7.5),
                                                decoration: const BoxDecoration(
                                                    color: Colors.black
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: responsive.percentHeight(7.5),
                                              child: Image.asset("assets/history_icon.png"),
                                            )
                                          ],
                                        ),
                                        SizedBox(width: responsive.percentWidth(7.5),),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '거북목 자세 탐지',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: responsive.fontSize(16),
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                            filteredForwardMap.keys.toList()[index].split('T')[1],
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: responsive.fontSize(16),
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }
                              ),
                            ) : const SizedBox()
                          ],
                          ),
                      ),
                    ],
                  );
                }
              }
            )
          ],
        ),
      ),
    );
  }

}