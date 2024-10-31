import 'package:flutter/material.dart';
import 'package:mocksum_flutter/view/stretch/stretching_completed.dart';
import 'package:mocksum_flutter/view/stretch/stretching_session.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_complete_modal.dart';
import 'package:mocksum_flutter/view/stretch/widgets/stretching_start_modal.dart';
import 'package:provider/provider.dart';

import '../../../service/stretching_timer.dart';
import '../../../util/responsive.dart';

class StretchingDevEnv extends StatefulWidget {
  const StretchingDevEnv({Key? key}) : super(key: key);

  @override
  _StretchingDevEnvState createState() => _StretchingDevEnvState();
}

class _StretchingDevEnvState extends State<StretchingDevEnv> {
  int _anchorIdx = 0;
  @override
  Widget build(BuildContext context) {
    final stretchingTimer = Provider.of<StretchingTimer>(context);
    Responsive res = Responsive(context);
    return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showStretchingStartModal();
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
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StretchingSession()),
              );
            },
            child: const Text('스트레칭 세션'),
          ),
          ElevatedButton(
            onPressed: () {
              stretchingTimer.setTimer();
            },
            child: const Text('스트레칭타이머 설정'),
          ),
        ],
      );
  }
}
