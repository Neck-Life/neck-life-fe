import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';

import '../asset_icon.dart';




class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.onPressed,
    this.text,
    this.icon,
    this.color,
    this.backgroundColor,
    this.width,
    this.isBorder,
    this.padding,
    this.borderColor,
    bool? isInactive,
  }) : isInactive = isInactive ?? false;

  /// 클릭 이벤트
  final void Function() onPressed;

  final bool isInactive;
  final String? text;
  final String? icon;
  final double? width;
  final Color? color;
  final Color? backgroundColor;
  final bool? isBorder;
  final double? padding;
  final Color? borderColor;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  /// 버튼이 눌려있는지 여부
  bool isPressed = false;


  /// 버튼 클릭 이벤트
  void onPressed(bool newIsPressed) {
    if (isPressed == newIsPressed) return;
    setState(() {
      isPressed = newIsPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    
    return GestureDetector(
      /// Click Event
      onTapUp: (details) {
        onPressed(false);
        if (!widget.isInactive) {
          widget.onPressed();
        }
      },
      onTapDown: (details) => onPressed(true),
      onTapCancel: () => onPressed(false),

      /// Container
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(13),
          border: widget.isBorder == true ? Border.all(
            width: 1,
            color: widget.borderColor ?? const Color(0xFF323238)
          ) : null,
        ),
        padding: EdgeInsets.symmetric(vertical: widget.padding!, horizontal: res.percentWidth(5)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: widget.icon != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
          children: [
            /// Icon
            if (widget.icon != null)
              AssetIcon(
                widget.icon!,
                color: widget.color ?? Colors.black,
                size: 8,
              ),

            /// Gap
            // if (widget.icon != null && widget.text != null)
            //   const SizedBox(width: 8),

            /// Text
            if (widget.text != null)
              TextDefault(
                content: widget.text!,
                fontSize: 16,
                isBold: true,
                fontColor: widget.color,
              ),

            if (widget.icon != null)
              SizedBox(
                width: res.percentWidth(8),
              ),
          ],
        ),
      ),
    );
  }
}
