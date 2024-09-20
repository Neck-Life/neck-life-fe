import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';


class HistoryStatus with ChangeNotifier {
  static const String serverAddress = 'http://3.34.251.190:8080/api/v1';

  Map<String, dynamic>? _historyData;
  Map<String, int>? _date2idx;
  Map<String, dynamic>? _scoreSeries;
  Map<String, dynamic>? _goalsList;
  bool _shouldChangeData = true;
  bool _dateDataUpdated = false;
  bool _scoreSeriesUpdated = false;
  static var dio = Dio();


  void resetShouldChangeData() {
    _shouldChangeData = true;
    _dateDataUpdated = false;
    _scoreSeriesUpdated = false;
  }

  // bool get nowDetecting => _nowDetecting;
  Map<String, dynamic>? historyData() {
    return _historyData;
  }

  // Map<String, dynamic> chosenGoalSetting () {
  //   return _chosenGoalSetting;
  // }

  Map<String, dynamic>? scoreSeries() {
    return _scoreSeries;
  }

  Map<String, dynamic>? goalsList() {
    return _goalsList;
  }


  HistoryStatus() {
    init();
  }

  void init() async {
    print('init');
    const storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null && accessToken != '') {
      dio.options.headers["authorization"] = "bearer $accessToken";
    }

    print(accessToken);
    DateTime now = DateTime.now();
    // if (_historyData == null) {
    await updateHistoryData(now.year.toString(), now.month.toString());
    // }
    int cnt = 0;
    if (_historyData != null) {
      _date2idx = <String, int>{};
      for (Map<String, dynamic> data in _historyData?['daily']) {
        _date2idx?['${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${data['date'].toString().padLeft(2, '0')}'] = cnt++;
      }
    }
    // print('init end $_historyData');
    // print(_date2idx);

  }

  Future<Map<String, dynamic>> getHistoryWithDate(String date) async {
    List<String> parsedDate = date.split('-');
    String year = parsedDate[0];
    String month = parsedDate[1].replaceAll(RegExp(r'^0+(?=.)'), '');
    // print(_historyData);
    if (_historyData == null) {
      return {'date': '1970-01-01', 'success': false};
    }
    if (_shouldChangeData || _historyData?['year'] != year || _historyData?['month'] != month) {
      await updateHistoryData(year, month);
    }
    // print('test11 $date $_date2idx');
    // print(_date2idx!.containsKey(date));
    if (_date2idx!.containsKey(date)) {
      _historyData?['daily'][_date2idx?[date]]['success'] = true;
      // print('return');
      return _historyData?['daily'][_date2idx?[date]];
    } else {
      // print('asdf');
      return {'date': '1970-01-01', 'success': false};
    }
  }

  Future<void> updateHistoryData(String year, String month) async {
    try {
      const storage = FlutterSecureStorage();
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response res = await dio.get(
          '$serverAddress/history/monthly?year=${int.parse(year)}&month=${int.parse(month)}');
      if (res.data['code'] == 'success') {
        _historyData = res.data['data'];
        _dateDataUpdated = true;
        if (_scoreSeriesUpdated) {
          _shouldChangeData = false;
        }
        notifyListeners();
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

  Future<Map<String, dynamic>> getScoreSeries() async {
    try {
      const storage = FlutterSecureStorage();
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        dio.options.headers["authorization"] = "bearer $accessToken";
      }

      if (_shouldChangeData) {
        Response res = await dio.get(
            '$serverAddress/history/point');

        if (res.data['code'] == 'success') {
          _scoreSeries = res.data['data'];
          _scoreSeries?['success'] = true;
          // print('scores $_scoreSeries');
          // notifyListeners();
          _scoreSeriesUpdated = true;
          if (_dateDataUpdated) {
            _shouldChangeData = false;
          }

          return _scoreSeries!;
        } else {
          throw Exception();
        }
      } else {
        return _scoreSeries!;
      }

    } on Exception catch (e) {
      // print(e);
      return {'success': false};
    }
  }

  Future<Map<String, dynamic>> getUserGoalSetting() async {
    try {
      const storage = FlutterSecureStorage();
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null && accessToken != '') {
        dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response res = await dio.get('$serverAddress/goals');
      // print('getgoal ${res.data}');
      if (res.data['code'] == 'success') {
        _goalsList = res.data['data'];
        _goalsList?['success'] = true;
      } else {
        throw Exception();
      }

      // notifyListeners();
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
    postData['order'] = _goalsList?['goals'].length > 0 ? (_goalsList?['goals'].last()['order']+1) : 1;
    _goalsList?['goals'].add(postData);
    // print('fuck $_goalsList');
    notifyListeners();

    try {
      Response res = await dio.post(
          '$serverAddress/goals', data: {'goals': [postData]});

      if (res.data['code'] == 'success') {
        // print('success');
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
      _goalsList?['goals'].removeWhere((item) => item['order'] == id);
      notifyListeners();
      // print(_goalsList);
      if (res.data['code'] == 'success') {
        print('success');
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

  static Future<void> postMeasuredPoseData(dynamic poseHistory) async {
    const storage = FlutterSecureStorage();

    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null && accessToken != '') {
      dio.options.headers["authorization"] = "bearer $accessToken";
    }

    // print({'historys': [poseHistory]});

    try {
      // print(poseHistory);
      Response res = await dio.post(
          '$serverAddress/history', data: {'historys': [poseHistory['history']]});

      if (res.data['code'] == 'success') {
        print('success');
        return;
      } else {
        throw Exception();
      }
    } on Exception catch (e){
      print(e);
      String? dataNotPosted = await storage.read(key: 'dataNotPosted');
      dataNotPosted ??= '[]';

      List<dynamic> dataNotPostedList = json.decode(dataNotPosted);
      dataNotPostedList.add(poseHistory);

      await storage.write(key: 'dataNotPosted', value: json.encode(dataNotPostedList));
    }
  }

  static Future<void> postDataNotPosted() async {
    const storage = FlutterSecureStorage();

    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null && accessToken != '') {
      dio.options.headers["authorization"] = "bearer $accessToken";
    }

    String? dataNotPosted = await storage.read(key: 'dataNotPosted');
    if (dataNotPosted == null || dataNotPosted == '[]') {
      return;
    }

    try {
      Response res = await dio.post(
          '$serverAddress/history', data: {'historys': json.decode(dataNotPosted)});
      if (res.data['code'] == 'success') {
        print('success');
        print('sened $dataNotPosted');
        await storage.write(key: 'dataNotPosted', value: '[]');
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
      print('feedback asdf');
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
