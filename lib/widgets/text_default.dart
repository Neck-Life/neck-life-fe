import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';

class TextDefault extends StatelessWidget {

  final String content;
  final double fontSize;
  final bool isBold;

  const TextDefault({required this.content, required this.fontSize, required this.isBold, super.key});

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);

    return Text(
      content,
      style: TextStyle(
        color: Colors.black,
        fontSize: responsive.fontSize(fontSize),
        fontFamily: 'Inter',
        fontWeight: isBold ? FontWeight.w600 : FontWeight.w300,
      ),
    );
  }

}