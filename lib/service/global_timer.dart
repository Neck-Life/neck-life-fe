import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GlobalTimer with ChangeNotifier {

  int _useSec = 0;
  Timer? _timer;
  late String _lastDate;
  bool _isRunning = false;

  static final _timeEventController = StreamController<dynamic>.broadcast();
  static Stream<dynamic> get timeEventStream => _timeEventController.stream;

  int get useSec => _useSec;

  GlobalTimer() {
    init();
  }

  void init() async {
    // print('timer init');
    const storage = FlutterSecureStorage();
    String? lastDate = await storage.read(key: 'lastDate');
    String? useSecStr = await storage.read(key: 'useSec');
    DateTime now = DateTime.now();
    // print('useSec $useSecStr');
    if (useSecStr != null) {
      _useSec = int.parse(useSecStr);
    } else {
      _useSec = 0;
    }

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
    const storage = FlutterSecureStorage();
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
    await storage.write(key: 'useSec', value: '$_useSec');
  }

  void startTimer() {
    // print('starttimer');
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

  Future<void> emitTimeEvent(dynamic event) async {
    _timeEventController.add(event);
  }

}
