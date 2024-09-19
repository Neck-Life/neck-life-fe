import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GlobalTimer with ChangeNotifier {

  int _useMin = 0;
  Timer? _timer;
  late String _lastDate;

  static final _timeEventController = StreamController<dynamic>.broadcast();
  static Stream<dynamic> get timeEventStream => _timeEventController.stream;

  int get useMin => _useMin;

  GlobalTimer() {
    init();
  }

  void init() async {
    const storage = FlutterSecureStorage();
    String? lastDate = await storage.read(key: 'lastDate');
    String? useMinStr = await storage.read(key: 'useMin');
    DateTime now = DateTime.now();

    if (useMinStr != null) {
      _useMin = int.parse(useMinStr);
    } else {
      _useMin = 0;
    }

    if (lastDate != null) {
      print(lastDate);
      _lastDate = lastDate;
      if (lastDate != '${now.year}-${now.month}-${now.day}') {
        _useMin = 0;
        notifyListeners();
        await storage.write(key: 'lastDate', value: '${now.year}-${now.month}-${now.day}');
        await storage.write(key: 'useMin', value: '0');
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
      _useMin = 0;
      await storage.write(key: 'lastDate', value: '${now.year}-${now.month}-${now.day}');
    } else {
      _useMin += 1;
    }
    notifyListeners();
    emitTimeEvent(_useMin);
    await storage.write(key: 'useMin', value: '$_useMin');
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      updateNowTime();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> emitTimeEvent(dynamic event) async {
    _timeEventController.add(event);
  }

}
