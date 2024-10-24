import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_complete_modal.dart';

class StretchingCompletedScreen extends StatefulWidget {
  const StretchingCompletedScreen({super.key});

  @override
  _StretchingCompletedScreenState createState() => _StretchingCompletedScreenState();
}

class _StretchingCompletedScreenState extends State<StretchingCompletedScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 3초 후에 이전 화면으로 돌아가는 타이머 설정
    _timer = Timer(const Duration(seconds: 3), () {
      Navigator.pop(context);
      showStretchingCompleteModal(context);
    });
  }

  @override
  void dispose() {
    // 화면이 사라질 때 타이머 취소
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    super.dispose();
  }
/**
 * TODO : 뒤로가기 막기?
 * */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo_circular.png',
                      width: 200,
                      height: 200,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '수고하셨어요!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '모든 스트레칭이 끝났습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'xx 자료에 의하면, 주기적인 스트레칭은\n집중력을 xx% 향상시켜준다고 해요!',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}