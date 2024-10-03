import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';

class AirpodsModal extends StatelessWidget {
  final double? width;
  final bool isRotating;

  const AirpodsModal({
    super.key,
    required this.isRotating,
    this.width
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Container(
      width: res.percentWidth(width ?? 17.5),
      height: res.percentWidth(width ?? 17.5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          isRotating == true ? const CircularProgressIndicator(
            strokeWidth: 4,
            backgroundColor: Color(0xFFE2E2E2),
            color: Color(0xFF236EF3),
          ) : const SizedBox(),
          Center(
              child: Image.asset("assets/airpods.png", width: res.percentWidth(width == null ? 10 : (width! - 12.5)), fit: BoxFit.contain)
          ),
        ],
      ),
    );
  }

}