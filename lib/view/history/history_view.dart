import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocksum_flutter/goal_setting.dart';
import 'package:mocksum_flutter/page_navbar.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/service/goal_provider.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/view/history/widgets/duration_dropdown.dart';
import 'package:mocksum_flutter/view/history/widgets/score_explain.dart';
import 'package:mocksum_flutter/view/history/widgets/update_explain.dart';
import 'package:mocksum_flutter/view/home/home_view.dart';
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
import '../../util/localization_string.dart';
import '../goal/subpage/goal_setting.dart';
import '../goal/subpage/widget/goal_list_item.dart';
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
  late ScrollController _durationListController;
  bool _showScorePart = true;
  bool isScrollingDown = false;

  List<PoseDuration> _poseDurationList = [];
  int _normalDurationSum = 0;
  int _normalDurationCount = 0;
  int _chosonDurationIdx = -1;

  int _anchorIdx = 0;
  String _scoreDurationValue = 'WEEK';
  int durationListScrollOffsetCoef = 0;

  Map<String, dynamic> _historyData = {'daily' : [], 'poseTimerMap': {}};
  Map<String, dynamic> _todayHistory = {'poseCountMap': {}, 'daily' : []};
  Map<String, int> _data2idx = {};

  Map<String, dynamic> _scoreSeries = {'historyPointMap': {}};

  final dummy = {'2024-09-26T19:03:06': 'START', '2024-09-26T19:03:20': 'FORWARD', '2024-09-26T19:03:27': 'NORMAL', '2024-09-26T19:03:36': 'FORWARD', '2024-09-26T19:03:50': 'NORMAL', '2024-09-26T19:04': 'FORWARD', '2024-09-26T19:04:03': 'NORMAL', '2024-09-26T19:04:06': 'FORWARD', '2024-09-26T19:04:15': 'NORMAL', '2024-09-26T19:04:47': 'END'};

//  '2024-09-26T19:06:18': 'START', '2024-09-26T19:06:28': 'FORWARD', '2024-09-26T19:06:31': 'NORMAL', '2024-09-26T19:06:32': 'FORWARD', '2024-09-26T19:06:35': 'NORMAL', '2024-09-26T19:06:42': 'FORWARD', '2024-09-26T19:06:45': 'NORMAL', '2024-09-26T19:07:11': 'END'
  @override
  void initState() {
    super.initState();
    print('his view init');
    // if (UserStatus.sIsLogged) {
    getHistoryData(DateTime
        .now()
        .year, DateTime
        .now()
        .month);
    getScoreSeriesV2('MONTH6');
    // }

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

    _durationListController = ScrollController();

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

    // Future.delayed(Duration.zero, () {
    //   timestamp2Duration(context.read<HistoryStatus>().todayHistory['history']);
    // });
  }

  Future<void> getHistoryData(int year, int month) async {
    const storage = FlutterSecureStorage();
    // print('gethis');
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        HistoryStatus.dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response res = await HistoryStatus.dio.get(
          '${HistoryStatus.serverAddressV3}/history/monthly?year=$year&month=$month');
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

        print("todayhistory : ${_todayHistory}");

        timestamp2DurationList(_todayHistory['pitch'] ?? dummy);
        storage.write(
            key: 'posePitchLocal', value: json.encode(_historyData));

      }
    } on DioException catch(e) {
      String? historyDataStr = await storage.read(key: 'posePitchLocal');
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
      // print(e);
      setState(() {
        _historyData = {'poseCountMap': {}, 'daily' : []};
      });
    }
  }

  Future<void> getScoreSeriesV2(String duration) async {
    // print('getsore');
    const storage = FlutterSecureStorage();
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        HistoryStatus.dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response res = await HistoryStatus.dio.get(
          '${HistoryStatus.serverAddress}/history/point?type=$duration');

      if (res.data['code'] == 'success') {
        setState(() {
          _scoreSeries = Map.from(res.data['data']);
        });
        // print(_scoreSeries);
        // _scoreSeries['success'] = true;
        // print('scores $_scoreSeries');
        // storage.write(key: 'scoreserieslocal', value: json.encode(_scoreSeries));
        // if (_dateDataUpdated) {
        //   _shouldChangeData = false;
        // }

        // return _scoreSeries;
      } else {
        throw Exception();
      }

    } on Exception catch (e) {
      print(e);
    }
  }

  void timestamp2DurationList(Map<String, dynamic>? historyMap) {
    // print('dummy2 $historyMap');
    if (historyMap == null) return;

    List<PoseDuration> poseDurationList = [];

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
        xOffset += duration;

        if (prevPose == 'START') {
          poseDurationList.add(PoseDuration(xOffset: xOffset,
            width: duration,
            durationType: DurationType.normal,
            startTime: '${(time.hour).toString().padLeft(2, '0')}:${(time.minute).toString().padLeft(2, '0')}:${(time.second).toString().padLeft(2, '0')}'
          ));

          normalDurationSum += duration;
          normalDurationCount += 1;
        } else if (prevPose == 'END') {
          poseDurationList.add(PoseDuration(xOffset: xOffset,
            width: duration,
            durationType: DurationType.none,
            startTime: '${(time.hour).toString().padLeft(2, '0')}:${(time.minute).toString().padLeft(2, '0')}:${(time.second).toString().padLeft(2, '0')}'
          ));
        } else if (prevPose == 'DOWNNORMAL') {
          if (value != 'DOWNNORMAL') {
            poseDurationList.add(PoseDuration(xOffset: xOffset,
              width: duration,
              durationType: DurationType.normal,
              startTime: '${(time.hour).toString().padLeft(2, '0')}:${(time.minute).toString().padLeft(2, '0')}:${(time.second).toString().padLeft(2, '0')}'
            ));
            normalDurationSum += duration;
            normalDurationCount += 1;
          }
        } else if (prevPose == 'DOWN') {
          // if (value != 'FORWARD') {
            poseDurationList.add(PoseDuration(xOffset: xOffset,
              width: duration,
              durationType: DurationType.abnormal,
              startTime: '${(time.hour).toString().padLeft(2, '0')}:${(time.minute).toString().padLeft(2, '0')}:${(time.second).toString().padLeft(2, '0')}',
              durationSec: duration
            ));
            if (_chosonDurationIdx == -1) {
              setState(() {
                _chosonDurationIdx = idx;
              });
            }
          // }
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
    // print('pdl $_poseDurationList');
  }

  void chooseDuration(int idx) {
    setState(() {
      _chosonDurationIdx = idx;
    });
  }

  String nowGraphDuration() {
    DateTime end = DateTime.now();
    DateTime start = DateTime.now();
    switch (_scoreDurationValue) {
      case 'WEEK':
        start = start.subtract(const Duration(days: 6));
        break;
      case 'MONTH1':
        start = start.subtract(const Duration(days: 29));
        break;
      case 'MONTH3':
        start = start.subtract(const Duration(days: 89));
        break;
      case 'MONTH6':
        start = start.subtract(const Duration(days: 179));
        break;
    }

    return '${start.month}.${start.day} ~ ${end.month}.${end.day}';
  }

  bool isDurationListScrollEnd() {
    Responsive res = Responsive(context);

    if (_durationListController.hasClients) {
      return durationListScrollOffsetCoef * res.percentWidth(76) >=
          _durationListController.position.maxScrollExtent;
    }
    return false;
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
    GoalProvider goalState = context.watch();
    DetectStatus detectStatus = context.watch();
    GlobalTimer globalTimer = context.watch();
    // HistoryStatus historyStatus = context.watch();
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
              detectStatus.nowDetecting ? GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      useSafeArea: false,
                      builder: (context) {
                        return const UpdateExplain();
                      });
                },
                child: Padding(
                  padding: EdgeInsets.only(top: res.percentHeight(2)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: res.percentWidth(7.5)),
                        width: res.percentWidth(3),
                        height: res.percentWidth(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF236EF3), //globalTimer.useSec % 2 == 1 ? const Color(0xFF236EF3) : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      SizedBox(width: res.percentWidth(2),),
                      TextDefault(content: 'history_view.measuring'.tr(), fontSize: 16, isBold: true, fontColor: const Color(0xFF236EF3),)
                    ],
                  ),
                ),
              ): SizedBox(height: res.percentHeight(1),),
                AnimatedContainer(
                  margin: EdgeInsets.only(left: res.percentWidth(7.5), top: res.percentHeight(1) , bottom: res.percentHeight(2)),
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
                                TextDefault(
                                  content: 'history_view.today_posture_point'.tr(),
                                  fontSize: 30,
                                  isBold: true,
                                  fontColor: Colors.black,
                                ),
                                TextDefault(
                                  content: _todayHistory['point'] == null ? 'history_view.today_posture_point2'.tr()
                                      : 'history_view.today_posture_point3'.tr(args:[_todayHistory['point'].toString()]),
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
                              content: 'history_view.today'.tr(),
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
                              content: 'history_view.timeLine'.tr(),
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
                          TextDefault(
                            content: 'history_view.today'.tr(),
                            fontSize: 22,
                            isBold: true,
                            fontColor: const Color(0xFF323238),
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
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextDefault(
                                          // 자세 탐지
                                            content: 'history_view.posture_detection'.tr(),
                                            fontSize: 16,
                                            isBold: true
                                        ),
                                        AssetIcon('arrowNext', size: res.percentWidth(1), color: const Color(0xFF9696A2),)
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: res.percentHeight(2),),
                                Stack(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        PoseCountFrame(poseType: PoseType.turtle, count: _todayHistory['poseCountMap']['DOWN'] ?? 0,),
                                        PoseCountFrame(poseType: PoseType.slouch, count: _todayHistory['poseCountMap']['FORWARD'] ?? 0,),
                                        PoseCountFrame(poseType: PoseType.back, count: _todayHistory['poseCountMap']['TILT'] ?? 0,)
                                      ],
                                    ),
                                    Positioned(
                                      left: res.percentWidth(25),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                          child: Container(
                                            width: res.percentWidth(75),
                                            height: res.percentHeight(30),
                                            color: Colors.black.withOpacity(0),
                                            alignment: Alignment.center,
                                          ),
                                        ),
                                      )
                                    ),
                                    Positioned(
                                      left: context.locale.languageCode == 'ko' ? res.percentWidth(34) : res.percentWidth(30),
                                      top: res.percentHeight(6),
                                      child: Column(
                                        children: [
                                          TextDefault(content: 'history_view.tbd_content1'.tr(), fontSize: 14, isBold: true),
                                          TextDefault(content: 'history_view.tbd_content2'.tr(), fontSize: 14, isBold: true),
                                        ],
                                      )
                                    ),
                                  ],
                                )
                              ],
                            )
                          ),
                          SizedBox(height: res.percentHeight(2),),
                          WhiteContainer(
                            width: res.percentWidth(85),
                            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(2), vertical: res.percentHeight(2)),
                            margin: EdgeInsets.only(right: res.percentWidth(7.5)),
                            radius: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: res.percentWidth(2)),
                                  child: TextDefault(
                                      content: _todayHistory['pitch'] != null ?
                                          'history_view.average_posture_lose_time'.tr(args:[TimeConvert.sec2Min(_normalDurationCount > 0 ? _normalDurationSum~/_normalDurationCount : 0, context.locale.languageCode)])
                                        // '평균 ${TimeConvert.sec2Min(_normalDurationCount > 0 ? _normalDurationSum~/_normalDurationCount : 0)}마다 자세가 무너져요'
                                        // : '자세 탐지를 하면 1초단위로\n내 자세를 알 수 있어요',
                                      : LS.tr('history_view.today_history_scoring_default'),
                                      fontSize: 16,
                                      isBold: true
                                  ),
                                ),
                                SizedBox(height: res.percentHeight(2),),
                                _todayHistory['pitch'] == null ? Container(
                                  margin: EdgeInsets.only(bottom: res.percentHeight(1), left: res.percentWidth(2)),
                                  padding: EdgeInsets.symmetric(horizontal: res.percentWidth(2), vertical: res.percentHeight(0.5)),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      width: 1,
                                      color: const Color(0xFF8991A0)
                                    )
                                  ),
                                  child: TextDefault(content: 'history_view.example'.tr(), fontSize: 13, isBold: false, fontColor: Color(0xFF8991A0),),
                                ) : const SizedBox(),
                                Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: res.percentWidth(2)),
                                      child: SingleChildScrollView(
                                        physics: const NeverScrollableScrollPhysics(),
                                        controller: _durationListController,
                                        scrollDirection: Axis.horizontal,
                                        child: PoseTimeMap(poseDurationList: _poseDurationList, notifyTap: chooseDuration),
                                      ),
                                    ),
                                    durationListScrollOffsetCoef > 0 ? Positioned(
                                      // left: -res.percentWidth(2.5),
                                      top: res.percentHeight(2.75),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (durationListScrollOffsetCoef > 0) {
                                              durationListScrollOffsetCoef -= 1;
                                            }
                                            _durationListController.animateTo(durationListScrollOffsetCoef*res.percentWidth(76),
                                                duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
                                          });
                                        },
                                        child: Container(
                                          width: res.percentWidth(5),
                                          height: res.percentWidth(5),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(res.percentWidth(5)),
                                              boxShadow: const [BoxShadow(
                                                color: Color(0x19000000),
                                                blurRadius: 4,
                                                offset: Offset(2, 2),
                                                spreadRadius: 3,
                                              )]
                                          ),
                                          child: const AssetIcon('arrowBack', size: 4, color: Color(0xFF64646F),),
                                        ),
                                      ),
                                    ) : const SizedBox(),
                                    !isDurationListScrollEnd() ? Positioned(
                                      left: res.percentWidth(75),
                                      top: res.percentHeight(2.75),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            durationListScrollOffsetCoef += 1;
                                            _durationListController.animateTo(min(durationListScrollOffsetCoef*res.percentWidth(76), _durationListController.position.maxScrollExtent),
                                                duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
                                          });
                                        },
                                        child: Container(
                                          width: res.percentWidth(5),
                                          height: res.percentWidth(5),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(res.percentWidth(5)),
                                              boxShadow: const [BoxShadow(
                                                color: Color(0x19000000),
                                                blurRadius: 4,
                                                offset: Offset(2, 2),
                                                spreadRadius: 3,
                                              )]
                                          ),
                                          child: const AssetIcon('arrowNext', size: 4, color: Color(0xFF64646F),),
                                        ),
                                      ),
                                    ) : const SizedBox()
                                  ],
                                ),

                                _chosonDurationIdx != -1 ? Stack(
                                  children: [
                                    // Positioned(
                                    //   // left: res.percentWidth(74)*_poseDurationList[_chosonDurationIdx].xOffset - res.percentWidth(74)*_poseDurationList[_chosonDurationIdx].width/2 - res.percentWidth(2),
                                    //   child: CustomPaint(
                                    //     painter: TrianglePainter(
                                    //       strokeColor: const Color(0x4DD8E2F9),
                                    //       strokeWidth: 2,
                                    //       paintingStyle: PaintingStyle.fill,
                                    //     ),
                                    //     child: SizedBox(
                                    //       height: res.percentWidth(3.5),
                                    //       width: res.percentWidth(5),
                                    //     ),
                                    //   ),
                                    // ),
                                    Container(
                                      width: res.percentWidth(77),
                                      margin: EdgeInsets.only(top: res.percentWidth(3.5), left: res.percentWidth(2)),
                                      decoration: BoxDecoration(
                                        color: const Color(0x4DD8E2F9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextDefault(
                                            // 거북목 자세 탐지
                                              content: 'history_view.forward_neck_detection'.tr(),
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
                                                content: TimeConvert.sec2Min(_poseDurationList[_chosonDurationIdx].durationSec!, context.locale.languageCode),
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
                          SizedBox(height: res.percentHeight(2),),
                          WhiteContainer(
                            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2)),
                            margin: EdgeInsets.only(right: res.percentWidth(7.5)),
                            radius: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (
                                        context) => const PageNavBar(pageIdx: 1,))
                                    );
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextDefault(content: 'history_view.goal'.tr(), fontSize: 16, isBold: true),
                                        AssetIcon('arrowNext', size: res.percentWidth(1), color: const Color(0xFF9696A2),)
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: res.percentHeight(2),),
                                GoalListItem(
                                  goalType: GoalType.score,
                                  targetValue: goalState.goalMap['score']['targetValue'] != null ? goalState.goalMap['score']['targetValue'].toDouble() : 85,
                                  isSet: goalState.goalMap['score']['targetValue'] != null,
                                  achieveRate: goalState.goalMap['score']['achieved_rate'] ?? 0,
                                  fontSize: 14,
                                  padding: EdgeInsets.symmetric(horizontal: res.percentWidth(4), vertical: res.percentHeight(2)),
                                  isInHistory: true,
                                ),
                                SizedBox(height: res.percentHeight(1),),
                                GoalListItem(
                                  goalType: GoalType.time,
                                  targetValue: goalState.goalMap['time']['targetValue'] != null ? goalState.goalMap['time']['targetValue'].toDouble() : 15,
                                  isSet: goalState.goalMap['time']['targetValue'] != null,
                                  achieveRate: goalState.goalMap['time']['achieved_rate'] ?? 0,
                                  fontSize: 14,
                                  padding: EdgeInsets.symmetric(horizontal: res.percentWidth(4), vertical: res.percentHeight(2)),
                                  isInHistory: true,
                                ),
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
                                SizedBox(height: res.percentHeight(1),),
                                WhiteContainer(
                                  padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2)),
                                  margin: EdgeInsets.only(right: res.percentWidth(7.5)),
                                  radius: 20,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          TextDefault(content: LS.tr('history_view.posture_score_difference'), fontSize: 16, isBold: true),
                                          TextDefault(content: nowGraphDuration(), fontSize: 14, isBold: true, fontColor: const Color(0xFF8991A0),),
                                        ],
                                      ),
                                      ScoreChart(scoreValues: _scoreSeries['historyPointMap'], duration: _scoreDurationValue)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30,)
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