import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/page_navbar.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/person_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/service/history_provider.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/util/time_convert.dart';
import 'package:mocksum_flutter/view/history/widgets/pose_count_frame.dart';
import 'package:mocksum_flutter/view/today_history/widgets/date_tile.dart';
import 'package:mocksum_flutter/view/today_history/widgets/pose_list_item.dart';

import '../../theme/component/button.dart';
import '../../theme/popup.dart';


class TodayHistory extends StatefulWidget {
  final Map<String, dynamic> fullHistoryData;
  final Map<String, int> date2idx;

  const TodayHistory({
    super.key,
    required this.fullHistoryData,
    required this.date2idx
  });

  @override
  State<StatefulWidget> createState() => _TodayHistoryState();
}

class _TodayHistoryState extends State<TodayHistory> {

  DateTime now = DateTime.now();
  late int _year;
  late int _month;
  late int _date;
  int _chosenDate = 0;
  final AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();
  final ScrollController _scrollController = ScrollController();
  int _fullTimeSec = 0;
  int _normalTimeSec = 0;
  Map<String, dynamic> _filteredPoseMap = {};
  Map<dynamic, dynamic> _historyDateKeyMap = {}; // {month : {date:{}, date:{}}}

  @override
  void initState() {
    setState(() {
      _year = now.year;
      _month = now.month;
      _date = now.day;
      _chosenDate = now.day-1;
    });
    _amplitudeEventManager.viewEvent('todayhistory');

    // Map<String, dynamic> historyData = Provider.of<HistoryStatus>(context, listen: false).getPastHistoryWithDateV2(_chosenDate+1);
    // print('widget $historyData');
    Map histodyDateKeyMap = {};
    Map monthDataMap = {};
    widget.fullHistoryData['daily'].forEach((item) {
      monthDataMap[item['date']] = item;
    });
    final historyData = monthDataMap.containsKey(_chosenDate+1) ? monthDataMap[_chosenDate+1] : {'poseTimerMap': {}, 'daily': []};
    // print('th $historyData');
    histodyDateKeyMap[_month] = monthDataMap;
    setState(() {
      _normalTimeSec = historyData['poseTimerMap']['NORMAL'] == null ? 0 : historyData['poseTimerMap']['NORMAL'].toInt();
      _fullTimeSec = historyData['measurementTime'] == null ? 0 : historyData['measurementTime'].toInt();
      _historyDateKeyMap = histodyDateKeyMap;
    });
    _filterPoseMap(historyData['history']);

    Future.delayed(Duration.zero, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      }
    });
    super.initState();
  }

  Future<void> getPrevMonthData() async {
    const storage = FlutterSecureStorage();
    int newYear = _month > 1 ? _year : _year-1;
    int newMonth = _month > 1 ? _month-1 : 12;
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        HistoryStatus.dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response res = await HistoryStatus.dio.get(
          '${HistoryStatus.serverAddress}/history/monthly?year=$newYear&month=$newMonth');

      if (res.data['code'] == 'success') {
        // print('ok');
        // print(res.data);
        final fullHistoryData = res.data['data'];
        Map monthDataMap = {};
        fullHistoryData['daily'].forEach((item) {
          monthDataMap[item['date']] = item;
        });
        final historyData = monthDataMap.containsKey(_chosenDate+1) ? monthDataMap[_chosenDate+1] : {'poseTimerMap': {}, 'daily': []};
        // print('th $historyData');
        setState(() {
          _normalTimeSec = historyData['poseTimerMap']['NORMAL'] == null ? 0 : historyData['poseTimerMap']['NORMAL'].toInt();
          _fullTimeSec = historyData['measurementTime'] == null ? 0 : historyData['measurementTime'].toInt();
          _historyDateKeyMap[newMonth] = monthDataMap;
          _date = DateTime(_year, _month, 1).subtract(const Duration(days: 1)).day;
          _month = newMonth;
          _year = newYear;
          _chosenDate = _date-1;
        });
        _filterPoseMap(historyData['history']);
        _scrollController.animateTo(MediaQuery.of(context).size.width*0.16*(_date+2),
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      } else {
        throw Exception();
      }
    } on Exception catch (e) {
      print(e);
      _openErrorPopUp();
    }
  }

  void getNextMonthData() async {
    int newYear = _month > 11 ? _year+1 : _year;
    int newMonth = _month > 11 ? 1 : _month+1;
    // if (newMonth > DateTime.now().month) return;

    // print('newMonth $newMonth');
    // print(_historyDateKeyMap);
    final historyData = _historyDateKeyMap[newMonth].containsKey(_chosenDate+1) ? _historyDateKeyMap[newMonth][_chosenDate+1] : {'poseTimerMap': {}, 'daily': []};
    try {
        setState(() {
          _normalTimeSec = historyData['poseTimerMap']['NORMAL'] == null ? 0 : historyData['poseTimerMap']['NORMAL'].toInt();
          _fullTimeSec = historyData['measurementTime'] == null ? 0 : historyData['measurementTime'].toInt();
          _date = newMonth == DateTime.now().month ? DateTime.now().day : DateTime(newMonth > 11 ? _year+1 : _year, newMonth > 11 ? 1 : newMonth+1, 1).subtract(const Duration(days: 1)).day;
          _month = newMonth;
          _year = newYear;
          _chosenDate = 0;
        });
        _filterPoseMap(historyData['history']);

    } on Exception catch (e) {
      print(e);
      _openErrorPopUp();
    }
  }

  void _filterPoseMap(Map<String, dynamic>? historyMap) {
    if (historyMap == null) {
      setState(() {
        _filteredPoseMap = {};
      });
      return;
    }

    Map<String, dynamic> filteredPoseMap = {};
    historyMap.forEach((key, val) {
      if (val != 'NORMAL' && val != 'START' && val != 'END') {
        filteredPoseMap[key] = val;
      }
    });
    setState(() {
      _filteredPoseMap = filteredPoseMap;
    });
  }

  void changeChosenDate(int chosenDate) {
    final historyData = _historyDateKeyMap[_month].containsKey(chosenDate+1) ? _historyDateKeyMap[_month][chosenDate+1] : {'poseTimerMap': {}, 'daily': []};
    setState(() {
      _normalTimeSec = historyData['poseTimerMap']['NORMAL'] == null ? 0 : historyData['poseTimerMap']['NORMAL'].toInt();
      _fullTimeSec = historyData['measurementTime'] == null ? 0 : historyData['measurementTime'].toInt();
      _chosenDate = chosenDate;
    });
    _filterPoseMap(historyData['history']);
  }

  void _openErrorPopUp() {
    showDialog(context: context, builder: (ctx) {
      return const CustomPopUp(text: '오류가 발생했습니다.\n다시 시도해주세요.');
    });
  }


  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFFF4F4F7),
          title: const TextDefault(
            content: '자세 탐지',
            fontSize: 16,
            isBold: false,
            fontColor: Color(0xFF64646F),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const AssetIcon('arrowBack', color: Color(0xFF8991A0), size: 6,)
          )
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: res.deviceWidth,
            decoration: const BoxDecoration(
              color:  Color(0xFFF4F4F7)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: res.percentHeight(2),),
                Container(
                  margin: EdgeInsets.only(left: res.percentWidth(7.5)),
                  child: TextDefault(
                      content: '$_month월 ${_chosenDate+1}일',
                      fontSize: 20,
                      isBold: true
                  ),
                ),
                SizedBox(height: res.percentHeight(2),),
                SizedBox(
                  width: res.percentWidth(92.5),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              await getPrevMonthData();
                            },
                            child: Container(
                              width: res.percentWidth(12.5),
                              height: res.percentWidth(15),
                              margin: EdgeInsets.only(left: res.percentWidth(2)),
                              alignment: Alignment.center,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AssetIcon('arrowBack', size: 5, color: Color(0xFF8991A0),),
                                  SizedBox(height: 5,),
                                  TextDefault(
                                      content: '이전',
                                      fontSize: 14,
                                      isBold: true,
                                      fontColor: Color(0xFF8991A0)
                                  )
                                ],
                              ),
                            ),
                          )
                        ] + List.generate(_date, (idx) {
                          return GestureDetector(
                            onTap: () {
                              changeChosenDate(idx);
                            },
                            child: DateTile(
                              date: idx+1,
                              month: _month,
                              hasChosen: _chosenDate == idx,
                            ),
                          );
                        }) + <Widget>[
                          _month < DateTime.now().month ? GestureDetector(
                            onTap: () {
                              getNextMonthData();
                            },
                            child: Container(
                              width: res.percentWidth(12.5),
                              height: res.percentWidth(15),
                              margin: EdgeInsets.only(left: res.percentWidth(2)),
                              alignment: Alignment.center,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AssetIcon('arrowNext', size: 5, color: Color(0xFF8991A0),),
                                  SizedBox(height: 5,),
                                  TextDefault(
                                      content: '다음',
                                      fontSize: 14,
                                      isBold: true,
                                      fontColor: Color(0xFF8991A0)
                                  )
                                ],
                              ),
                            ),
                          ) : const SizedBox()
                        ]
                    ),
                  ),
                ),
                SizedBox(height: res.percentHeight(4),)
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: res.deviceWidth,
                height: res.percentHeight(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F4F7)
                ),
              ),
              Container(
                width: res.deviceWidth,
                height: res.percentHeight(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)
                  )
                ),
              )
            ],
          ),
          Container(
            width: res.deviceWidth,
            padding: EdgeInsets.only(left: res.percentWidth(7.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextDefault(
                  content: '바른 자세 유지',
                  fontSize: 28,
                  isBold: true,
                ),
                Row(
                  children: [
                    TextDefault(
                      content: TimeConvert.sec2Min(_normalTimeSec),
                      fontSize: 28,
                      isBold: true,
                      fontColor: const Color(0xFF115FE9),
                    ),
                    TextDefault(
                      content: '/총 ${TimeConvert.sec2Min(_fullTimeSec)}',
                      fontSize: 18,
                      isBold: false,
                      fontColor: const Color(0xFF115FE9),
                    ),
                  ],
                ),
                SizedBox(height: res.percentHeight(3),),
                _filteredPoseMap.isNotEmpty ? SizedBox(
                  height: res.percentHeight(45),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: _filteredPoseMap.length,
                    itemBuilder: (context, index) {
                      return PoseListItem(poseType: PoseType.turtle, time: _filteredPoseMap.keys.toList()[index].split('T')[1]);
                    }
                  ),
                ) : Container(
                  width: res.percentWidth(85),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: res.percentWidth(34),
                            height: res.percentWidth(34),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(res.percentWidth(17)),
                              color: const Color(0xFFD8E2F9)
                            ),
                          ),
                          Positioned(
                            left: res.percentWidth(2),
                            top: res.percentWidth(2),
                            child: const PersonIcon(size: 30,),
                          )
                        ],
                      ),
                      SizedBox(height: res.percentHeight(2),),
                      TextDefault(
                        content: '${_month == DateTime.now().month && _chosenDate+1 == DateTime.now().day ? '오늘' : '이 날의'} 기록이 없어요',
                        fontSize: 18,
                        isBold: true,
                        fontColor: const Color(0xFF323238),
                      ),
                      SizedBox(height: res.percentHeight(2),),
                      Button(
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (
                              context) => const PageNavBar()));
                        },
                        text: '자세 탐지하기',
                        backgroundColor: const Color(0xFF8991A0),
                        color: Colors.white,
                        width: res.percentWidth(45),
                        padding: res.percentWidth(5),
                      )
                    ],
                  ),
                ),
                // PoseListItem(poseType: PoseType.slouch, time: '17:34'),
                // PoseListItem(poseType: PoseType.slouch, time: '17:34'),
                // PoseListItem(poseType: PoseType.slouch, time: '17:34')
              ],
            ),
          )
        ],
      ),
    );
  }

}