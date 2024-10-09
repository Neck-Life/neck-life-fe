import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/view/setting/subpages/alarm_setting/widgets/time_delay_tile.dart';
import 'package:provider/provider.dart';

import '../../../../theme/asset_icon.dart';
import '../../../../theme/component/text_default.dart';

class AlarmSetting extends StatefulWidget {
  const AlarmSetting({super.key});

  @override
  State<StatefulWidget> createState() => _AlarmSettingState();
}

class _AlarmSettingState extends State<AlarmSetting> {

  double _sensitivity = 1;
  int _alarmGap = 5;
  bool _bgSoundActive = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _sensitivity = Provider.of<DetectStatus>(context, listen: false).sensitivity.toDouble();
        _alarmGap = Provider.of<DetectStatus>(context, listen: false).alarmGap;
        _bgSoundActive = Provider.of<DetectStatus>(context, listen: false).bgSoundActive;
      });
    });
  }

  void changeAlarmDelay(int? value, DetectStatus detectStatus) {
    setState(() {
      _alarmGap = value!;
    });
    detectStatus.setAlarmGap(_alarmGap);
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    DetectStatus detectStatus = Provider.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
            backgroundColor: const Color(0xFFF4F4F7),
            title:TextDefault(
              content: 'setting_subpages.alarm_setting.alarm_setting_view.alarm_setting'.tr(),
              fontSize: 16,
              isBold: false,
              fontColor: Color(0xFF64646F),
            ),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const AssetIcon('arrowBack', color: Color(0xFF8991A0), size: 6,)
            )
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: res.deviceWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: res.percentHeight(2)),
              WhiteContainer(
                // margin: EdgeInsets.only(left: res.percentWidth(5)),
                width: 87.5,
                padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
                radius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextDefault(content:  'setting_subpages.alarm_setting.alarm_setting_view.alarm_sensitive'.tr(), fontSize: 18, isBold: true),
                    SizedBox(height: res.percentHeight(0.5),),
                     TextDefault(
                      content: 'setting_subpages.alarm_setting.alarm_setting_view.alarm_sensitive_explain'.tr(),
                      fontSize: 13,
                      isBold: false,
                      fontColor: Color(0xFF8991A0),
                    ),
                    SizedBox(height: res.percentHeight(2),),
                    SliderTheme(
                      data: SliderThemeData(
                          activeTrackColor: const Color(0xFF3077F4),
                          inactiveTrackColor: const Color(0xFFE5E5EB),
                          thumbColor: const Color(0xFF3077F4),
                          overlayShape: SliderComponentShape.noOverlay
                      ),
                      child: Slider(
                          value: _sensitivity,
                          max: 2,
                          divisions: 2,
                          onChanged: (double? value) {
                            setState(() {
                              _sensitivity = value!;
                              detectStatus.setSensitivity(value);
                            });
                          }
                      ),
                    ),
                    SizedBox(height: res.percentHeight(1),),
                    SizedBox(
                      width: res.percentWidth(85),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextDefault(content: "setting_subpages.alarm_setting.alarm_sensitive_low".tr(), fontSize: 13, isBold: false, fontColor: _sensitivity == 0 ? const Color(0xFF3077F4) : const Color(0xFF8991A0),),
                          TextDefault(content: "setting_subpages.alarm_setting.alarm_sensitive_middle".tr(), fontSize: 13, isBold: false, fontColor: _sensitivity == 1 ? const Color(0xFF3077F4) : const Color(0xFF8991A0),),
                          TextDefault(content: "setting_subpages.alarm_setting.alarm_sensitive_high".tr(), fontSize: 13, isBold: false, fontColor: _sensitivity == 2 ? const Color(0xFF3077F4) : const Color(0xFF8991A0),)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: res.percentHeight(2)),
              WhiteContainer(
                width: 87.5,
                padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
                radius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextDefault(content: "setting_subpages.alarm_setting.alarm_time".tr(), fontSize: 18, isBold: true),
                    SizedBox(height: res.percentHeight(0.5),),
                    TextDefault(
                      content: "setting_subpages.alarm_setting.alarm_time_explain".tr(),
                      fontSize: 13,
                      isBold: false,
                      fontColor: Color(0xFF8991A0),
                    ),
                    SizedBox(height: res.percentHeight(2),),
                    TimeDelayTile(alarmDelay: 5, chosenVal: _alarmGap, onChange: (int? value) => changeAlarmDelay(value, detectStatus)),
                    TimeDelayTile(alarmDelay: 10, chosenVal: _alarmGap,onChange: (int? value) => changeAlarmDelay(value, detectStatus)),
                    TimeDelayTile(alarmDelay: 15, chosenVal: _alarmGap,onChange: (int? value) => changeAlarmDelay(value, detectStatus)),
                    TimeDelayTile(alarmDelay: 20, chosenVal: _alarmGap,onChange: (int? value) => changeAlarmDelay(value, detectStatus)),
                    TimeDelayTile(alarmDelay: 30, chosenVal: _alarmGap,onChange: (int? value) => changeAlarmDelay(value, detectStatus)),
                    SizedBox(height: res.percentHeight(1),),
                  ],
                ),
              ),
              SizedBox(height: res.percentHeight(2)),
              WhiteContainer(
                width: 87.5,
                padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(1.5)),
                radius: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextDefault(content: "setting_subpages.alarm_setting.sound_alarm_turn_on".tr(), fontSize: 18, isBold: false),
                    CupertinoSwitch(
                      value: _bgSoundActive,
                      activeColor: CupertinoColors.activeBlue,
                      onChanged: (bool? value) {
                        setState(() {
                          _bgSoundActive = value ?? false;
                          detectStatus.setBgSoundActive(_bgSoundActive);
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Container(
              //   width: res.percentWidth(85),
              //   margin: EdgeInsets.only(bottom: 10, left: res.percentWidth(7.5)),
              //   child: Text('알림 기준 시간 설정',
              //     style: TextStyle(
              //       color: const Color(0xFF434343),
              //       fontSize: res.fontSize(18),
              //       fontFamily: 'Inter',
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
              // Column(
              //   children: [
              //     Container(
              //       width: res.percentWidth(85),
              //       margin: const EdgeInsets.only(
              //           bottom: 10),
              //       child: Text('잘못된 자세를 얼마나 유지했을 때 알림을 받을지 설정할 수 있어요.',
              //         style: TextStyle(
              //           color: const Color(0xFF434343),
              //           fontSize: res.fontSize(14),
              //           fontFamily: 'Inter',
              //           fontWeight: FontWeight.w300,
              //         ),
              //       ),
              //     ),
              //     Container(
              //         width: res.percentWidth(95),
              //         margin: EdgeInsets.only(left: res.percentWidth(2.5)),
              //         decoration: ShapeDecoration(
              //           color: Colors.white,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(20),
              //           ),
              //         ),
              //         child: Column(
              //           children: [
              //             ListTile(
              //               title: Text('5초',
              //                 style: TextStyle(
              //                   color: const Color(0xFF434343),
              //                   fontSize: res.fontSize(14),
              //                   fontFamily: 'Inter',
              //                   fontWeight: FontWeight.w300,
              //                 ),
              //               ),
              //               leading: Radio(
              //                 value: 5,
              //                 groupValue: _alarmGap,
              //                 onChanged: (int? value) {
              //                   setState(() {
              //                     _alarmGap = value!;
              //                   });
              //                   detectStatus.setAlarmGap(_alarmGap);
              //                 },
              //               ),
              //             ),
              //             ListTile(
              //               title: Text('15초',
              //                 style: TextStyle(
              //                   color: const Color(0xFF434343),
              //                   fontSize: res.fontSize(14),
              //                   fontFamily: 'Inter',
              //                   fontWeight: FontWeight.w300,
              //                 ),
              //               ),
              //               leading: Radio(
              //                 value: 15,
              //                 groupValue: _alarmGap,
              //                 onChanged: (int? value) {
              //                   setState(() {
              //                     _alarmGap = value!;
              //                   });
              //                   detectStatus.setAlarmGap(_alarmGap);
              //                 },
              //               ),
              //             ),
              //             ListTile(
              //               title: Text('30초',
              //                 style: TextStyle(
              //                   color: const Color(0xFF434343),
              //                   fontSize: res.fontSize(14),
              //                   fontFamily: 'Inter',
              //                   fontWeight: FontWeight.w300,
              //                 ),
              //               ),
              //               leading: Radio(
              //                 value: 30,
              //                 groupValue: _alarmGap,
              //                 onChanged: (int? value) {
              //                   setState(() {
              //                     _alarmGap = value!;
              //                   });
              //                   detectStatus.setAlarmGap(_alarmGap);
              //                 },
              //               ),
              //             ),
              //             ListTile(
              //               title: Text('1분',
              //                 style: TextStyle(
              //                   color: const Color(0xFF434343),
              //                   fontSize: res.fontSize(14),
              //                   fontFamily: 'Inter',
              //                   fontWeight: FontWeight.w300,
              //                 ),
              //               ),
              //               leading: Radio(
              //                 value: 60,
              //                 groupValue: _alarmGap,
              //                 onChanged: (int? value) {
              //                   setState(() {
              //                     _alarmGap = value!;
              //                   });
              //                   detectStatus.setAlarmGap(_alarmGap);
              //                 },
              //               ),
              //             ),
              //             ListTile(
              //               title: Text('5분',
              //                 style: TextStyle(
              //                   color: const Color(0xFF434343),
              //                   fontSize: res.fontSize(14),
              //                   fontFamily: 'Inter',
              //                   fontWeight: FontWeight.w300,
              //                 ),
              //               ),
              //               leading: Radio(
              //                 value: 300,
              //                 groupValue: _alarmGap,
              //                 onChanged: (int? value) {
              //                   setState(() {
              //                     _alarmGap = value!;
              //                   });
              //                   detectStatus.setAlarmGap(_alarmGap);
              //                 },
              //               ),
              //             )
              //           ],
              //         )
              //     ),
              //   ],
              // ),
              // SizedBox(height: res.percentHeight(7)),
              // Container(
              //   width: res.percentWidth(85),
              //   margin: EdgeInsets.only(bottom: 10, left: res.percentWidth(7.5)),
              //   child: Text('소리 설정',
              //     style: TextStyle(
              //       color: const Color(0xFF434343),
              //       fontSize: res.fontSize(18),
              //       fontFamily: 'Inter',
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
              // Column(
              //   children: [
              //     Container(
              //       width: res.percentWidth(85),
              //       margin: const EdgeInsets.only(
              //           bottom: 10),
              //       child: Text('거북목 탐지 시 알람 소리를 내줘요\n이 설정은 변경 후에 탐지를 중지 후 다시 시작해주세요.',
              //         style: TextStyle(
              //           color: const Color(0xFF434343),
              //           fontSize: res.fontSize(14),
              //           fontFamily: 'Inter',
              //           fontWeight: FontWeight.w300,
              //         ),
              //       ),
              //     ),
              //     Container(
              //         width: res.percentWidth(95),
              //         margin: EdgeInsets.only(left: res.percentWidth(2.5)),
              //         padding: EdgeInsets.only(left: res.percentWidth(7.5), top: res.percentHeight(0.75), bottom: res.percentHeight(0.75), right: res.percentWidth(5)),
              //         decoration: ShapeDecoration(
              //           color: Colors.white,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(20),
              //           ),
              //         ),
              //         child:
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}