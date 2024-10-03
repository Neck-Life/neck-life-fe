import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';


class PageIdxTile extends StatelessWidget {
  final bool isNowTap;

  const PageIdxTile({
    super.key,
    required this.isNowTap
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Container(
      width: res.percentWidth(28),
      height: 5,
      margin: EdgeInsets.symmetric(horizontal: res.percentWidth(0.5)),
      decoration: BoxDecoration(
          color: isNowTap ? const Color(0xFF236EF3) : const Color(0xFFCFCFD8),
        borderRadius: BorderRadius.circular(10)
      ),
    );
  }

}