import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';

class TextDefault extends StatelessWidget {

  final String content;
  final double fontSize;
  final bool isBold;
  final Color? fontColor;
  final double? height;
  final bool? underline;

  const TextDefault({
    required this.content,
    required this.fontSize,
    required this.isBold,
    this.fontColor,
    this.height,
    this.underline,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    String content_ = content;
    return Text(
      content_,
      style: TextStyle(
        color: fontColor ?? Colors.black,
        fontSize: responsive.fontSize(fontSize),
        fontFamily: 'Inter',
        fontWeight: isBold ? FontWeight.w600 : FontWeight.w300,
        height: height ?? 1.2,
        decoration: underline == true ? TextDecoration.underline : null
      ),
    );
  }

}