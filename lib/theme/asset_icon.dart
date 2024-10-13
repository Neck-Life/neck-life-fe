import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mocksum_flutter/util/responsive.dart';

class AssetIcon extends StatelessWidget {
  const AssetIcon(
      this.icon, {
        super.key,
        this.color,
        this.size,
      });

  final String icon;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return SvgPicture.asset(
      'assets/icons/$icon.svg',
      width: res.percentWidth(size ?? 30),
      height: res.percentWidth(size ?? 30),
      colorFilter: color != null ? ColorFilter.mode(
        color ?? Colors.black,
        BlendMode.srcIn,
      ) : null,
    );
  }
}
