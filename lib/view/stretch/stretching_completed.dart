import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_complete_modal.dart';
import 'package:provider/provider.dart';

import '../../service/stretching_timer.dart';
import '../../util/localization_string.dart';

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
      // listen: false로 설정하여 Provider 접근
      final stretchingTimer = Provider.of<StretchingTimer>(context, listen: false);
      stretchingTimer.finishStretchingSession(); // 메서드 호출
      // showStretchingCompleteModal(context);
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
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                      const SizedBox(height: 10),
                      Text(
                        LS.tr('stretching.completed_view.good_job'),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        LS.tr('stretching.completed_view.stretching_complete'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 20.0),
              //   child: Text(
              //     LS.tr('stretching.completed_view.stretching_info'),
              //     style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}