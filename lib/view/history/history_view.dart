import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocksum_flutter/goal_setting.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/view/history/widgets/duration_dropdown.dart';
import 'package:mocksum_flutter/view/history/widgets/score_explain.dart';
import 'package:mocksum_flutter/view/today_history/today_history_view.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/service/history_provider.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/util/time_convert.dart';
import 'package:mocksum_flutter/view/history/widgets/pose_count_frame.dart';
import 'package:mocksum_flutter/view/history/widgets/pose_time_map.dart';
import 'package:mocksum_flutter/view/history/widgets/pose_time_tile.dart';
import 'package:mocksum_flutter/view/history/widgets/score_bar.dart';
import 'package:mocksum_flutter/widgets/line_chart.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../model/pose_duration.dart';
import '../../theme/triangle.dart';
import '../home/widgets/app_bar.dart';


class History extends StatefulWidget {
  const History({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final GlobalKey todayKey = GlobalKey();
  final GlobalKey timelineKey = GlobalKey();


  late Map<String, int> poseCount;
  late final _internetCheckListener;
  bool _isInternetConnected = true;

  late ScrollController _scrollViewController;
  bool _showScorePart = true;
  bool isScrollingDown = false;

  List<PoseDuration> _poseDurationList = [];
  int _normalDurationSum = 0;
  int _normalDurationCount = 0;
  int _chosonDurationIdx = -1;

  int _anchorIdx = 0;
  String _scoreDurationValue = 'WEEK';

  Map<String, dynamic> _historyData = {'daily' : [], 'poseTimerMap': {}};
  Map<String, dynamic> _todayHistory = {'poseCountMap': {}, 'daily' : []};
  Map<String, int> _data2idx = {};

  // final dummy = {'2024-09-26T19:03:06': 'START', '2024-09-26T19:03:20': 'FORWARD', '2024-09-26T19:03:27': 'NORMAL', '2024-09-26T19:03:36': 'FORWARD', '2024-09-26T19:03:50': 'NORMAL', '2024-09-26T19:04': 'FORWARD', '2024-09-26T19:04:03': 'NORMAL', '2024-09-26T19:04:06': 'FORWARD', '2024-09-26T19:04:15': 'NORMAL', '2024-09-26T19:04:31': 'END', '2024-09-26T19:06:18': 'START', '2024-09-26T19:06:28': 'FORWARD', '2024-09-26T19:06:31': 'NORMAL', '2024-09-26T19:06:32': 'FORWARD', '2024-09-26T19:06:35': 'NORMAL', '2024-09-26T19:06:42': 'FORWARD', '2024-09-26T19:06:45': 'NORMAL', '2024-09-26T19:07:11': 'END'};

//  '2024-09-26T19:06:18': 'START', '2024-09-26T19:06:28': 'FORWARD', '2024-09-26T19:06:31': 'NORMAL', '2024-09-26T19:06:32': 'FORWARD', '2024-09-26T19:06:35': 'NORMAL', '2024-09-26T19:06:42': 'FORWARD', '2024-09-26T19:06:45': 'NORMAL', '2024-09-26T19:07:11': 'END'
  @override
  void initState() {
    super.initState();
    print('his view init');
    getHistoryData(DateTime.now().year, DateTime.now().month);

    _internetCheckListener = InternetConnection().onStatusChange.listen((InternetStatus status) async {
      switch (status) {
        case InternetStatus.connected:
          await HistoryStatus.postDataNotPosted();
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

    _scrollViewController = ScrollController();
    _scrollViewController.addListener(() {
      if (_scrollViewController.position.userScrollDirection == ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showScorePart = false;
          setState(() {});
        }
      }

      if (_scrollViewController.position.userScrollDirection == ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showScorePart = true;
          setState(() {});
        }
      }
    });

    Future.delayed(Duration.zero, () {
      timestamp2Duration(context.read<HistoryStatus>().todayHistory['history']);
    });
  }

  Future<void> getHistoryData(int year, int month) async {
    const storage = FlutterSecureStorage();
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        HistoryStatus.dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response res = await HistoryStatus.dio.get(
          '${HistoryStatus.serverAddress}/history/monthly?year=${year}&month=${month}');
      DateTime now = DateTime.now();
      if (res.data['code'] == 'success') {
          // print('ok');
        final historyData = res.data['data'];


        Map<String, int> date2idx = <String, int>{};
        int cnt = 0;
        // DateTime now = DateTime.now();
        for (Map<String, dynamic> data in historyData['daily']) {
          date2idx['$year-${month.toString().padLeft(2, '0')}-${data['date']
              .toString()
              .padLeft(2, '0')}'] = cnt++;
        }
        setState(() {
          _historyData = historyData;
          _data2idx = date2idx;
          String dateStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
          if (date2idx.containsKey(dateStr)) {
            // print('return');
            _todayHistory = historyData['daily'][date2idx[dateStr]];
          } else {
            // print('asdf');
            _todayHistory = {'poseCountMap': {}, 'daily' : []};
          }
        });
        timestamp2Duration(_todayHistory['history']);
        storage.write(
            key: 'posehistoryLocal', value: json.encode(_historyData));

      }
    } on DioException catch(e) {
      String? historyDataStr = await storage.read(key: 'posehistoryLocal');
      if (historyDataStr == null) {
        setState(() {
          _historyData = {'poseCountMap': {}, 'daily' : []};
        });
      } else {
        setState(() {
          _historyData = json.decode(historyDataStr);
        });
      }
    } on Exception catch (e) {
      print(e);
      setState(() {
        _historyData = {'poseCountMap': {}, 'daily' : []};
      });
    }
  }

  void timestamp2Duration(Map<String, dynamic>? historyMap) {
    if (historyMap == null) return;

    List<PoseDuration> poseDurationList = [];
    print('calc');

    String prevPose = '';
    DateTime? prevTime;
    List timestampKey = historyMap.keys.toList();
    int wholeDuration = DateTime.parse(timestampKey.last).difference(DateTime.parse(timestampKey[0])).inSeconds;
    double xOffset = 0;
    int normalDurationSum = 0;
    int normalDurationCount = 0;

    int idx = -1;
    historyMap.forEach((timestamp, value) {
      int duration = 0;
      DateTime time = DateTime.parse(timestamp);
      if (prevTime != null) {
        duration = time
            .difference(prevTime!)
            .inSeconds;
        xOffset += duration / wholeDuration;

        if (prevPose == 'START') {
          poseDurationList.add(PoseDuration(xOffset: xOffset,
            widthRate: duration / wholeDuration,
            durationType: DurationType.normal,
            startTime: '${(time.hour).toString().padLeft(2, '0')}:${(time.minute).toString().padLeft(2, '0')}'
          ));

          normalDurationSum += duration;
          normalDurationCount += 1;
        } else if (prevPose == 'END') {
          poseDurationList.add(PoseDuration(xOffset: xOffset,
            widthRate: duration / wholeDuration,
            durationType: DurationType.none,
            startTime: '${(time.hour).toString().padLeft(2, '0')}:${(time.minute).toString().padLeft(2, '0')}'
          ));
        } else if (prevPose == 'NORMAL') {
          if (value != 'NORMAL') {
            poseDurationList.add(PoseDuration(xOffset: xOffset,
              widthRate: duration / wholeDuration,
              durationType: DurationType.normal,
              startTime: '${(time.hour).toString().padLeft(2, '0')}:${(time.minute).toString().padLeft(2, '0')}'
            ));
            normalDurationSum += duration;
            normalDurationCount += 1;
          }
        } else if (prevPose == 'FORWARD') {
          if (value != 'FORWARD') {
            poseDurationList.add(PoseDuration(xOffset: xOffset,
              widthRate: duration / wholeDuration,
              durationType: DurationType.abnormal,
              startTime: '${(time.hour).toString().padLeft(2, '0')}:${(time.minute).toString().padLeft(2, '0')}',
              durationSec: duration
            ));
            if (_chosonDurationIdx == -1) {
              setState(() {
                _chosonDurationIdx = idx;
              });
            }
          }
        }
      }

      // if (prevPose != value) {
      prevPose = value;
      prevTime = time;
      idx += 1;
      // }
    });

    setState(() {
      _poseDurationList = poseDurationList;
      _normalDurationCount = normalDurationCount;
      _normalDurationSum = normalDurationSum;
    });
  }

  void chooseDuration(int idx) {
    setState(() {
      _chosonDurationIdx = idx;
    });
  }

  @override
  void dispose() {
    _internetCheckListener.cancel();
    _scrollViewController.dispose();
    _scrollViewController.removeListener(() {});
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    HistoryStatus historyStatus = context.watch();
    // if (historyStatus)
    // initScoreMap(historyStatus.scoreSeries);
    return SafeArea(
        child: Scaffold(
          appBar:  const PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: HomeAppBar()
          ),
          body: SizedBox(
            width: res.deviceWidth,
            // decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  margin: EdgeInsets.only(left: res.percentWidth(7.5), top: res.percentHeight(4), bottom: res.percentHeight(2)),
                  height: _showScorePart ? res.percentHeight(12.5) : 0,
                  duration: const Duration(milliseconds: 250),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextDefault(
                                  content: '오늘 자세점수는 ',
                                  fontSize: 30,
                                  isBold: true,
                                  fontColor: Colors.black,
                                ),
                                TextDefault(
                                  content: '${_todayHistory['point'] ?? 0}점이예요',
                                  fontSize: 30,
                                  isBold: true,
                                  fontColor: const Color(0xFF236EF3),
                                ),
                                SizedBox(height: res.percentHeight(2),),
                                ScoreBar(score: _todayHistory['point'] ?? 0)
                              ],
                            ),
                            Positioned(
                                left: res.percentWidth(79),
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        useSafeArea: false,
                                        builder: (context) {
                                          return const ScoreExplain();
                                        });
                                  },
                                  child: AssetIcon('help', color: const Color(0xFF8991A0), size: res.percentWidth(1.25),),
                                )
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: res.deviceWidth,
                  margin: EdgeInsets.only(left: res.percentWidth(7.5)),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE5E5EB)))
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _anchorIdx = 0;
                            _showScorePart = false;
                          });
                          Scrollable.ensureVisible(
                              todayKey.currentContext!,
                              duration: const Duration(seconds: 1)
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: res.percentHeight(1), bottom: res.percentHeight(1) - (_anchorIdx == 0 ? 3 : 0)),
                          decoration: _anchorIdx == 0 ? const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF101010), width: 3))
                          ) : null,
                          child: TextDefault(
                              content: '오늘',
                              fontSize: 16,
                              isBold: _anchorIdx == 0
                          ),
                        ),
                      ),
                      SizedBox(width: res.percentWidth(5),),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _anchorIdx = 1;
                            _showScorePart = false;
                          });
                          Scrollable.ensureVisible(
                            timelineKey.currentContext!,
                            duration: const Duration(seconds: 1)
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: res.percentHeight(1), bottom: res.percentHeight(1) - (_anchorIdx == 1 ? 3 : 0)),
                          decoration: _anchorIdx == 1 ? const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFF101010), width: 3))
                          ) : null,
                          child: TextDefault(
                              content: '타임라인',
                              fontSize: 16,
                              isBold: _anchorIdx == 1
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _scrollViewController,
                    child: Container(
                      key: todayKey,
                      margin: EdgeInsets.only(left: res.percentWidth(7.5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: res.percentHeight(3.5),),
                          const TextDefault(
                            content: '오늘',
                            fontSize: 22,
                            isBold: true,
                            fontColor: Color(0xFF323238),
                          ),
                          SizedBox(height: res.percentHeight(2),),
                          WhiteContainer(
                            width: res.percentWidth(85),
                            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2)),
                            margin: EdgeInsets.only(right: res.percentWidth(7.5)),
                            radius: 20,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (
                                        context) => TodayHistory(fullHistoryData: _historyData, date2idx: _data2idx,)));
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const TextDefault(
                                          content: '자세 탐지',
                                          fontSize: 16,
                                          isBold: true
                                      ),
                                      AssetIcon('arrowNext', size: res.percentWidth(1), color: const Color(0xFF9696A2),)
                                    ],
                                  ),
                                ),
                                SizedBox(height: res.percentHeight(2),),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    PoseCountFrame(poseType: PoseType.turtle, count: _todayHistory['poseCountMap']['FORWARD'] ?? 0,),
                                    PoseCountFrame(poseType: PoseType.slouch, count: _todayHistory['poseCountMap']['tilt'] ?? 0,),
                                    PoseCountFrame(poseType: PoseType.back, count: _todayHistory['poseCountMap']['BACKWARD'] ?? 0,)
                                  ],
                                )
                              ],
                            )
                          ),
                          SizedBox(height: res.percentHeight(2),),
                          WhiteContainer(
                            width: res.percentWidth(85),
                            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(4), vertical: res.percentHeight(2)),
                            margin: EdgeInsets.only(right: res.percentWidth(7.5)),
                            radius: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextDefault(
                                  content: '평균 ${TimeConvert.sec2Min(_normalDurationCount > 0 ? _normalDurationSum~/_normalDurationCount : 0)}마다 자세가 무너져요',
                                  fontSize: 16,
                                  isBold: true
                                ),
                                SizedBox(height: res.percentHeight(2),),
                                PoseTimeMap(poseDurationList: _poseDurationList, notifyTap: chooseDuration),

                                _chosonDurationIdx != -1 ? Stack(
                                  children: [
                                    Positioned(
                                      left: res.percentWidth(74)*_poseDurationList[_chosonDurationIdx].xOffset - res.percentWidth(74)*_poseDurationList[_chosonDurationIdx].widthRate/2 - res.percentWidth(2),
                                      child: CustomPaint(
                                        painter: TrianglePainter(
                                          strokeColor: const Color(0x4DD8E2F9),
                                          strokeWidth: 2,
                                          paintingStyle: PaintingStyle.fill,
                                        ),
                                        child: SizedBox(
                                          height: res.percentWidth(3.5),
                                          width: res.percentWidth(5),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: res.percentWidth(77),
                                      margin: EdgeInsets.only(top: res.percentWidth(3.5)),
                                      decoration: BoxDecoration(
                                        color: const Color(0x4DD8E2F9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const TextDefault(
                                              content: '거북목 자세 탐지',
                                              fontSize: 16,
                                              isBold: false
                                          ),
                                          Row(
                                            children: [
                                              TextDefault(
                                                content: _poseDurationList[_chosonDurationIdx].startTime,
                                                fontSize: 16,
                                                isBold: false,
                                                fontColor: const Color(0xFF236EF3),
                                              ),
                                              AssetIcon('bullet', size: res.percentWidth(1), color: const Color(0xFF9696A2),),
                                              TextDefault(
                                                content: TimeConvert.sec2Min(_poseDurationList[_chosonDurationIdx].durationSec!),
                                                fontSize: 16,
                                                isBold: false,
                                                fontColor: const Color(0xFF236EF3),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ) : const SizedBox()
                              ],
                            ),
                          ),
                          SizedBox(height: res.percentHeight(3.5),),
                          SizedBox(
                            key: timelineKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // const TextDefault(
                                //   content: '이번주',
                                //   fontSize: 22,
                                //   isBold: true,
                                //   fontColor: Color(0xFF323238),
                                // ),
                                DurationDropdown(
                                  onChanged: (value) {
                                    setState(() {
                                      _scoreDurationValue = value;
                                    });
                                  },
                                  chosenValue: _scoreDurationValue,
                                ),
                                SizedBox(height: res.percentHeight(2),),
                                WhiteContainer(
                                  padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2)),
                                  margin: EdgeInsets.only(right: res.percentWidth(7.5)),
                                  radius: 20,
                                  child: ScoreChart(scoreValues: historyStatus.scoreSeries['historyPointMap'], duration: _scoreDurationValue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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