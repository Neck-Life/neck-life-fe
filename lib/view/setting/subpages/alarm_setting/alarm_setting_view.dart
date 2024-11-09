import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/view/setting/subpages/alarm_setting/sound_setting_view.dart';
import 'package:mocksum_flutter/view/setting/subpages/alarm_setting/widgets/time_delay_tile.dart';
import 'package:provider/provider.dart';

import '../../../../theme/asset_icon.dart';
import '../../../../theme/component/text_default.dart';
import '../../../../util/localization_string.dart';

class AlarmSetting extends StatefulWidget {
  const AlarmSetting({super.key});

  @override
  State<StatefulWidget> createState() => _AlarmSettingState();
}

class _AlarmSettingState extends State<AlarmSetting> {

  double _sensitivity = 1;
  int _alarmGap = 5;
  bool _bgSoundActive = false;
  bool _pushNotiActive = true;
  double _volume = 0.4;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _sensitivity = Provider.of<DetectStatus>(context, listen: false).sensitivity.toDouble();
        _alarmGap = Provider.of<DetectStatus>(context, listen: false).alarmGap;
        _bgSoundActive = Provider.of<DetectStatus>(context, listen: false).bgSoundActive;
        _volume = Provider.of<DetectStatus>(context, listen: false).soundVolume;
        _pushNotiActive = Provider.of<DetectStatus>(context, listen: false).pushNotiAvtive;
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
              fontColor: const Color(0xFF64646F),
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
                      content: LS.tr('setting_subpages.alarm_setting.alarm_setting_view.alarm_sensitive_explain'),
                      fontSize: 13,
                      isBold: false,
                      fontColor: const Color(0xFF8991A0),
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
                          TextDefault(content: "setting_subpages.alarm_setting.alarm_setting_view.alarm_sensitive_low".tr(), fontSize: 13, isBold: false, fontColor: _sensitivity == 0 ? const Color(0xFF3077F4) : const Color(0xFF8991A0),),
                          TextDefault(content: "setting_subpages.alarm_setting.alarm_setting_view.alarm_sensitive_middle".tr(), fontSize: 13, isBold: false, fontColor: _sensitivity == 1 ? const Color(0xFF3077F4) : const Color(0xFF8991A0),),
                          TextDefault(content: "setting_subpages.alarm_setting.alarm_setting_view.alarm_sensitive_high".tr(), fontSize: 13, isBold: false, fontColor: _sensitivity == 2 ? const Color(0xFF3077F4) : const Color(0xFF8991A0),)
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
                    TextDefault(content: "setting_subpages.alarm_setting.alarm_setting_view.alarm_time".tr(), fontSize: 18, isBold: true),
                    SizedBox(height: res.percentHeight(0.5),),
                    TextDefault(
                      content: "setting_subpages.alarm_setting.alarm_setting_view.alarm_time_explain".tr(),
                      fontSize: 13,
                      isBold: false,
                      fontColor: const Color(0xFF8991A0),
                    ),
                    SizedBox(height: res.percentHeight(2),),
                    TimeDelayTile(alarmDelay: 1, chosenVal: _alarmGap, onChange: (int? value) => changeAlarmDelay(value, detectStatus)),
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
                padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
                radius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextDefault(content: "setting_subpages.alarm_setting.alarm_setting_view.sound_setting".tr(), fontSize: 18, isBold: true),
                    SizedBox(height: res.percentHeight(2),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextDefault(content: "setting_subpages.alarm_setting.alarm_setting_view.push_setting".tr(), fontSize: 16, isBold: false),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            value: _pushNotiActive,
                            activeColor: CupertinoColors.activeBlue,
                            onChanged: (bool? value) {
                              setState(() {
                                _pushNotiActive = value ?? false;
                                detectStatus.setPushNotiActive(_pushNotiActive);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextDefault(content: "setting_subpages.alarm_setting.alarm_setting_view.sound_alarm_turn_on".tr(), fontSize: 16, isBold: false),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            value: _bgSoundActive,
                            activeColor: CupertinoColors.activeBlue,
                            onChanged: (bool? value) {
                              setState(() {
                                _bgSoundActive = value ?? false;
                                detectStatus.setBgSoundActive(_bgSoundActive);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: res.percentHeight(1)),
                    TextDefault(content: "setting_subpages.alarm_setting.alarm_setting_view.volume_setting".tr(), fontSize: 16, isBold: false),
                    SizedBox(height: res.percentHeight(2)),
                    SliderTheme(
                      data: SliderThemeData(
                          activeTrackColor: const Color(0xFF3077F4),
                          inactiveTrackColor: const Color(0xFFE5E5EB),
                          thumbColor: const Color(0xFF3077F4),
                          overlayShape: SliderComponentShape.noOverlay
                      ),
                      child: Slider(
                          value: _volume,
                          max: 1,
                          onChanged: (double? value) {
                            setState(() {
                              _volume = value!;
                            });
                          },
                        onChangeEnd: (double? value) {
                          setState(() {
                            _volume = value!;
                            Provider.of<DetectStatus>(context, listen: false).setSoundVolume(_volume);
                          });
                        },
                      ),
                    ),
                    SizedBox(height: res.percentHeight(2),),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (
                            context) => const SoundSetting()));
                      },
                      child: Container(
                        width: res.percentWidth(80),
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            TextDefault(content: "setting_subpages.alarm_setting.alarm_setting_view.change_sound".tr(), fontSize: 16, isBold: false),
                            SizedBox(width: res.percentWidth(2),),
                            AssetIcon('arrowNext', size: res.percentWidth(1),)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: res.percentHeight(5),)
            ],
          ),
        ),
      ),
    );
  }
}