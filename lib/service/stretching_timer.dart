import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/view/stretch/models/stretching_action.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../util/localization_string.dart';
import '../view/stretch/data/stretching_data.dart';
import '../view/stretch/stretching.dart';
import '../view/stretch/widgets/stretching_start_modal.dart';

final GlobalKey<NavigatorState> stretchingNavigatorKey = GlobalKey<NavigatorState>();

class StretchingTimer extends ChangeNotifier {
  Timer? _timer;

  final List<int?> _intervals = [null, 600, 1200, 1800, 2400, 3000]; // 각 인덱스에 맞는 interval 값, null은 '사용 안함'
  int _selectedIntervalIndex = 2; // 초기 인덱스 -> 기본 30분
  int _selectedStretchingIndex = 0; // 초기 인덱스 -> 기본 3
  int get selectedIntervalIndex => _selectedIntervalIndex;
  int get selectedStretchingIndex => _selectedStretchingIndex;
  List<StretchingGroup> _stretchingList = StretchingData.init('ko');
  List<StretchingGroup> get stretchingList => _stretchingList;
  int? get selectedStretchingInterval => _intervals[_selectedIntervalIndex];

  int completedStretchCount = 0;
  static bool isStretchingMode = false;

  StretchingTimer(){
    init();
  }
  //스토리지에 스트레칭 알림 설정 저장
  void init() async {
    // const storage = FlutterSecureStorage();
    String? selectedIntervalIndexStorage = await storage.read(key: 'selectedIntervalIndex');
    String? selectedStretchingIndexStorage = await storage.read(key: 'selectedStretchingIndex');
    String? completedStretchCountStorage = await storage.read(key: 'completedStretchCount');

    if (selectedIntervalIndexStorage != null) {
      _selectedIntervalIndex = int.parse(selectedIntervalIndexStorage);
      // print('loadeddd $_selectedIntervalIndex');
    }
    if (selectedStretchingIndexStorage != null) {
      _selectedStretchingIndex = int.parse(selectedStretchingIndexStorage);
    }
    if (completedStretchCountStorage != null) {
      completedStretchCount = int.parse(completedStretchCountStorage);
      // print('completedStretchCount:${completedStretchCount}');
      if(Provider.of<GlobalTimer>(stretchingContext, listen: false).useSec <10) completedStretchCount = 0; // 오늘 처음켰을때 스트레칭 카운트도 0으로 바꿈
      // print('useSec: ${Provider.of<GlobalTimer>(stretchingContext, listen: false).useSec}');
    }
    notifyListeners(); // 모든 리스너에게 변경 사항을 알림


    // print("스트레칭인덱스 : ${_selectedIntervalIndex}, ${_selectedStretchingIndex}");
  }

  void setStretchingLan(String lanCode) {
    _stretchingList = StretchingData.init(lanCode);
    notifyListeners();
  }

  StretchingGroup getSelectedStretching() {
    return _stretchingList[_selectedStretchingIndex];
  }

  // 인덱스를 통해 interval 값을 변경하는 메서드
  void setStretchingIntervalIndex(int index) async {
    // print("스트레칭간격 수정${index}");
    if (index < 0 || index >= _intervals.length) {
      throw ArgumentError("Stretching Interval Setting Invalid index");
    }
    _selectedIntervalIndex = index;
    notifyListeners(); // 모든 리스너에게 변경 사항을 알림

    // const storage = FlutterSecureStorage();
    await storage.write(key: 'selectedIntervalIndex', value: _selectedIntervalIndex.toString());
  }

  // 인덱스를 통해 스트레칭 선택 값을 변경하는 메서드
  void setStretchingTypeIndex(int index) async{
    // print("스트레칭타입 수정${index}");
    if (index < 0 || index >= _stretchingList.length) {
      throw ArgumentError("Stretching Type Setting Invalid index");
    }
    _selectedStretchingIndex = index;
    notifyListeners(); // 모든 리스너에게 변경 사항을 알림

    // const storage = FlutterSecureStorage();
    await storage.write(key: 'selectedStretchingIndex', value: _selectedStretchingIndex.toString());
  }

  // 스트레칭가이드를 성공적으로 끝냈을때
  void finishStretchingSession() async{
    isStretchingMode = false;
    completedStretchCount++;
    // const storage = FlutterSecureStorage();
    await storage.write(key: 'completedStretchCount', value: completedStretchCount.toString());

    notifyListeners(); // UI 업데이트 트리거
  }


  int? getStretchingInterval(){
    return _intervals[_selectedIntervalIndex];
  }

  void setTimer() {
    _timer?.cancel();
    int? _interval = getStretchingInterval();
    if(_interval == null) return; //스트레칭 타이머 비활성화일때

    int initialUseSec = Provider.of<GlobalTimer>(stretchingContext, listen: false).useSec;
    late int currentUseSec;

    _showPushAlarm(
        LS.tr('stretching.timer.stretching_reminder_title', [_interval~/60]),
        LS.tr('stretching.timer.stretching_reminder_body',[_interval~/60])
    );

    _timer = Timer(Duration(seconds: _interval), () {
      // 새로운 타이머로 일정 간격마다 useSec를 체크하여 조건이 만족될 때까지 대기
      Timer.periodic(Duration(seconds: 1), (checkTimer) {
        if( DetectStatus.sNowDetecting == false){ //자세탐지 종료해버릴때
          checkTimer.cancel();
          return;
        }

        //스트레칭 타이머가 울렸는데, 아직 interval만큼 안지났다? -> 유저가 중간에 이어폰뺐거나 껐거나 그런경우임
        currentUseSec = Provider.of<GlobalTimer>(stretchingContext, listen: false).useSec;
        if ((currentUseSec - initialUseSec) < _interval) return;

        // 조건 만족 시 알람과 모달 호출
        checkTimer.cancel();
        _showPushAlarm(
          LS.tr('stretching.timer.stretching_reminder_title', [_interval ~/ 60]),
          LS.tr('stretching.timer.stretching_time_passed', [_interval ~/ 60]),
        );
        showStretchingStartModal();
        // 조건이 만족되면 반복 타이머 중지
      });
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  final NotificationDetails _details = const NotificationDetails(
      android: AndroidNotificationDetails('temp1', 'asdf'),
      iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
      )
  );

  Future<void> _showPushAlarm(String title, String body) async {
    FlutterLocalNotificationsPlugin localNotification =
    FlutterLocalNotificationsPlugin();

    await localNotification.show(10, // 푸쉬알림고유ID
        title,
        body,
        _details
    );
  }
}