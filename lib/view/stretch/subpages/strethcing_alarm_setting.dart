import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:provider/provider.dart';

import '../../../../theme/component/text_default.dart';
import '../../../service/stretching_timer.dart';
import '../../../util/localization_string.dart';
import '../data/stretching_data.dart';
import '../models/stretching_action.dart';


StretchingGroup selectedStretchingGroup = stretchingGroups[0]; // 상태 변수로 선언


class StretchingAlarmSetting extends StatefulWidget {
  const StretchingAlarmSetting({super.key});

  @override
  State<StatefulWidget> createState() => _StretchingAlarmSettingState();
}
class _StretchingAlarmSettingState extends State<StretchingAlarmSetting> {
  double _selectedIntervalIndex = 2;
  int _selectedStretchingIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _selectedIntervalIndex = Provider.of<StretchingTimer>(context, listen: false).selectedIntervalIndex.toDouble();
        _selectedStretchingIndex = Provider.of<StretchingTimer>(context, listen: false).selectedStretchingIndex;
        selectedStretchingGroup = stretchingGroups[_selectedStretchingIndex];
      });
    });
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
                  TextDefault(content: LS.tr('stretching.stretching_alarm.stretching_alarm_setting'), fontSize: 18, isBold: true),
                  SizedBox(height: res.percentHeight(0.5)),
                  TextDefault(
                    content: LS.tr('stretching.stretching_alarm.stretching_alarm_description'),
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
                        TextDefault(content: LS.tr('stretching.stretching_alarm.stretching_interval_disabled'), fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 0 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
                        TextDefault(content: LS.tr('stretching.stretching_alarm.stretching_interval_10m'), fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 1 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
                        TextDefault(content: LS.tr('stretching.stretching_alarm.stretching_interval_30m'), fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 2 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
                        TextDefault(content: LS.tr('stretching.stretching_alarm.stretching_interval_50m'), fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 3 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
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
                          content: LS.tr('stretching.stretching_alarm.stretching_selection'),
                          fontSize: 18,
                          isBold: true,
                        ),
                        SizedBox(height: res.percentHeight(0.5)),
                        TextDefault(
                          content: LS.tr('stretching.stretching_alarm.stretching_selection_description'),
                          fontSize: 14,
                          isBold: false,
                          fontColor: const Color(0xFF8991A0),
                        ),
                        DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedStretchingIndex,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.blue),
                          underline: Container(
                            height: 2,
                            color: Colors.blueAccent,
                          ),
                          onChanged: (int? newIndex) {
                            setState(() {
                              _selectedStretchingIndex = newIndex!;
                              selectedStretchingGroup = stretchingGroups[_selectedStretchingIndex];
                              stretchingTimer.setStretchingTypeIndex(_selectedStretchingIndex);

                            });
                          },
                          items: List.generate(stretchingGroups.length, (index) {
                            return DropdownMenuItem<int>(
                              value: index,
                              child: TextDefault(
                                content: stretchingGroups[index].groupName,
                                fontSize: 16,
                                isBold: false,
                              ),
                            );
                          }),
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
                          content: LS.tr('stretching.stretching_alarm.why_stretch'),
                          fontSize: 18,
                          isBold: true,
                        ),
                        SizedBox(height: res.percentHeight(0.5)),
                        TextDefault(
                          content: LS.tr('stretching.stretching_alarm.why_stretch_description'),
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