
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/button.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';

class CustomPopUp extends StatelessWidget {
  final String text;
  final String? btnText;
  final void Function()? onClick;

  const CustomPopUp({
    super.key,
    required this.text,
    this.btnText,
    this.onClick
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      content: Container(
        margin: EdgeInsets.only(top: res.percentHeight(0.5)),
        child: TextDefault(content: text, fontSize: 16, isBold: false),
      ),
      actions: [
        Center(
          child: Button(
            onPressed: () {
              if (onClick == null) {
                Navigator.of(context).pop();
              } else {
                onClick!();
              }
            },
            text: '확인',
            backgroundColor: const Color(0xFF236EF3),
            color: Colors.white,
            width: res.percentWidth(55),
            padding: res.percentWidth(3),
          ),
        )
      ],
    );
  }

}