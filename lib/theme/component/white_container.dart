import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';

class WhiteContainer extends StatelessWidget {

  const WhiteContainer({
    super.key,
    this.width,
    this.height,
    this.child,
    this.padding,
    this.margin,
    this.radius
  });

  final double? width;
  final double? height;
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Container(
      width: res.percentWidth(width ?? 85),
      height: height == null ? null : res.percentWidth(height!),
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius == null ? BorderRadius.circular(10) : BorderRadius.circular(radius!),
        border: Border.all(
          width: 1,
          color: const Color(0xFFE5E5EB)
        )
      ),
      child: child
    );
  }

}