import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../util/localization_string.dart';
import '../view/stretch/data/stretching_data.dart';
import '../view/stretch/widgets/stretching_start_modal.dart';

/**
 * TODO: interval[] 단위: second vs minutes 결정하기 (현재는 10초로 테스트하는중)
 * TODO: 오늘 스트레칭한 횟수 반영 (서버 연동 고려)
 * */
final GlobalKey<NavigatorState> stretchingNavigatorKey = GlobalKey<NavigatorState>();

class StretchingTimer extends ChangeNotifier {
  Timer? _timer;

  final List<int?> _intervals = [10, 600, 1800, 3000]; // 각 인덱스에 맞는 interval 값, null은 '사용 안함'
  int _selectedIntervalIndex = 2; // 초기 인덱스 -> 기본 30분
  int _selectedStretchingIndex = 0; // 초기 인덱스 -> 기본 3
  int get selectedIntervalIndex => _selectedIntervalIndex;
  int get selectedStretchingIndex => _selectedStretchingIndex;

  int completedStretchCount = 0;
  bool isStretchingMode = false;

  StretchingTimer(){
    init();
  }
  //스토리지에 스트레칭 알림 설정 저장
  void init() async {
    const storage = FlutterSecureStorage();
    String? selectedIntervalIndexStorage = await storage.read(key: 'selectedIntervalIndex');
    String? selectedStretchingIndexStorage = await storage.read(key: 'selectedStretchingIndex');

    if (selectedIntervalIndexStorage != null) {
      _selectedIntervalIndex = int.parse(selectedIntervalIndexStorage);
    }
    if (selectedStretchingIndexStorage != null) {
      _selectedStretchingIndex = int.parse(selectedStretchingIndexStorage);
    }
    notifyListeners(); // 모든 리스너에게 변경 사항을 알림


    // print("스트레칭인덱스 : ${_selectedIntervalIndex}, ${_selectedStretchingIndex}");
  }

  // 인덱스를 통해 interval 값을 변경하는 메서드
  void setStretchingIntervalIndex(int index) async{
    // print("스트레칭간격 수정${index}");
    if (index < 0 || index >= _intervals.length) {
      throw ArgumentError("Stretching Interval Setting Invalid index");
    }
    _selectedIntervalIndex = index;
    notifyListeners(); // 모든 리스너에게 변경 사항을 알림

    const storage = FlutterSecureStorage();
    await storage.write(key: 'selectedIntervalIndex', value: _selectedIntervalIndex.toString());
  }

  // 인덱스를 통해 스트레칭 선택 값을 변경하는 메서드
  void setStretchingTypeIndex(int index) async{
    // print("스트레칭타입 수정${index}");
    if (index < 0 || index >= stretchingGroups.length) {
      throw ArgumentError("Stretching Type Setting Invalid index");
    }
    _selectedStretchingIndex = index;
    notifyListeners(); // 모든 리스너에게 변경 사항을 알림

    const storage = FlutterSecureStorage();
    await storage.write(key: 'selectedStretchingIndex', value: _selectedStretchingIndex.toString());
  }

  // 스트레칭가이드를 성공적으로 끝냈을때
  void finishStretchingSession() {
    isStretchingMode = false;
    completedStretchCount++;
    setTimer(); // 타이머 재설정
    notifyListeners(); // UI 업데이트 트리거
  }


  int? getStretchingInterval(){
    return _intervals[_selectedIntervalIndex];
  }

  void setTimer() {
    _timer?.cancel();
    if(getStretchingInterval() == null) return; //스트레칭 타이머 비활성화일때

    int? _interval = getStretchingInterval();
    _showPushAlarm(
        LS.tr('stretching.timer.stretching_reminder_title', [_interval!~/60]),
        LS.tr('stretching.timer.stretching_reminder_body',[_interval~/60])
    );

    _timer = Timer(Duration(seconds: _interval), () {
      _showPushAlarm(
        LS.tr('stretching.timer.stretching_reminder_title', [_interval~/60]),
        LS.tr('stretching.timer.stretching_time_passed', [_interval~/60]),
      );
      showStretchingStartModal();
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