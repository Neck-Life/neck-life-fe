import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/service/goal_provider.dart';
import 'package:mocksum_flutter/theme/component/button.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:provider/provider.dart';

import '../../../../theme/asset_icon.dart';
import '../../../../theme/component/text_default.dart';
import '../../../service/history_provider.dart';
import '../../../service/user_provider.dart';

enum GoalType {
  score,
  time;

  String get keyName {
    switch (this) {
      case GoalType.score:
        return 'score';
      case GoalType.time:
        return 'time';
    }
  }

  String get typeName {
    switch (this) {
      case GoalType.score:
        return 'score';
      case GoalType.time:
        return 'measurement';
    }
  }

  String get typeNameCap {
    switch (this) {
      case GoalType.score:
        return 'SCORE';
      case GoalType.time:
        return 'MEASUREMENT';
    }
  }

  String get desc {
    switch (this) {
      case GoalType.score:
        return DetectStatus.lanCode == 'ko' ? '자세 점수 n점 달성하기' : "Posture score of np." ;
      case GoalType.time:
        return DetectStatus.lanCode == 'ko' ? '바른 자세 n분 유지하기' : "Correct posture for nm.";
    }
  }

  String get iconName {
    switch (this) {
      case GoalType.score:
        return 'tarket';
      case GoalType.time:
        return 'time';
    }
  }
}

class GoalSetting extends StatefulWidget {
  final GoalType? goalType;
  const GoalSetting({super.key, this.goalType});

  @override
  State<StatefulWidget> createState() => _GoalSettingState();
}

class _GoalSettingState extends State<GoalSetting> {

  GoalType? _chosenGoalType;
  int _goalValue = 85;
  int _initialValue = 0;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        _chosenGoalType = widget.goalType;
        if (widget.goalType == GoalType.score) {
          var targetValue = context.read<GoalProvider>().goalMap['score']['targetValue'];
          _goalValue = targetValue != null ? targetValue.toInt() : 85;
          _initialValue = targetValue != null ? targetValue.toInt() : 0;
        } else {
          var targetValue = context.read<GoalProvider>().goalMap['time']['targetValue'];
          _goalValue = targetValue != null ? targetValue.toInt() : 900;
          _initialValue = targetValue != null ? targetValue.toInt() : 0;
        }
      });
    });
    super.initState();
  }

  void showErrSnackbar(String msg) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: const Color(0xFFF25959),
                borderRadius: BorderRadius.circular(10)
            ),
            alignment: Alignment.center,
            child: const AssetIcon('close', color: Colors.white, size: 20,),
          ),
          const SizedBox(width: 10,),
          TextDefault(
            content: msg,
            fontSize: 16,
            isBold: false,
            fontColor: Colors.white,
          )
        ],
      ),
      backgroundColor: const Color(0xFF323238),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showSnackbar(String msg) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: const Color(0xFF34A853),
                borderRadius: BorderRadius.circular(10)
            ),
            alignment: Alignment.center,
            child: const AssetIcon('check', color: Colors.white, size: 20,),
          ),
          const SizedBox(width: 10,),
          TextDefault(
            content: msg,
            fontSize: 16,
            isBold: false,
            fontColor: Colors.white,
          )
        ],
      ),
      backgroundColor: const Color(0xFF323238),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> addGoalSetting() async {
    if (_chosenGoalType == null) {
      return;
    }

    const storage = FlutterSecureStorage();

    String? accessToken = await storage.read(key: 'accessToken');

    var postData = {
      'order': 1,
      'type': _chosenGoalType!.typeName,
      'description': _chosenGoalType!.desc,
      'target_value': _chosenGoalType == GoalType.time ? _goalValue.toDouble()*60 : _goalValue
    };

    try {
      if (accessToken == null || UserStatus.isTokenExpired(accessToken)) {
        String? refreshToken = await storage.read(key: 'refreshToken');
        Response res = await HistoryStatus.dio.post(
            '$HistoryStatus.serverAddress/members/token', data: {'refreshToken': refreshToken});

        if (res.statusCode! ~/ 100 == 2) {
          accessToken = res.data['data']['accessToken'];
          refreshToken = res.data['data']['refreshToken'];

          await storage.write(key: 'accessToken', value: accessToken);
          await storage.write(key: 'refreshToken', value: refreshToken);
        } else {
          throw Exception();
        }
      }

      if (accessToken != null && accessToken != '') {
        HistoryStatus.dio.options.headers["authorization"] = "bearer $accessToken";
      }

      print(postData);
      Response res = await HistoryStatus.dio.post(
          '${HistoryStatus.serverAddress}/goals', data: {'goals': [postData]});

      if (res.data['code'] == 'success') {
        print('success');
        context.read<GoalProvider>().addSettedGoalTypes(_chosenGoalType!);

        var oldGoalMap = context.read<GoalProvider>().goalMap;

        print('addres ${res.data}');
        for (var obj in res.data['data']['goals']) {
          if (obj['type'] == _chosenGoalType!.typeNameCap) {
            oldGoalMap[_chosenGoalType!.keyName] = {
              'order': obj['order'],
              'type': _chosenGoalType!.typeName,
              'targetValue': _chosenGoalType == GoalType.time ? _goalValue : _goalValue
            };
          }
        }
        context.read<GoalProvider>().updateGoalMap(oldGoalMap);
        Navigator.of(context).pop();
        showSnackbar('goal_view.add_snack'.tr());
      } else {
        throw Exception();
      }
    } on Exception catch (e) {
      showErrSnackbar('goal_view.err_popup'.tr());
      print(e);
    }
  }

  Future<void> updateGoalSetting() async {
    if (_chosenGoalType == null) {
      return;
    }

    const storage = FlutterSecureStorage();

    String? accessToken = await storage.read(key: 'accessToken');

    var postData = {
      'order': 1,
      'type': _chosenGoalType!.typeName,
      'description': _chosenGoalType!.desc,
      'target_value': _chosenGoalType == GoalType.time ? _goalValue : _goalValue
    };

    try {

      if (accessToken == null || UserStatus.isTokenExpired(accessToken)) {
        String? refreshToken = await storage.read(key: 'refreshToken');
        Response res = await HistoryStatus.dio.post(
            '$HistoryStatus.serverAddress/members/token', data: {'refreshToken': refreshToken});

        if (res.statusCode! ~/ 100 == 2) {
          accessToken = res.data['data']['accessToken'];
          refreshToken = res.data['data']['refreshToken'];

          await storage.write(key: 'accessToken', value: accessToken);
          await storage.write(key: 'refreshToken', value: refreshToken);
        } else {
          throw Exception();
        }
      }

      if (accessToken != null && accessToken != '') {
        HistoryStatus.dio.options.headers["authorization"] = "bearer $accessToken";
      }

      print(postData);
      Response res = await HistoryStatus.dio.put(
          '${HistoryStatus.serverAddress}/goals', data: {'goals': [postData]});

      print('here ${res.data}');
      if (res.data['code'] == 'resource.modified') {
        print('success');
        context.read<GoalProvider>().addSettedGoalTypes(_chosenGoalType!);

        var oldGoalMap = context.read<GoalProvider>().goalMap;


        for (var obj in res.data['data']['goals']) {
          print('loop2 $obj');
          if (obj['type'] == _chosenGoalType!.typeNameCap) {
            print('check $obj');
            oldGoalMap[_chosenGoalType!.keyName] = {
              'order': obj['order'],
              'type': _chosenGoalType!.typeName,
              'targetValue': _chosenGoalType == GoalType.time ? _goalValue*60 : _goalValue
            };
          }
        }
        context.read<GoalProvider>().updateGoalMap(oldGoalMap);
        Navigator.of(context).pop();
        showSnackbar('goal_view.upd_snack'.tr());
      } else {
        throw Exception();
      }
    } on Exception catch (e){
      showErrSnackbar('goal_view.err_popup'.tr());
      print(e);
    }
  }

  Future<void> deleteGoalSetting(int goalId) async {
    if (_chosenGoalType == null) {
      return;
    }

    const storage = FlutterSecureStorage();

    String? accessToken = await storage.read(key: 'accessToken');


    try {

      if (accessToken == null || UserStatus.isTokenExpired(accessToken)) {
        String? refreshToken = await storage.read(key: 'refreshToken');
        Response res = await HistoryStatus.dio.post(
            '$HistoryStatus.serverAddress/members/token', data: {'refreshToken': refreshToken});

        if (res.statusCode! ~/ 100 == 2) {
          accessToken = res.data['data']['accessToken'];
          refreshToken = res.data['data']['refreshToken'];

          await storage.write(key: 'accessToken', value: accessToken);
          await storage.write(key: 'refreshToken', value: refreshToken);
        } else {
          throw Exception();
        }
      }

      if (accessToken != null && accessToken != '') {
        HistoryStatus.dio.options.headers["authorization"] = "bearer $accessToken";
      }

      Response res = await HistoryStatus.dio.delete(
          '${HistoryStatus.serverAddress}/goals', data: {'goalIds': [goalId]});

      print(res.data);
      if (res.data['code'] == 'resource.deleted') {
        print('success');
        context.read<GoalProvider>().deleteSettedGoalTypes(_chosenGoalType!);

        var oldGoalMap = context.read<GoalProvider>().goalMap;

        oldGoalMap[_chosenGoalType!.keyName] = {};

        for (var obj in res.data['data']['goals']) {
          print('loop2 $obj');
          if (obj['type'] == _chosenGoalType!.typeNameCap) {
            print('check $obj');
            oldGoalMap[_chosenGoalType!.keyName] = {
              'order': obj['order'],
              'type': _chosenGoalType!.typeName,
              'targetValue': _goalValue
            };
          }
        }
        print('um $oldGoalMap');
        context.read<GoalProvider>().updateGoalMap(oldGoalMap);
        Navigator.of(context).pop();
        showSnackbar('goal_view.del_snack'.tr());
      } else {
        throw Exception();
      }
    } on Exception catch (e){
      showErrSnackbar('goal_view.err_popup'.tr());
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    GoalProvider goalState = context.watch();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
            backgroundColor: const Color(0xFFF4F4F7),
            title: TextDefault(
              content: 'goal_view.add_goal'.tr(),
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
      body: SizedBox(
        height: res.deviceHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WhiteContainer(
              margin: EdgeInsets.only(left: res.percentWidth(7.5), top: res.percentHeight(2)),
              padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
              radius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextDefault(content: 'goal_view.goal_set_txt1'.tr(), fontSize: 18, isBold: true, fontColor: Color(0xFF101010),),
                  SizedBox(height: res.percentHeight(2),),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _chosenGoalType = GoalType.score;
                        _goalValue = goalState.goalMap['score']['targetValue'] != null ? goalState.goalMap['score']['targetValue'].toInt() : 85;
                        _initialValue = goalState.goalMap['score']['targetValue'] != null ? goalState.goalMap['score']['targetValue'].toInt() : 0;
                      });
                    },
                    child: WhiteContainer(
                      padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2)),
                      borderColor: _chosenGoalType == GoalType.score ? const Color(0xFF236EF3) : const Color(0xFFF4F4F7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextDefault(content: 'goal_view.score'.tr(), fontSize: 16, isBold: false, fontColor: const Color(0xFF323238),),
                          Container(
                            width: res.percentWidth(5),
                            height: res.percentWidth(5),
                            padding: EdgeInsets.all(res.percentWidth(0.5)),
                            decoration: BoxDecoration(
                                color: _chosenGoalType == GoalType.score ? const Color(0xFF236EF3) : const Color(0xFFF4F4F7),
                                borderRadius: BorderRadius.circular(res.percentWidth(3))
                            ),
                            child: AssetIcon('check', size: 1, color: _chosenGoalType == GoalType.score ? Colors.white : const Color(0xFF101E32),),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: res.percentHeight(1),),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _chosenGoalType = GoalType.time;
                        _goalValue = goalState.goalMap['time']['targetValue'] != null ? goalState.goalMap['time']['targetValue'].toInt() : 900;
                        _initialValue = goalState.goalMap['time']['targetValue'] != null ? goalState.goalMap['time']['targetValue'].toInt() : 0;
                      });
                    },
                    child: WhiteContainer(
                      padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2)),
                      borderColor: _chosenGoalType == GoalType.time ? const Color(0xFF236EF3) : const Color(0xFFF4F4F7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextDefault(content: 'goal_view.time'.tr(), fontSize: 16, isBold: false, fontColor: const Color(0xFF323238),),
                          Container(
                            width: res.percentWidth(5),
                            height: res.percentWidth(5),
                            padding: EdgeInsets.all(res.percentWidth(0.5)),
                            decoration: BoxDecoration(
                                color: _chosenGoalType == GoalType.time ? const Color(0xFF236EF3) : const Color(0xFFF4F4F7),
                                borderRadius: BorderRadius.circular(res.percentWidth(3))
                            ),
                            child: AssetIcon('check', size: 1, color: _chosenGoalType == GoalType.time ? Colors.white : const Color(0xFF101E32),),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _chosenGoalType != null ? WhiteContainer(
              margin: EdgeInsets.only(left: res.percentWidth(7.5), top: res.percentHeight(2)),
              padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
              radius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextDefault(content: 'goal_view.goal_set_ask'.tr(args: [_chosenGoalType == GoalType.score ? 'goal_view.sc'.tr() : 'goal_view.min'.tr()]), fontSize: 18, isBold: true, fontColor: const Color(0xFF101010),),
                  SizedBox(height: res.percentHeight(2),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_chosenGoalType == GoalType.score && _goalValue > 5) {
                              _goalValue -= 5;
                            } else if (_chosenGoalType == GoalType.time && _goalValue > 300) {
                              _goalValue -= 300;
                            }
                          });
                        },
                        child: WhiteContainer(
                          width: res.percentWidth(1.5),
                          height: res.percentWidth(1.5),
                          radius: 7.5,
                          padding: EdgeInsets.symmetric(horizontal: res.percentWidth(0.5)),
                          child: const AssetIcon('minus', size: 2, color: Color(0xFF64646F),),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: res.percentWidth(3.5), vertical: res.percentHeight(1.25)),
                        margin: EdgeInsets.symmetric(horizontal: res.percentWidth(2)),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F7),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: TextDefault(content: '${_chosenGoalType == GoalType.time ? _goalValue ~/ 60 : _goalValue}${_chosenGoalType == GoalType.score ? 'goal_view.sc'.tr() : 'goal_view.min'.tr()}', fontSize: 14, isBold: false, fontColor: const Color(0xFF236EF3),),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_chosenGoalType == GoalType.score && _goalValue >= 100) return;
                          setState(() {
                            if (_chosenGoalType == GoalType.score) {
                              _goalValue += 5;
                            } else if (_chosenGoalType == GoalType.time) {
                              _goalValue += 300;
                            }
                          });
                          log('sdfg');
                        },
                        child: WhiteContainer(
                          width: res.percentWidth(1.5),
                          height: res.percentWidth(1.5),
                          radius: 7.5,
                          padding: EdgeInsets.symmetric(horizontal: res.percentWidth(0.75)),
                          child: const AssetIcon('plus', size: 2, color: Color(0xFF64646F),),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ) : const SizedBox(),
            const Spacer(),
            Container(
              margin: EdgeInsets.only(left: res.percentWidth(5), bottom: res.percentHeight(5)),
              child: !goalState.settedGoalTypes.contains(_chosenGoalType) ? Button(
                onPressed: () async {
                  await addGoalSetting();
                },
                text: 'goal_view.add_txt'.tr(),
                backgroundColor: _chosenGoalType != null ? const Color(0xFF236EF3) : const Color(0xFFCFCFD8),
                color: Colors.white,
                width: res.percentWidth(90),
                padding: res.percentWidth(4),
              ) : Container(
                padding: EdgeInsets.only(right: res.percentWidth(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Button(
                      onPressed: () async {
                        print(goalState.goalMap);
                        int goalId = goalState.goalMap[_chosenGoalType!.keyName]['order'];
                        await deleteGoalSetting(goalId);
                      },
                      text: 'goal_view.del_txt'.tr(),
                      backgroundColor: const Color(0xFF8991A0),
                      color: Colors.white,
                      width: res.percentWidth(43),
                      padding: res.percentWidth(4),
                    ),
                    Button(
                      onPressed: () async {
                        if (_goalValue != _initialValue) {
                          await updateGoalSetting();
                        }
                      },
                      text: 'goal_view.upd_txt'.tr(),
                      backgroundColor: _goalValue != _initialValue ? const Color(0xFF236EF3) : const Color(0xFFCFCFD8),
                      color: Colors.white,
                      width: res.percentWidth(43),
                      padding: res.percentWidth(4),
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}