import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocksum_flutter/view/stretch/stretching.dart';
import '../view/stretch/widgets/stretching_start_modal.dart';

/**
 * TODO: interval[] 단위: second vs minutes 결정하기 (현재는 10초로 테스트하는중)
 * TODO: 오늘 스트레칭한 횟수 반영 (서버 연동 고려)
 * */
final GlobalKey<NavigatorState> stretchingNavigatorKey = GlobalKey<NavigatorState>();

class StretchingTimer extends ChangeNotifier {
  final List<int?> _intervals = [10, 600, 1800, 3000]; // 각 인덱스에 맞는 interval 값, null은 '사용 안함'
  int _selectedIntervalIndex = 0; // 초기 인덱스
  Timer? _timer;
  int get selectedIntervalIndex => _selectedIntervalIndex;
  int completedStretchCount = 0;
  bool isStretchingMode = false;
  StretchingTimer(){}

  // 인덱스를 통해 interval 값을 변경하는 메서드
  void setStretchingIntervalIndex(int index) {
    if (index < 0 || index >= _intervals.length) {
      throw ArgumentError("Stretching Setting Invalid index");
    }
    _selectedIntervalIndex = index;
    notifyListeners(); // 모든 리스너에게 변경 사항을 알림
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
        '네키 : 스트레칭 알리미',
        '${(_interval!~/60)}분 후에 네키가 스트레칭 알림을 보내드릴게요!'
    );

    _timer = Timer(Duration(seconds: _interval), () {
      _showPushAlarm(
          '네키 : 스트레칭 알리미',
        '벌써 ${(_interval!~/60)}분이 지났어요!\n'
          '네키랑 같이 스트레칭 해볼까요?'
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