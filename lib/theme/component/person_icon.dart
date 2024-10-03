import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';

class PersonIcon extends StatelessWidget {
  final double? size;

  const PersonIcon({
    super.key,
    this.size
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size == null ? res.percentWidth(7.5) : res.percentWidth(size!)/2),
      child: Container(
        width: size == null ? res.percentWidth(15) : res.percentWidth(size!),
        height: size == null ? res.percentWidth(15) : res.percentWidth(size!),
        padding: EdgeInsets.only(top: res.percentHeight(2)),
        decoration: const BoxDecoration(
          color: Colors.white
        ),
        child: Image.asset('assets/person.png', width: size == null ? res.percentWidth(10) : res.percentWidth(size!), fit: BoxFit.contain,),
      ),
    );
  }

}