import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:provider/provider.dart';

import '../../../../theme/component/text_default.dart';
import '../../../service/stretching_timer.dart';
import '../data/stretching_data.dart';
import '../models/stretching_action.dart';


StretchingGroup selectedStretchingGroup = stretchingGroups[0]; // 상태 변수로 선언


class StretchingAlarmSetting extends StatefulWidget {
  const StretchingAlarmSetting({super.key});

  @override
  State<StatefulWidget> createState() => _StretchingAlarmSettingState();
}
class _StretchingAlarmSettingState extends State<StretchingAlarmSetting> {
  late double _selectedIntervalIndex;

  @override
  void initState() {
    super.initState();
    _selectedIntervalIndex = Provider.of<StretchingTimer>(context, listen: false).selectedIntervalIndex.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    StretchingTimer stretchingTimer = Provider.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: res.deviceWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: res.percentHeight(2)),
            WhiteContainer(
              width: 87.5,
              padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(3.5)),
              radius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextDefault(content: '스트레칭 알람 주기 설정', fontSize: 18, isBold: true),
                  SizedBox(height: res.percentHeight(0.5)),
                  TextDefault(
                    content: '자세탐지 도중 스트레칭 알람 주기를 설정할 수 있어요',
                    fontSize: 14,
                    isBold: false,
                    fontColor: const Color(0xFF8991A0),
                  ),
                  SizedBox(height: res.percentHeight(2)),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF3077F4),
                      inactiveTrackColor: const Color(0xFFE5E5EB),
                      thumbColor: const Color(0xFF3077F4),
                      trackHeight: 8.0,
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: _selectedIntervalIndex,
                      max: 3,
                      divisions: 3,
                      onChanged: (double? value) {
                        setState(() {
                          _selectedIntervalIndex = value!;
                          stretchingTimer.setStretchingIntervalIndex(value.toInt());
                        });
                      },
                    ),
                  ),
                  SizedBox(height: res.percentHeight(1)),
                  SizedBox(
                    width: res.percentWidth(85),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextDefault(content: '10초', fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 0 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
                        TextDefault(content: '10분', fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 1 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
                        TextDefault(content: '30분', fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 2 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
                        TextDefault(content: '50분', fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 3 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: res.percentHeight(2)),
            // 드롭다운 메뉴 추가
            WhiteContainer(
              width: 87.5,
              padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
              radius: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: res.percentWidth(1)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: res.percentHeight(1)),
                        TextDefault(
                          content: '스트레칭 선택',
                          fontSize: 18,
                          isBold: true,
                        ),
                        SizedBox(height: res.percentHeight(0.5)),
                        TextDefault(
                          content: '선택한 스트레칭으로 가이드해 드릴게요',
                          fontSize: 14,
                          isBold: false,
                          fontColor: const Color(0xFF8991A0),
                        ),
                        DropdownButton<StretchingGroup>(
                          isExpanded: true, // DropdownButton이 전체 너비를 사용하도록 설정
                          value: selectedStretchingGroup,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.blue),
                          underline: Container(
                            height: 2,
                            color: Colors.blueAccent,
                          ),
                          onChanged: (StretchingGroup? newValue) {
                            setState(() {
                              selectedStretchingGroup = newValue!;
                            });
                          },
                          items: stretchingGroups
                              .map<DropdownMenuItem<StretchingGroup>>((StretchingGroup group) {
                            return DropdownMenuItem<StretchingGroup>(
                              value: group,
                              child: TextDefault(content: group.groupName, fontSize: 16, isBold: false),
                            );
                          }).toList(),
                        ),

                      ],
                    ),
                  ),
                  // SvgPicture.asset('assets/icons/Document.svg'),
                  SizedBox(width: res.percentWidth(1),)
                ],
              ),
            ),
            SizedBox(height: res.percentHeight(2)),
            WhiteContainer(
              width: 87.5,
              padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
              radius: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset('assets/icons/info.svg'),
                  SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextDefault(
                          content: '스트레칭을 왜 해야하나요?',
                          fontSize: 18,
                          isBold: true,
                        ),
                        SizedBox(height: res.percentHeight(0.5)),
                        TextDefault(
                          content: '규칙적인 스트레칭은 근육 피로를 평균 60% 줄이고 혈액 순환을 30% 개선합니다.\n거북목을 예방하고 신체 유연성도 높일 수 있답니다!',
                          fontSize: 14,
                          isBold: false,
                          fontColor: const Color(0xFF8991A0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}