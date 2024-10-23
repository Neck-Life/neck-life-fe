import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';


class HistoryStatus with ChangeNotifier {
  static const String serverAddress = 'http://necklife-prod-1214-env.eba-mtve9iwm.ap-northeast-2.elasticbeanstalk.com/api/v1';
  static const String serverAddressV3 = 'http://necklife-prod-1214-env.eba-mtve9iwm.ap-northeast-2.elasticbeanstalk.com/api/v3';

  // static const String serverAddress = 'http://43.200.200.34/api/v1';
  // static const String serverAddressV3 = 'http://43.200.200.34/api/v3';

  Map<String, dynamic> _historyData = {'daily' : []};
  Map<String, dynamic> _pastHistoryData = {'daily' : [], 'poseTimerMap': {}};
  Map<String, dynamic> _todayHistory = {'poseCountMap': {}};
  Map<String, dynamic> _scoreSeries = {'historyPointMap': {}};
  Map<String, dynamic> _scoreSeries2 = {'historyPointMap': {}};
  Map<String, int>? _date2idx;
  Map<String, dynamic>? _goalsList;
  bool _shouldChangeData = true;
  bool _dateDataUpdated = false;
  bool _scoreSeriesUpdated = false;
  static var dio = Dio();


  void clearAll() {
    _historyData.clear();
    _pastHistoryData.clear();
    _date2idx?.clear();
    _scoreSeries.clear();
    _goalsList?.clear();
    _shouldChangeData = true;
    _dateDataUpdated = false;
    _scoreSeriesUpdated = false;
  }


  void resetShouldChangeData() {
    _shouldChangeData = true;
    _dateDataUpdated = false;
    _scoreSeriesUpdated = false;
  }

  // bool get nowDetecting => _nowDetecting;
  Map<String, dynamic> get todayHistory => _todayHistory;
  Map<String, dynamic> get historyData => _historyData;
  Map<String, dynamic> get pastHistoryData => _pastHistoryData;
  Map<String, dynamic> get scoreSeries => _scoreSeries;
  Map<String, dynamic> get scoreSeries2 => _scoreSeries2;


  Map<String, dynamic>? goalsList() {
    return _goalsList;
  }


  HistoryStatus() {
    init();
  }

  void init() async {
    // print('his init');
    // const storage = FlutterSecureStorage();
    // String? accessToken = await storage.read(key: 'accessToken');
    // if (accessToken != null && accessToken != '') {
    //   dio.options.headers["authorization"] = "bearer $accessToken";
    // }
    //
    // String? dataNotPosted = await storage.read(key: 'dataNotPosted');
    // print('dnp $dataNotPosted');

    // print(accessToken);
    // DateTime now = DateTime.now();
    // // if (_historyData == null) {
    // await updateHistoryData(now.year.toString(), now.month.toString());
    // await getScoreSeriesV2('MONTH6');
    // }
    // int cnt = 0;
    // // print(_historyData);
    // if (_historyData['success'] != false) {
    //   _date2idx = <String, int>{};
    //   for (Map<String, dynamic> data in _historyData['daily']) {
    //     // print(data);
    //     _date2idx?['${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${data['date'].toString().padLeft(2, '0')}'] = cnt++;
    //   }
    // }
    //
    // _todayHistory = getHistoryWithDateV2(now.day);
    // print(_pastHistoryData);
    // print('score init $_scoreSeries');
    // _scoreSeries2 = _scoreSeries;
    // print(_date2idx);

  }


  Future<Map<String, dynamic>> getPastHistoryWithDate(String date) async {
    List<String> parsedDate = date.split('-');
    String year = parsedDate[0];
    String month = parsedDate[1].replaceAll(RegExp(r'^0+(?=.)'), '');
    // print(_historyData);
    // print('test $_historyData $_shouldChangeData');
    // print('getHistoryWithDate $date');
    if (_shouldChangeData || _pastHistoryData['year'] != year || _pastHistoryData['month'] != month) {
      await updateHistoryData(year, month);
    }

    if (_pastHistoryData == null) {
      // print('check1');
      return {'date': '1970-01-01', 'success': false};
    }

    // print('test11 $date $_date2idx');
    // print(_date2idx!.containsKey(date));
    if (_date2idx!.containsKey(date)) {
      _pastHistoryData['daily'][_date2idx?[date]]['success'] = true;
      // print('return');
      // print(_pastHistoryData['daily'][_date2idx?[date]]);
      return _pastHistoryData['daily'][_date2idx?[date]];
    } else {
      // print('asdf');
      return {'date': '1970-01-01', 'success': false};
    }
  }

  // 특정 달
  Map<String, dynamic> getPastHistoryWithDateV2(int date) {
    String dateStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${date.toString().padLeft(2, '0')}';
    // print('test $dateStr');
    // print('test $_date2idx');
    if (_date2idx!.containsKey(dateStr)) {
      _pastHistoryData['daily'][_date2idx?[dateStr]]['success'] = true;
      // print('return');
      return _pastHistoryData['daily'][_date2idx?[dateStr]];
    } else {
      // print('asdf');
      return {'daily' : [], 'poseTimerMap': {}};
    }
  }

  // 이번 달 한정
  Map<String, dynamic> getHistoryWithDateV2(int date) {
    String dateStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${date.toString().padLeft(2, '0')}';
    if (_date2idx!.containsKey(dateStr)) {
      _historyData['daily'][_date2idx?[dateStr]]['success'] = true;
      // print('return');
      return _historyData['daily'][_date2idx?[dateStr]];
    } else {
      // print('asdf');
      return {'poseCountMap': {}, 'daily' : []};
    }

  }


  Future<Map<String, dynamic>> getHistoryWithDate(String date) async {
    List<String> parsedDate = date.split('-');
    String year = parsedDate[0];
    String month = parsedDate[1].replaceAll(RegExp(r'^0+(?=.)'), '');
    // print(_historyData);
    // print('test $_historyData $_shouldChangeData');
    // print('getHistoryWithDate $date');
    if (_shouldChangeData || _historyData['year'] != year || _historyData['month'] != month) {
      await updateHistoryData(year, month);
    }

    if (_historyData == null) {
      // print('check1');
      return {'date': '1970-01-01', 'success': false};
    }

    // print('test11 $date $_date2idx');
    // print(_date2idx!.containsKey(date));
    if (_date2idx!.containsKey(date)) {
      _historyData['daily'][_date2idx?[date]]['success'] = true;
      // print('return');
      return _historyData['daily'][_date2idx?[date]];
    } else {
      // print('asdf');
      return {'date': '1970-01-01', 'success': false};
    }
  }

  Future<void> updateHistoryData(String year, String month) async {
    const storage = FlutterSecureStorage();
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response res = await dio.get(
          '$serverAddressV3/history/monthly?year=${int.parse(year)}&month=${int.parse(month)}');
      // print(res.data);
      // print('get history');
      DateTime now = DateTime.now();
      if (res.data['code'] == 'success') {
        // print('$year $month, ${now.year.toString()} ${now.month.toString().padLeft(2, '0')}');
        if (year != now.year.toString() || month != now.month.toString()) {
          _pastHistoryData = res.data['data'];
          int cnt = 0;
          for (Map<String, dynamic> data in _pastHistoryData['daily']) {
            _date2idx?['$year-${month.padLeft(2, '0')}-${data['date']
                .toString()
                .padLeft(2, '0')}'] = cnt++;
          }
        } else {
          // print('ok');
          _historyData = res.data['data'];
          _pastHistoryData = res.data['data'];
          // print(_historyData);
          _dateDataUpdated = true;
          _date2idx = <String, int>{};
          int cnt = 0;
          // DateTime now = DateTime.now();
          for (Map<String, dynamic> data in _historyData['daily']) {
            _date2idx?['$year-${month.padLeft(2, '0')}-${data['date']
                .toString()
                .padLeft(2, '0')}'] = cnt++;
          }
          storage.write(
              key: 'posehistoryLocal', value: json.encode(_historyData));
          if (_scoreSeriesUpdated) {
            _shouldChangeData = false;
          }
          notifyListeners();
          print('notify');
        }
      }
    } on DioException catch(e) {
      String? historyDataStr = await storage.read(key: 'posehistoryLocal');
      if (historyDataStr == null) {
        _historyData =  {'success': false};
      } else {
        _historyData = json.decode(historyDataStr);
      }
    } on Exception catch (e) {
      print(e);
      _historyData = {'success': false};
    }
  }

  Future<Map<String, dynamic>> getTodayHistoryData() async {
    DateTime now = DateTime.now();
    return await getHistoryWithDate('${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
  }

  Future<Map<String, dynamic>> getScoreSeriesV2(String duration) async {
    // print('getsore');
    const storage = FlutterSecureStorage();
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response res = await dio.get(
          '$serverAddress/history/point?type=$duration');

      if (res.data['code'] == 'success') {
        _scoreSeries = Map.from(res.data['data']);
        // print(_scoreSeries);
        // _scoreSeries['success'] = true;
        // print('scores $_scoreSeries');
        notifyListeners();
        _scoreSeriesUpdated = true;
        storage.write(key: 'scoreserieslocal', value: json.encode(_scoreSeries));
        if (_dateDataUpdated) {
          _shouldChangeData = false;
        }

        return _scoreSeries;
      } else {
        // print('fuck1');
        _scoreSeries = {'historyPointMap': {}};
        throw Exception();
      }

    } on DioException catch(e) {
      // print('fuck2');
      print(e);
      String? scoreSeriesStr = await storage.read(key: 'scoreserieslocal');
      // print('check $scoreSeriesStr');
      if (scoreSeriesStr == null) {
        _scoreSeries = {'historyPointMap': {}};
      } else {
        _scoreSeries = json.decode(scoreSeriesStr);
      }

      return _scoreSeries;
    } on Exception catch (e) {
      print(e);
      return {'success': false};
    }
  }

  Future<Map<String, dynamic>> getScoreSeries() async {
    const storage = FlutterSecureStorage();
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        dio.options.headers["authorization"] = "bearer $accessToken";
      }

      print('test $accessToken');
      if (_shouldChangeData) {
        Response res = await dio.get(
            '$serverAddress/history/point');

        if (res.data['code'] == 'success') {
          _scoreSeries = res.data['data'];
          print('data $_scoreSeries');
          _scoreSeries['success'] = true;
          // print('scores $_scoreSeries');
          // notifyListeners();
          _scoreSeriesUpdated = true;
          storage.write(key: 'scoreserieslocal', value: json.encode(_scoreSeries));
          if (_dateDataUpdated) {
            _shouldChangeData = false;
          }

          return _scoreSeries;
        } else {
          throw Exception();
        }
      } else {
        print('check2 $_scoreSeries');
        return _scoreSeries;
      }

    } on DioException catch(e) {
      String? scoreSeriesStr = await storage.read(key: 'scoreserieslocal');
      print('check $scoreSeriesStr');
      if (scoreSeriesStr == null) {
        _scoreSeries =  {'success': false};
      } else {
        _scoreSeries = json.decode(scoreSeriesStr);
      }

      return _scoreSeries!;
    } on Exception catch (e) {
      // print(e);
      return {'success': false};
    }
  }

  Future<Map<String, dynamic>> getUserGoalSetting() async {
    const storage = FlutterSecureStorage();
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response res = await dio.get('$serverAddress/goals');
      // print('getgoal ${res.data}');
      if (res.data['code'] == 'success') {
        _goalsList = res.data['data'];
        _goalsList?['success'] = true;
        storage.write(key: 'goallistlocal', value: json.encode(_goalsList));
      } else {
        throw Exception();
      }

      // notifyListeners();
      return _goalsList!;

    } on DioException catch(e) {
      String? goalListStr = await storage.read(key: 'goallistlocal');
      if (goalListStr == null) {
        _goalsList =  {'goals': [], 'success': false};
      } else {
        _goalsList = json.decode(goalListStr);
      }

      return _goalsList!;
    } on Exception catch (e) {
      print(e);
      return {'success': false};
    }
  }


  Future<bool> addGoalSetting(String type, int value, String desc) async {
    const storage = FlutterSecureStorage();

    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null && accessToken != '') {
      dio.options.headers["authorization"] = "bearer $accessToken";
    }

    var postData = {
      'order': 1,
      'type': type,
      'description': desc,
      'target_value': value
    };

    // 나중에 success 안에 넣기

    try {
      Response res = await dio.post(
          '$serverAddress/goals', data: {'goals': [postData]});

      if (res.data['code'] == 'success') {
        // print('success');
        postData['order'] = _goalsList?['goals'].length > 0 ? (_goalsList?['goals'].last()['order']+1) : 1;
        _goalsList?['goals'].add(postData);
        // print('fuck $_goalsList');
        notifyListeners();
        return true;
      } else {
        throw Exception();
      }
    } on Exception catch (e){
      print(e);
      print('add fail');
      return false;
    }
  }

  Future<bool> deleteGoalSetting(int id) async {
    const storage = FlutterSecureStorage();

    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null && accessToken != '') {
      dio.options.headers["authorization"] = "bearer $accessToken";
    }

    try {
      Response res = await dio.delete(
          '$serverAddress/goals', data: {'goalsIds': [id]});

      // 추후 success 절 안에 넣기
      // print(_goalsList);
      if (res.data['code'] == 'success') {
        print('success');
        _goalsList?['goals'].removeWhere((item) => item['order'] == id);
        notifyListeners();
        return true;
      } else {
        throw Exception();
      }
    } on Exception catch (e){
      print(e);
      print('delete fail');
      return false;
    }
  }

  Future<Map<String, dynamic>> getGoalHistory() async {
    const storage = FlutterSecureStorage();

    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null && accessToken != '') {
      dio.options.headers["authorization"] = "bearer $accessToken";
    }
    try {
      Response res = await dio.get('$serverAddress/goals/history');

      if (res.data['code'] == 'success') {
        print('success');
        Map<String, dynamic> goalHistory = res.data['data'];
        goalHistory['success'] = true;
        return goalHistory;
      } else {
        throw Exception();
      }
    } on Exception catch (e){
      print(e);
      print('delete fail');
      return {'success': false};
    }

  }

  Future<int> getGoalStreak() async {
    const storage = FlutterSecureStorage();

    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null && accessToken != '') {
      dio.options.headers["authorization"] = "bearer $accessToken";
    }
    try {
      Response res = await dio.get('$serverAddress/goals/streak');

      if (res.data['code'] == 'success') {
        print('success');
        return res.data['data']['currentGoalStreak'];
      } else {
        throw Exception();
      }
    } on Exception catch (e){
      print(e);
      print('delete fail');
      return 0;
    }

  }

  static Future<void> postMeasuredPoseData(dynamic pitchLog,dynamic forwardLog,dynamic tiltLog, dynamic rawData  ) async {
    const storage = FlutterSecureStorage();

    print('postMeasuredPoseData');
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null && accessToken != '') {
      dio.options.headers["authorization"] = "bearer $accessToken";
    }

    print('history post');
    print({'pitchLog': pitchLog});

    // print({'pitch': [pitchLog['pitch']] , 'forward': [forwardLog['forward']], 'tilt': [tiltLog['tilt']], 'rawData': rawData});



    try {
      // print(poseHistory);

      print('sadfdsfdfsdssdsdfsa');
      print({'pitch': [pitchLog['pitch']] ,'rawData': rawData, 'forward': [forwardLog['forward']], 'tilt': [tiltLog['tilt']]});
      // todo 데이터 전송방식이 바뀌어서 안보내졌을때 캐시에 저장하는거 수정되어야 함
      Response res = await dio.post(
          '$serverAddressV3/history', data: {'pitch': [pitchLog['pitch']] ,'rawData': rawData, 'forward': [forwardLog['forward']], 'tilt': [tiltLog['tilt']]});

      print(res.data);
      if (res.data['code'] == 'success') {
        print('success');
        return;
      } else {
        throw Exception();
      }
    } on Exception catch (e){
      print(e);

      //  todo 데이터 형식 바뀜  pitch
      String? dataNotPostedPitch = await storage.read(key: 'dataNotPostedPitch');
      dataNotPostedPitch ??= '[]';



      List<dynamic> dataNotPostedPitchList = json.decode(dataNotPostedPitch);
      dataNotPostedPitchList.add(pitchLog['pitch']);
      // print(dataNotPostedList);
      await storage.write(key: 'dataNotPostedPitch', value: json.encode(dataNotPostedPitchList));


      //forward
      String? dataNotPostedForward = await storage.read(key: 'dataNotPostedForward');
      dataNotPostedForward ??= '[]';



      List<dynamic> dataNotPostedForwardList = json.decode(dataNotPostedForward);
      dataNotPostedForwardList.add(forwardLog['forward']);
      // print(dataNotPostedList);
      await storage.write(key: 'dataNotPostedForward', value: json.encode(dataNotPostedForwardList));


      //tilt
      String? dataNotPostedTilt = await storage.read(key: 'dataNotPostedTilt');
      dataNotPostedTilt ??= '[]';



      List<dynamic> dataNotPostedTiltList = json.decode(dataNotPostedTilt);
      dataNotPostedTiltList.add(tiltLog['tilt']);
      // print(dataNotPostedList);
      await storage.write(key: 'dataNotPostedTilt', value: json.encode(dataNotPostedTiltList));

      //raw
      String? dataNotPostedRaw = await storage.read(key: 'dataNotPostedRaw');
      dataNotPostedRaw ??= '[]';



      List<dynamic> dataNotPostedRawList = json.decode(dataNotPostedRaw);
      dataNotPostedRawList.add(rawData);
      // print(dataNotPostedList);
      await storage.write(key: 'dataNotPostedRaw', value: json.encode(dataNotPostedRawList));




    }
  }

  static Future<void> postDataNotPosted() async {
    const storage = FlutterSecureStorage();

    // print('post not posted');
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null && accessToken != '') {
      dio.options.headers["authorization"] = "bearer $accessToken";
    }

    String? dataNotPostedPitch = await storage.read(key: 'dataNotPostedPitch');
    String? dataNotPostedForward = await storage.read(key: 'dataNotPostedForward');
    String? dataNotPostedTilt = await storage.read(key: 'dataNotPostedTilt');
    String? dataNotPostedRaw = await storage.read(key: 'dataNotPostedRaw');
    if (dataNotPostedPitch == null || dataNotPostedPitch == '[]' || dataNotPostedForward == null || dataNotPostedForward == '[]' || dataNotPostedTilt == null || dataNotPostedTilt == '[]' || dataNotPostedRaw == null || dataNotPostedRaw == '[]') {
      return;
    }


    try {
      Response res = await dio.post(
          '$serverAddressV3/history', data: {'pitch': json.decode(dataNotPostedPitch), 'forward': json.decode(dataNotPostedForward), 'tilt': json.decode(dataNotPostedTilt), 'rawData': json.decode(dataNotPostedRaw)});
      if (res.data['code'] == 'success') {
        // print('success');
        // print('sened $dataNotPosted');
        await storage.write(key: 'dataNotPostedPitch', value: '[]');
        await storage.write(key: 'dataNotPostedForward', value: '[]');
        await storage.write(key: 'dataNotPostedTilt', value: '[]');
        await storage.write(key: 'dataNotPostedRaw', value: '[]');


        return;
      } else {
        throw Exception();
      }
    } on Exception {
      print('adsfasffsdfdsfsd');
      return;
    }
  }

  static Future<bool> sendFeedback(String content) async {
    try {
      print('feedback $content');
      Response res = await dio.post(
          '$serverAddress/members/inquiry',
          data: {"title": "문의", "content": content}
      );
      print('feedback start');
      print(res.data);
      if (res.data['code'] == 'success') {
        print('feedback sended');
        return true;
      }
      throw Exception();
    } on Exception {
      print('feedback send fail');
      return false;
    }
  }

//   Future<List<Map<String, dynamic>> _getUserGoals() {
//     try {
//       Response res = await dio.get('$serverAddress/goal');
//       if (res.data['code'] == 'success') {
//
//       }
//     }
// }
}
