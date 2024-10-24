import 'package:flutter/material.dart';
import 'package:mocksum_flutter/view/stretch/stretching_completed.dart';
import 'package:mocksum_flutter/view/stretch/widgets/StretchingWidget.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_complete_modal.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_start_modal.dart';

/**
 * 스트레칭괸련 테스트용 화면
 * TODO : 팀지 도중 mm분마다 스트레칭 모달창 띄우기
 */

class Stretching extends StatefulWidget {
  const Stretching({Key? key}) : super(key: key);

  @override
  _StretchingState createState() => _StretchingState();
}

class _StretchingState extends State<Stretching> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stretching Guide'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showStretchingStartModal(context);
            },
            child: Text("스트레칭 시작 모달창 띄우기"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StretchingCompletedScreen()),
              );
            },
            child: const Text('스트레칭 완료'),
          ),
          ElevatedButton(
            onPressed: () {
              showStretchingCompleteModal(context);
            },
            child: Text("스트레칭 완료 모달창 띄우기"),
          ),
        ],
      ),
    );
  }
}
