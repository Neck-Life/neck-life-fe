
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/theme/component/button.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:provider/provider.dart';

import '../../../service/history_provider.dart';

class FeedbackPopUp extends StatefulWidget {
  const FeedbackPopUp({
    super.key,
    required this.onError,
    required this.onSuccess,
    required this.pagePop
  });

  final void Function() onError;
  final void Function() onSuccess;
  final void Function() pagePop;

  @override
  State<StatefulWidget> createState() => _FeedbackPopupState();

}

class _FeedbackPopupState extends State<FeedbackPopUp> {

  final _feedbackEditController = TextEditingController();
  bool _hasText = false;


  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return SingleChildScrollView(
      child: Container(
        width: res.deviceWidth,
        height: 370,
        // margin: EdgeInsets.only(bottom: res.percentHeight(5)),
        // padding: MediaQuery.of(context).viewInsets,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F7),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextDefault(
                      content: '문의 또는 피드백을 전달해주세요',
                      fontSize: 20,
                      isBold: true,
                      fontColor: Color(0xFF323238)
                  ),
                  SizedBox(height: res.percentHeight(1),),
                  Padding(
                    padding: EdgeInsets.all(res.percentWidth(1)),
                    child: TextField(
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E5EB),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(15)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E5EB),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(15)
                          )
                      ),
                      onChanged: (text) {
                        if (text != '') {
                          setState(() {
                            _hasText = true;
                          });
                        } else {
                          setState(() {
                            _hasText = false;
                          });
                        }
                      },
                      controller: _feedbackEditController,
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: res.percentHeight(1),),
            Container(
              padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: res.percentWidth(43),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8991A0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: res.percentWidth(4),),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextDefault(
                            content: '그만할래요',
                            fontSize: 16,
                            isBold: true,
                            fontColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Button(
                    onPressed: () async {
                      if (_feedbackEditController.text == '') return;
                      bool success = await HistoryStatus.sendFeedback(_feedbackEditController.text);
                      if (success) {
                        widget.onSuccess();
                      } else {
                        widget.onError();
                      }
                    },
                    text: '피드백 보내기',
                    backgroundColor: !_hasText ? const Color(0xFFCFCFD8): const Color(0xFF236EF3),
                    color: Colors.white,
                    width: res.percentWidth(43),
                    padding: res.percentWidth(4),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}