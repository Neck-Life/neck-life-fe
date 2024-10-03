import 'package:flutter/material.dart';
import 'package:mocksum_flutter/page_navbar.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/person_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/amplitude.dart';
import 'package:mocksum_flutter/service/history_provider.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/util/time_convert.dart';
import 'package:mocksum_flutter/view/history/widgets/pose_count_frame.dart';
import 'package:mocksum_flutter/view/home/home_view.dart';
import 'package:mocksum_flutter/view/today_history/widgets/date_tile.dart';
import 'package:mocksum_flutter/view/today_history/widgets/pose_list_item.dart';
import 'package:provider/provider.dart';

import '../../theme/component/button.dart';


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
  late int _month;
  late int _date;
  int _chosenDate = 0;
  final AmplitudeEventManager _amplitudeEventManager = AmplitudeEventManager();
  final ScrollController _scrollController = ScrollController();
  int _fullTimeSec = 0;
  int _normalTimeSec = 0;
  Map<String, dynamic> _filteredPoseMap = {};
  Map<dynamic, dynamic> _historyDateKeyMap = {};

  @override
  void initState() {
    setState(() {
      _month = now.month;
      _date = now.day;
      _chosenDate = now.day-1;
    });
    _amplitudeEventManager.viewEvent('todayhistory');

    // _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    // Map<String, dynamic> historyData = Provider.of<HistoryStatus>(context, listen: false).getPastHistoryWithDateV2(_chosenDate+1);
    // print('widget $historyData');
    String todayStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    Map histodyDateKeyMap = {};

    widget.fullHistoryData['daily'].forEach((item) {
      histodyDateKeyMap[item['date']] = item;
    });
    final historyData = histodyDateKeyMap.containsKey(_chosenDate+1) ? histodyDateKeyMap[_chosenDate+1] : {'poseTimerMap': {}, 'daily': []};
    // print('th $historyData');
    setState(() {
      _normalTimeSec = historyData['poseTimerMap']['NORMAL'] == null ? 0 : historyData['poseTimerMap']['NORMAL'].toInt();
      _fullTimeSec = historyData['measurementTime'] == null ? 0 : historyData['measurementTime'].toInt();
      _historyDateKeyMap = histodyDateKeyMap;
    });
    _filterPoseMap(historyData['history']);

    super.initState();
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
    final historyData = _historyDateKeyMap.containsKey(chosenDate+1) ? _historyDateKeyMap[chosenDate+1] : {'poseTimerMap': {}, 'daily': []};
    setState(() {
      _normalTimeSec = historyData['poseTimerMap']['NORMAL'] == null ? 0 : historyData['poseTimerMap']['NORMAL'].toInt();
      _fullTimeSec = historyData['measurementTime'] == null ? 0 : historyData['measurementTime'].toInt();
      _chosenDate = chosenDate;
    });
    _filterPoseMap(historyData['history']);
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    // HistoryStatus historyStatus = context.watch();
    // String todayStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${(DateTime.now().day).toString().padLeft(2, '0')}';
    // final historyData = widget.fullHistoryData.containsKey(todayStr) ? widget.fullHistoryData[todayStr] : {'posTimerMap': {}, 'daily': []};
    // _filterPoseMap(historyData['history']);

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
                        children: List.generate(_date, (idx) {
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
                        })
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
                        content: '${_chosenDate+1 == DateTime.now().day ? '오늘' : '이 날의'} 기록이 없어요',
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