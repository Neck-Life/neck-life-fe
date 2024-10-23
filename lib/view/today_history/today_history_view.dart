import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:mocksum_flutter/view/history/widgets/pose_dropdown.dart';
import 'package:mocksum_flutter/view/today_history/widgets/date_tile.dart';
import 'package:mocksum_flutter/view/today_history/widgets/pose_list_item.dart';

import '../../theme/component/button.dart';
import '../../theme/popup.dart';
import '../../util/localization_string.dart';


class TodayHistory extends StatefulWidget {
  final Map<String, dynamic> fullHistoryData;
  final Map<String, int> date2idx;
  final PoseType? chosenType;

  const TodayHistory({
    super.key,
    required this.fullHistoryData,
    required this.date2idx,
    this.chosenType
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
  PoseType _chosenType = PoseType.slouch;

  @override
  void initState() {
    setState(() {
      _year = now.year;
      _month = now.month;
      _date = now.day;
      _chosenDate = now.day-1;
      _chosenType = widget.chosenType ?? PoseType.slouch;
    });
    _amplitudeEventManager.viewEvent('todayhistory');

    // Map<String, dynamic> historyData = Provider.of<HistoryStatus>(context, listen: false).getPastHistoryWithDateV2(_chosenDate+1);
    // print('widget $historyData');
    Map historyDateKeyMap = {};
    Map monthDataMap = {};
    // print(widget.fullHistoryData);
    widget.fullHistoryData['daily'].forEach((item) {
      // print('?? $item');
      monthDataMap[item['date']] = item;
    });
    // print('asdf $monthDataMap');
    final historyData = monthDataMap.containsKey(_chosenDate+1) ? monthDataMap[_chosenDate+1] : {'poseTimerMap': {}, 'daily': []};
    // print('th $historyData');
    historyDateKeyMap[_month] = monthDataMap;
    print('fuck $historyData');
    print('${_chosenType.poseIdentifier}NORMAL');
    setState(() {
      _normalTimeSec = historyData['poseTimerMap']['${_chosenType.poseIdentifier}NORMAL'] == null ? 0 : historyData['poseTimerMap']['${_chosenType.poseIdentifier}NORMAL'].toInt();
      _fullTimeSec = historyData['measurementTime'] == null ? 0 : historyData['measurementTime'].toInt();
      _historyDateKeyMap = historyDateKeyMap;
    });
    _filterPoseMap(historyData);

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
          '${HistoryStatus.serverAddressV3}/history/monthly?year=$newYear&month=$newMonth');


      if (res.data['code'] == 'success') {
        // print('ok');
        final fullHistoryData = res.data['data'];
        Map monthDataMap = {};
        fullHistoryData['daily'].forEach((item) {
          monthDataMap[item['date']] = item;
        });
        final historyData = monthDataMap.containsKey(_chosenDate+1) ? monthDataMap[_chosenDate+1] : {'poseTimerMap': {}, 'daily': []};

        setState(() {
          _normalTimeSec = historyData['poseTimerMap']['${_chosenType.poseIdentifier}NORMAL'] == null ? 0 : historyData['poseTimerMap']['${_chosenType.poseIdentifier}NORMAL'].toInt();
          _fullTimeSec = historyData['measurementTime'] == null ? 0 : historyData['measurementTime'].toInt();
          _historyDateKeyMap[newMonth] = monthDataMap;
          _date = DateTime(_year, _month, 1).subtract(const Duration(days: 1)).day;
          _month = newMonth;
          _year = newYear;
          _chosenDate = _date-1;
        });
        _filterPoseMap(historyData);
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
          _normalTimeSec = historyData['poseTimerMap']['${_chosenType.poseIdentifier}NORMAL'] == null ? 0 : historyData['poseTimerMap']['${_chosenType.poseIdentifier}NORMAL'].toInt();
          _fullTimeSec = historyData['measurementTime'] == null ? 0 : historyData['measurementTime'].toInt();
          _date = newMonth == DateTime.now().month ? DateTime.now().day : DateTime(newMonth > 11 ? _year+1 : _year, newMonth > 11 ? 1 : newMonth+1, 1).subtract(const Duration(days: 1)).day;
          _month = newMonth;
          _year = newYear;
          _chosenDate = 0;
        });
        _filterPoseMap(historyData);

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
    if (historyMap[_chosenType.poseFilter] != null) {
      historyMap[_chosenType.poseFilter].forEach((key, val) {
        if (val == _chosenType.poseIdentifier) {
          filteredPoseMap[key] = val;
        }
      });
    }
    setState(() {
      _filteredPoseMap = filteredPoseMap;
    });
  }

  void changeChosenDate(int chosenDate) {
    final historyData = _historyDateKeyMap[_month].containsKey(chosenDate+1) ? _historyDateKeyMap[_month][chosenDate+1] : {'poseTimerMap': {}, 'daily': []};
    setState(() {
      _normalTimeSec = historyData['poseTimerMap']['${_chosenType.poseIdentifier}NORMAL'] == null ? 0 : historyData['poseTimerMap']['${_chosenType.poseIdentifier}NORMAL'].toInt();
      _fullTimeSec = historyData['measurementTime'] == null ? 0 : historyData['measurementTime'].toInt();
      _chosenDate = chosenDate;
    });
    _filterPoseMap(historyData);
  }

  void _openErrorPopUp() {
    showDialog(context: context, builder: (ctx) {
      return CustomPopUp(text: LS.tr('today_history_view.error'));
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
          title:TextDefault(
            content: 'today_history_view.posture_detection'.tr(),
            fontSize: 16,
            isBold: false,
            fontColor: const Color(0xFF64646F),
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
                      content: context.locale.languageCode == 'ko' ? '$_month월 ${_chosenDate+1}일' : TimeConvert.engDateFormat(_month, _chosenDate+1),
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
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const AssetIcon('arrowBack', size: 5, color: Color(0xFF8991A0),),
                                  const SizedBox(height: 5,),
                                  TextDefault(
                                      content: 'today_history_view.before'.tr(),
                                      fontSize: 14,
                                      isBold: true,
                                      fontColor: const Color(0xFF8991A0)
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
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const AssetIcon('arrowNext', size: 5, color: Color(0xFF8991A0),),
                                  const SizedBox(height: 5,),
                                  TextDefault(
                                      content: 'today_history_view.next'.tr(),
                                      fontSize: 14,
                                      isBold: true,
                                      fontColor: const Color(0xFF8991A0)
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
            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(7.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextDefault(
                          content: 'today_history_view.good_posture'.tr(),
                          fontSize: 28,
                          isBold: true,
                        ),
                        Row(
                          children: [
                            TextDefault(
                              content: TimeConvert.sec2Min(_normalTimeSec, context.locale.languageCode),
                              fontSize: 28,
                              isBold: true,
                              fontColor: const Color(0xFF115FE9),
                            ),
                            TextDefault(
                              content: 'today_history_view.total_time'.tr(args: [TimeConvert.sec2Min(_fullTimeSec, context.locale.languageCode)]),
                              //'/총 ${TimeConvert.sec2Min(_fullTimeSec)}',
                              fontSize: 18,
                              isBold: false,
                              fontColor: const Color(0xFF115FE9),
                            ),
                          ],
                        )
                      ],
                    ),
                    PoseDropdown(onChanged: (PoseType type) {
                      setState(() {
                        _chosenType = type;
                      });
                      final historyData = _historyDateKeyMap[_month].containsKey(_chosenDate+1) ? _historyDateKeyMap[_month][_chosenDate+1] : {'poseTimerMap': {}, 'daily': []};
                      _filterPoseMap(historyData);
                      setState(() {
                        _normalTimeSec = historyData['poseTimerMap']['${_chosenType.poseIdentifier}NORMAL'];
                      });
                    }, chosenValue: _chosenType,)
                  ],
                ),
                SizedBox(height: res.percentHeight(3),),
                _filteredPoseMap.isNotEmpty ? SizedBox(
                  height: res.percentHeight(45),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: _filteredPoseMap.length,
                    itemBuilder: (context, index) {
                      return PoseListItem(poseType: _chosenType, time: _filteredPoseMap.keys.toList()[index].split('T')[1]);
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
                        content: '${_month == DateTime.now().month && _chosenDate+1 == DateTime.now().day ?
                        'today_history_view.today'.tr() : 'today_history_view.this_day'.tr()} ${'today_history_view.no_history'.tr()}',
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
                        text: 'today_history_view.do_posture_detection'.tr(),
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