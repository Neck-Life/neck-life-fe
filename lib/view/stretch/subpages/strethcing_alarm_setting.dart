import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/main.dart';
import 'package:mocksum_flutter/theme/asset_icon.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:provider/provider.dart';

import '../../../../theme/component/text_default.dart';
import '../../../service/stretching_timer.dart';
import '../../../util/localization_string.dart';
import '../data/stretching_data.dart';
import '../models/stretching_action.dart';


class StretchingAlarmSetting extends StatefulWidget {
  const StretchingAlarmSetting({super.key});

  @override
  State<StatefulWidget> createState() => _StretchingAlarmSettingState();
}


class _StretchingAlarmSettingState extends State<StretchingAlarmSetting> {
  double _selectedIntervalIndex = 2;
  int _selectedStretchingIndex = 0;
  List<StretchingGroup> stretchingGroupList = [];
  StretchingGroup? selectedStretchingGroup; // 상태 변수로 선언
  bool _stretchingSetted = false;

  @override
  void initState() {
    super.initState();

    getStretchingInfoFromStorage();
    Future.delayed(Duration.zero, () async {
      Provider.of<StretchingTimer>(context, listen: false).setStretchingLan(context.locale.languageCode);
      // Provider.of<StretchingTimer>(context, listen: false).init();
      // setState(() {
      //   stretchingGroupList = StretchingData.init(context.locale.languageCode);
      //   _selectedIntervalIndex = Provider.of<StretchingTimer>(context, listen: false).selectedIntervalIndex.toDouble();
      //   _stretchingSetted = _selectedIntervalIndex != 0;
      //   _selectedIntervalIndex -= 1;
      //   _selectedStretchingIndex = Provider.of<StretchingTimer>(context, listen: false).selectedStretchingIndex;
      //   selectedStretchingGroup = stretchingGroupList[_selectedStretchingIndex];
      // });
    });
  }

  Future<void> getStretchingInfoFromStorage() async {
    const storage = FlutterSecureStorage();
    String? selectedIntervalIndexStorage = await storage.read(key: 'selectedIntervalIndex');
    String? selectedStretchingIndexStorage = await storage.read(key: 'selectedStretchingIndex');

    setState(() {
      if (selectedIntervalIndexStorage != null) {
        _selectedIntervalIndex = double.parse(selectedIntervalIndexStorage);
      }
      if (selectedStretchingIndexStorage != null) {
        _selectedStretchingIndex = int.parse(selectedStretchingIndexStorage);
      }
      _stretchingSetted = _selectedIntervalIndex != 0;
      // _selectedIntervalIndex -= 1;
      // print
      stretchingGroupList = StretchingData.init(context.locale.languageCode);
      selectedStretchingGroup = stretchingGroupList[_selectedStretchingIndex];
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextDefault(
                        content: LS.tr('stretching.stretching_alarm.use_reminder'),
                        fontSize: 15,
                        isBold: false,
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: _stretchingSetted,
                          activeColor: CupertinoColors.activeBlue,
                          onChanged: (bool value) {
                            setState(() {
                              _stretchingSetted = value;
                              stretchingTimer.setStretchingIntervalIndex(value ? 2 : 0);
                              _selectedIntervalIndex = value ? 1 : 0;
                              // StretchingTimer.isStretchingMode = false;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: res.percentHeight(2),),
                  Stack(
                    children: [
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: const Color(0xFF3077F4),
                              inactiveTrackColor: const Color(0xFFE5E5EB),
                              thumbColor: const Color(0xFF3077F4),
                              trackHeight: 8.0,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: _selectedIntervalIndex-1 < 0 ? 0 : _selectedIntervalIndex-1,
                              max: 2,
                              divisions: 2,
                              onChanged: (double? value) {
                                setState(() {
                                  _selectedIntervalIndex = value!+1;
                                  stretchingTimer.setStretchingIntervalIndex(value.toInt()+1);
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
                                // TextDefault(content: LS.tr('stretching.stretching_alarm.stretching_interval_disabled'), fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 0 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
                                TextDefault(content: LS.tr('stretching.stretching_alarm.stretching_interval_10m'), fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 1 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
                                TextDefault(content: LS.tr('stretching.stretching_alarm.stretching_interval_30m'), fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 2 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
                                TextDefault(content: LS.tr('stretching.stretching_alarm.stretching_interval_50m'), fontSize: 14, isBold: false, fontColor: _selectedIntervalIndex == 3 ? const Color(0xFF3077F4) : const Color(0xFF8991A0)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      !_stretchingSetted ? Container(
                        width: res.percentWidth(85),
                        height: res.percentHeight(5),
                        color: const Color(0xAAFFFFFF),
                      ) : const SizedBox()
                    ],
                  )
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
                          borderRadius: BorderRadius.circular(15),
                          value: _selectedStretchingIndex,
                          // padding: EdgeInsets.symmetric(horizontal: res.percentWidth(2)),
                          icon: AssetIcon('arrowDown', size: res.percentWidth(1),),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.blue),
                          underline: Container(
                            height: 2,
                            color: Colors.blueAccent,
                          ),
                          onChanged: (int? newIndex) {
                            setState(() {
                              _selectedStretchingIndex = newIndex!;
                              selectedStretchingGroup = stretchingTimer.stretchingList[_selectedStretchingIndex];
                              stretchingTimer.setStretchingTypeIndex(_selectedStretchingIndex);
                            });
                          },
                          items: List.generate(stretchingTimer.stretchingList.length, (index) {
                            return DropdownMenuItem<int>(
                              value: index,
                              child: TextDefault(
                                content: stretchingTimer.stretchingList[index].groupName,
                                fontSize: 16,
                                isBold: false,
                              ),
                            );
                          }),
                        )

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
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AssetIcon('info', size: res.percentWidth(1,)),
                      const SizedBox(width: 8),
                      TextDefault(
                        content: LS.tr('stretching.stretching_alarm.why_stretch'),
                        fontSize: 15,
                        isBold: true,
                      ),
                    ],
                  ),
                  SizedBox(height: res.percentHeight(1),),
                  TextDefault(
                    content: LS.tr('stretching.stretching_alarm.why_stretch_description'),
                    fontSize: 14,
                    isBold: false,
                    fontColor: const Color(0xFF8991A0),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}