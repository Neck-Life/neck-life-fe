import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';

import '../../../theme/component/text_default.dart';


class SpinningTimer extends StatelessWidget {
  final int lastTime;


  const SpinningTimer({super.key, required this.lastTime});

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Container(
      margin: EdgeInsets.only(left: res.percentWidth(17.5)),
      child: SizedBox(
        width: res.percentWidth(50),
        height: res.percentWidth(50),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 20,
              backgroundColor: Color(0xFFE2E2E2),
              color: Color(0xFF236EF3),
            ),
            Center(
              child: ClipRRect(
                child: Container(
                  width: res.percentWidth(50),
                  height: res.percentWidth(50),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(res.percentWidth(25))
                  ),
                  alignment: Alignment.center,
                  child: TextDefault(
                      content: lastTime.toString(),
                      fontSize: 80,
                      isBold: false
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}