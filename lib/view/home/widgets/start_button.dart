import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';

import '../../../util/localization_string.dart';

class StartButton extends StatefulWidget {
  const StartButton({
    super.key,
    required this.onPressed,
    required this.isRunning,
    required this.isDisabled,
    required this.useTime,
  });

  /// 클릭 이벤트
  final void Function() onPressed;
  final bool isRunning;
  final bool isDisabled;
  final String useTime;
  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> {
  /// 버튼이 눌려있는지 여부
  bool isPressed = false;

  /// 버튼 클릭 이벤트
  void onPressed(bool newIsPressed) {
    if (isPressed == newIsPressed) return;
    setState(() {
      isPressed = newIsPressed;
    });
    if (isPressed) widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return GestureDetector(
      /// Click Event
      // onTapUp: (details) {
      //   onPressed(false);
      //   if (!widget.isDisabled) {
      //     widget.onPressed();
      //   }
      // },
      // onTapDown: (details) => onPressed(true),
      // onTapCancel: () => onPressed(false),
      onTap: () {
        widget.onPressed();
      },

      /// Container
      child: Container(
        width: res.percentWidth(80),
        decoration: BoxDecoration(
          color: widget.isDisabled ? const Color(0xFFCFCFD8) : (widget.isRunning ? Colors.white : const Color(0xFF236EF3)),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: res.percentHeight(1.5), horizontal: res.percentWidth(5)),
        child: widget.isRunning ? 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextDefault(
              content: widget.useTime,
              fontSize: 16,
              isBold: true,
              fontColor: const Color(0xFF236EF3),
            ),
            TextDefault(
              content: LS.tr('home_widgets.start_button.stop'),
              fontSize: 16,
              isBold: false,
              fontColor: Colors.black,
            )
          ],
        ) : TextDefault(
          content: LS.tr('home_widgets.start_button.start'),
          fontSize: 16,
          isBold: true,
          fontColor: Colors.white,
        ),
      ),
    );
  }
}
