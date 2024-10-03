import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';

class ScoreBar extends StatelessWidget {
  final int score;
  final double? width;

  const ScoreBar({
    super.key,
    required this.score,
    this.width
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    int score_ = score;

    return Stack(
      children: [
        Container(
          width: width == null ? res.percentWidth(85) : res.percentWidth(width!),
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5EB),
            borderRadius: BorderRadius.circular(30),
          )
        ),
        Container(
            width: width == null ? res.percentWidth(85)*(score_/100) : res.percentWidth(width!)*(score_/100),
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF236EF3),
              borderRadius: BorderRadius.circular(30),
            )
        )
      ],
    );
  }

}