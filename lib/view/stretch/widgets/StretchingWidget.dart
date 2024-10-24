import 'package:flutter/material.dart';
import 'package:mocksum_flutter/view/stretch/data/stretching_data.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../service/status_provider.dart';
import '../models/stretching_action.dart';

/**
 * deprecated
 * TODO: 위젯이 아니라 스캐폴드로 만든뒤 네비게이션 시켜버리기
 * */

class StretchingWidget extends StatefulWidget {
  final StretchingGroup selectedGroup = stretchingGroups[0];
  // 선택된 그룹을 전달받음, 나중에 프로바이더에서 받아오기

  StretchingWidget({super.key});

  @override
  _StretchingWidgetState createState() => _StretchingWidgetState();
}

class _StretchingWidgetState extends State<StretchingWidget> {
  int currentStepIndex = 0;
  Timer? _timer;
  double _elapsedTime = 0;
  bool _isActive = false;

  String get guideText => widget.selectedGroup.actions[currentStepIndex].name;
  String get stretchingGroupName => widget.selectedGroup.groupName;
  @override
  void initState() {
    super.initState();
    detectStretching();
  }

  void detectStretching() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DetectStatus>(context, listen: false).notifyListeners();
    });
  }

  void startTimer(double duration) {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _elapsedTime += 0.5;
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('수고하셨습니다!'),
        content: const Text('스트레칭을 완료하셨습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              _toggleStretchingWidget();
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("스트레칭 위젯");
    final currentAction = widget.selectedGroup.actions[currentStepIndex]; // 동작 정보 가져오기
    final double duration = currentAction.duration; // 동작에 따른 duration 설정

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Consumer<DetectStatus>(
            builder: (context, detectStatus, child) {
              double pitch = DetectStatus.nowPitch;
              double roll = DetectStatus.nowRoll;
              double yaw = DetectStatus.nowYaw;

              checkStretchCompletion(pitch, roll, yaw);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    stretchingGroupName,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                    'Pitch: ${pitch.toStringAsFixed(3)}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Roll: ${roll.toStringAsFixed(3)}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Yaw: ${yaw.toStringAsFixed(3)}',
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
    );
  }
}