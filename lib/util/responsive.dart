import 'package:flutter/cupertino.dart';

class Responsive {
  BuildContext? context;
  double deviceWidth = 0;
  double deviceHeight = 0;

  Responsive(context_) {
    context = context_;
    deviceWidth = MediaQuery.of(context_).size.width;
    deviceHeight = MediaQuery.of(context_).size.height;
  }

  double percentWidth(double percent) {
    return deviceWidth*(percent/100);
  }

  double percentHeight(double percent) {
    return deviceHeight*(percent/100);
  }

  double fontSize(double fs) {
    return fs * deviceWidth / 392;
  }
}
