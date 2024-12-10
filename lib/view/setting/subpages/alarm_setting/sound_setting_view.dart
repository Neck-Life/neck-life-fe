import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/view/setting/subpages/alarm_setting/widgets/time_delay_tile.dart';
import 'package:provider/provider.dart';

import '../../../../theme/asset_icon.dart';
import '../../../../theme/component/text_default.dart';
import '../../../../util/localization_string.dart';


class SoundSetting extends StatefulWidget {
  const SoundSetting({super.key});

  @override
  State<StatefulWidget> createState() => _SoundSettingState();
}

class _SoundSettingState extends State<SoundSetting> {

  String _soundFileName = 'noti.mp3';
  final List<String> _soundfileNameList = ['noti.mp3', 'noti2.mp3', 'noti3.mp3', 'noti4.mp3', 'noti5.mp3', 'noti6.mp3'];

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _soundFileName = Provider.of<DetectStatus>(context, listen: false).soundFileName;
      });
    });
  }


  // void changeAlarmDelay(int? value, DetectStatus detectStatus) {
  //   setState(() {
  //     _alarmGap = value!;
  //   });
  //   detectStatus.setAlarmGap(_alarmGap);
  // }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    DetectStatus detectStatus = Provider.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
            backgroundColor: const Color(0xFFF4F4F7),
            title: TextDefault(
              content: 'setting_subpages.alarm_setting.alarm_setting_view.change_sound_setting'.tr(),
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
                    TextDefault(content: 'setting_subpages.alarm_setting.alarm_setting_view.change_sound_setting'.tr(), fontSize: 18, isBold: true),
                    SizedBox(height: res.percentHeight(0.5),),
                    TextDefault(
                      content: 'setting_subpages.alarm_setting.alarm_setting_view.change_desc'.tr(),
                      fontSize: 13,
                      isBold: false,
                      fontColor: const Color(0xFF8991A0),
                    ),
                    detectStatus.nowDetecting ? TextDefault(
                      content: 'setting_subpages.alarm_setting.alarm_setting_view.change_noti.'.tr(),
                      fontSize: 13,
                      isBold: false,
                    ) : const SizedBox(),
                    Stack(
                      children: [
                        Column(
                          children: List.generate(_soundfileNameList.length, (idx) {
                            return GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _soundFileName = _soundfileNameList[idx];
                                });
                                detectStatus.setSoundFileName(_soundFileName);
                                await player.stop();
                                await player.setUrl('asset:///assets/${_soundfileNameList[idx]}');
                                await player.setClip(start: const Duration(seconds: 0), end: const Duration(seconds: 3));
                                await player.play();
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: res.percentHeight(2)),
                                padding: EdgeInsets.symmetric(horizontal: res.percentWidth(3), vertical: res.percentHeight(1.5)),
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: _soundFileName == _soundfileNameList[idx] ? const Color(0xFF236EF3) : const Color(0xFFF4F4F7)
                                    )
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextDefault(content: idx == 0 ? 'setting_subpages.alarm_setting.alarm_setting_view.default'.tr() : '${'setting_subpages.alarm_setting.alarm_setting_view.sound'.tr()}$idx', fontSize: 14, isBold: false),
                                    _soundFileName == _soundfileNameList[idx] ?
                                    AssetIcon('check', size: res.percentWidth(1), color: const Color(0xFF236EF3),) :
                                    const SizedBox()
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                        detectStatus.nowDetecting ? Container(
                          width: res.percentWidth(85),
                          height: res.percentHeight(45),
                          color: const Color(0xAAFFFFFF),
                        ) : const SizedBox()
                      ],
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