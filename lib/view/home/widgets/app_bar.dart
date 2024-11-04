import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';

class HomeAppBar extends StatelessWidget {

  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: res.percentWidth(7.5), top: res.percentHeight(5)),
      child: Image.asset(
        'assets/logowithname.png',
        // width: res.percentWidth(size ?? 30),
        height: res.percentWidth(8.5),
      )
    );
  }

}