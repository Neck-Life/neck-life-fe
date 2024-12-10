import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/theme/triangle.dart';
import 'package:mocksum_flutter/util/responsive.dart';

class StartButtonMsg extends StatefulWidget {
  final String message;

  const StartButtonMsg({
    super.key,
    required this.message,
  });

  @override
  State<StatefulWidget> createState() => _StartButtonMsgState();

}

class _StartButtonMsgState extends State<StartButtonMsg> {

  bool _interval = false;
  Timer? _timer;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _interval = !_interval;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Padding(
    padding: EdgeInsets.only(left: res.percentWidth(2)),
    child: AnimatedOpacity(
        opacity: _interval ? 1 : 0,
        duration: const Duration(seconds: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: res.percentWidth(2.5), top: res.percentHeight(3)),
              child: CustomPaint(
                painter: TrianglePainter(
                  strokeColor: const Color(0xFFE5E5EB),
                  strokeWidth: 2,
                  paintingStyle: PaintingStyle.fill,
                ),
                child: SizedBox(
                  height: res.percentWidth(1.5),
                  width: res.percentWidth(3.5),
                ),
              ),
            ),
            Container(
              // width: res.percentWidth(65),
              padding: EdgeInsets.symmetric(horizontal: res.percentWidth(3), vertical: res.percentHeight(1)),
              decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EB),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: TextDefault(content: widget.message, fontSize: 14, isBold: false),
            )
          ],
        ),
      )
    );
  }

}