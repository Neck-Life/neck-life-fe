import 'package:flutter/material.dart';
import 'package:mocksum_flutter/view/stretch/data/stretching_data.dart';
import 'package:mocksum_flutter/view/stretch/stretching_completed.dart';
import 'package:mocksum_flutter/view/stretch/widgets/StretchingWidget.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../service/status_provider.dart';
import 'models/stretching_action.dart';

class StretchingSessionDev extends StatefulWidget {
  final StretchingGroup selectedGroup = stretchingGroups[5];

// 선택된 그룹을 전달받음, 나중에 프로바이더에서 받아오기

  StretchingSessionDev({super.key});

  @override
  _StretchingSessionDevState createState() => _StretchingSessionDevState();
}

class _StretchingSessionDevState extends State<StretchingSessionDev> {
  double pitch = DetectStatus.nowPitch;
  double roll = DetectStatus.nowRoll;
  double yaw = DetectStatus.nowYaw;

  int currentStepIndex = 0;
  Timer? _timer, _updateDataTimer;
  double _elapsedTime = 0;
  bool _isActive = true;

  String get guideText => widget.selectedGroup.actions[currentStepIndex].name;

  String get stretchingGroupName => widget.selectedGroup.groupName;

  @override
  void initState() {
    super.initState();
    print("스트레칭 타이머 ");
// 1초마다 상태를 확인하고 강제로 setState()를 호출해 UI를 갱신
    _updateDataTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      setState(() {
        pitch = DetectStatus.nowPitch;
        roll = DetectStatus.nowRoll;
        yaw = DetectStatus.nowYaw;
      });
    });
    detectStretching();
  }

  void detectStretching() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DetectStatus>(context, listen: false).notifyListeners();
    });
  }

  void startTimer(double duration) {
    _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        _elapsedTime += 0.25;
      });

      if (_elapsedTime >= duration) {
        _goToNextStep();
        _resetTimer();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _elapsedTime = 0;
  }

  bool isStepCompleted(double pitch, double roll, double yaw) {
    final currentAction = widget.selectedGroup.actions[currentStepIndex];
    return currentAction.isCompleted(pitch, roll, yaw);
  }

  void checkStretchCompletion(double pitch, double roll, double yaw) {
    final currentAction = widget.selectedGroup.actions[currentStepIndex];

    if (_isActive && isStepCompleted(pitch, roll, yaw)) {
      if (_timer == null || !_timer!.isActive) {
        startTimer(currentAction.duration); // 동작별 duration을 사용
      }
    } else {
      _resetTimer();
    }
  }

  void _goToNextStep() {
    if (currentStepIndex < widget.selectedGroup.actions.length - 1) {
      setState(() {
        currentStepIndex += 1;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    _toggleStretchingWidget(); // 스트레칭 비활성화
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const StretchingCompletedScreen()),
    );
  }

  void _toggleStretchingWidget() {
    setState(() {
      _isActive = !_isActive;
      currentStepIndex = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _updateDataTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAction =
        widget.selectedGroup.actions[currentStepIndex]; // 동작 정보 가져오기
    final double duration = currentAction.duration; // 동작에 따른 duration 설정

    return Scaffold(
      appBar: AppBar(
        title: const Text('스트레칭 가이드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Consumer<DetectStatus>(
                builder: (context, detectStatus, child) {
                  checkStretchCompletion(pitch, roll, yaw);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        stretchingGroupName,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _isActive ? guideText : "스트레칭을 시작하세요",
                        style: const TextStyle(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$duration초 동안 유지: $_elapsedTime 초',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Pitch: ${pitch.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Roll: ${roll.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Yaw: ${yaw.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleStretchingWidget,
              child: Text(_isActive ? '스트레칭 비활성화' : '스트레칭 활성화'),
            ),
          ],
        ),
      ),
    );
  }
}
