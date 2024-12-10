import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/view/login/login_view.dart';

import 'component/text_default.dart';

class BlurToLogin extends StatelessWidget {
  final double width;
  final double height;
  final String? tab;


  const BlurToLogin({
    super.key,
    required this.width,
    required this.height,
    this.tab
  });



  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (
            context) => const LoginPage()));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: res.percentWidth(width),
            height: res.percentHeight(height),
            color: Colors.black.withOpacity(0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextDefault(content: tab == 'goal' ? 'goal_view.tbd_content1'.tr() : 'history_view.tbd_content1'.tr(), fontSize: 14, isBold: true),
                TextDefault(content: tab == 'goal' ? 'goal_view.tbd_content2'.tr() : 'history_view.tbd_content2'.tr(), fontSize: 14, isBold: true),
              ],
            ),
          ),
        ),
      )
    );
  }
}
