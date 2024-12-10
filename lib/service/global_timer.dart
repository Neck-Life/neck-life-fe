import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../main.dart';

class GlobalTimer with ChangeNotifier {

  int _secOnStart = 0;
  int _useSec = 0;
  Timer? _timer;
  late String _lastDate;
  bool _isRunning = false;
  static int alarmCount = 0;

  static final _timeEventController = StreamController<dynamic>.broadcast();
  static Stream<dynamic> get timeEventStream => _timeEventController.stream;

  int get useSec => _useSec;
  int get secOnStart => _secOnStart;
  bool get isRunning => _isRunning;
  GlobalTimer() {
    init();
  }

  void init() async {
    // print('timer init');
    // const storage = FlutterSecureStorage();
    String? lastDate = await storage.read(key: 'lastDate');
    String? useSecStr = await storage.read(key: 'useSec');
    DateTime now = DateTime.now();
    // print('useSec $useSecStr');
    if (useSecStr != null) {
      _useSec = int.parse(useSecStr);
    } else {
      _useSec = 0;
    }
    alarmCount = 0;

    if (lastDate != null) {
      // print(lastDate);
      _lastDate = lastDate;
      if (lastDate != '${now.year}-${now.month}-${now.day}') {
        _useSec = 0;
        _lastDate = '${now.year}-${now.month}-${now.day}';
        notifyListeners();
        await storage.write(key: 'lastDate', value: '${now.year}-${now.month}-${now.day}');
        await storage.write(key: 'useSec', value: '0');
      }
    } else {
      _lastDate = '${now.year}-${now.month}-${now.day}';
      await storage.write(key: 'lastDate', value: '${now.year}-${now.month}-${now.day}');
    }
  }

  void updateNowTime() async {
    // const storage = FlutterSecureStorage();
    DateTime now = DateTime.now();

    if (_lastDate != '${now.year}-${now.month}-${now.day}') {
      _useSec = 0;
      _lastDate = '${now.year}-${now.month}-${now.day}';
      await storage.write(key: 'lastDate', value: '${now.year}-${now.month}-${now.day}');
    } else {
      _useSec += 1;
    }
    notifyListeners();
    emitTimeEvent(_useSec);
    // try{
    //   String? existingData =  await storage.read(key: 'useSec');
    //   // 기존 값이 있으면 새로운 설정으로 덮어쓰기를 진행
    //   print('1 $existingData');
    //   if (existingData != null) {
    //     await storage.delete(key: 'useSec');  // 기존 데이터를 삭제
    //     await newStorage.write(key: 'useSec', value: existingData);  // 새로운 옵션으로 다시 저장
    //   }
    //   else{
    //     await newStorage.write(key: 'useSec', value: '$_useSec');  // 새로운 옵션으로 다시 저장
    //   }
    //   // await storage.write(key: 'useSec', value: '$_useSec');
    //   //   accessibility: KeychainAccessibility.first_unlock_this_device,
    //   //   synchronizable: true,
    //   // ));
    // }catch(err){
    //   print(err);
    //   await newStorage.delete(key: 'useSec', iOptions: const IOSOptions());
    //   await newStorage.write(key: 'useSec', value: '$_useSec');
    // }
    // TODO: 10초 or 30초 간격으로 IO처리 하도록 개선하기
    await storage.write(key: 'useSec', value: '$_useSec');
    // print('2 ${await storage.read(key: 'useSec')}');
  }

  void startTimer() {
    // print('starttimer');
    _secOnStart = _useSec;
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        updateNowTime();
      });
    }
  }

  void restartTimer() {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        updateNowTime();
      });
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  int getDetectionTime() {
    return _useSec - _secOnStart;
  }

  Future<void> emitTimeEvent(dynamic event) async {
    _timeEventController.add(event);
  }

}
