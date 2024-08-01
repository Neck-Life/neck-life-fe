import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/util/status_provider.dart';
import 'package:provider/provider.dart';

class AlarmSetting extends StatefulWidget {
  const AlarmSetting({super.key});

  @override
  State<StatefulWidget> createState() => _AlarmSettingState();
}

class _AlarmSettingState extends State<AlarmSetting> {

  double _sensitivity = 1;
  int _alarmGap = 15;
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

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    DetectStatus detectStatus = Provider.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(height: responsive.percentHeight(7)),
            Container(
              width: responsive.percentWidth(85),
              margin: EdgeInsets.only(bottom: 10, left: responsive.percentWidth(7.5)),
              child: Text('거북목 탐지 민감도 설정',
                style: TextStyle(
                  color: const Color(0xFF434343),
                  fontSize: responsive.fontSize(18),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  width: responsive.percentWidth(85),
                  margin: const EdgeInsets.only(
                      bottom: 10),
                  child: Text('민감도가 높을수록 잘못된 자세를 더욱 엄격하게 탐지해요. 그 대신 더 작은 움직임에도 탐지 알림이 울릴 수 있어요.',
                    style: TextStyle(
                      color: const Color(0xFF434343),
                      fontSize: responsive.fontSize(14),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Container(
                  width: responsive.percentWidth(95),
                  margin: EdgeInsets.only(left: responsive.percentWidth(2.5)),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Slider(
                          value: _sensitivity,
                          max: 2,
                          divisions: 2,
                          // label: _sliderLabel[_sensitivity.toInt()],
                          onChanged: (double value) {
                            setState(() {
                              _sensitivity = value;
                              detectStatus.setSensitivity(value);
                            });
                          }
                      ),
                      SizedBox(
                        width: responsive.percentWidth(85),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("낮음"),
                            Text("보통"),
                            Text("높음")
                          ],
                        ),
                      ),
                      const SizedBox(height: 10,)
                    ],
                  )
                ),
              ],
            ),
            SizedBox(height: responsive.percentHeight(7)),
            Container(
              width: responsive.percentWidth(85),
              margin: EdgeInsets.only(bottom: 10, left: responsive.percentWidth(7.5)),
              child: Text('알림 기준 시간 설정',
                style: TextStyle(
                  color: const Color(0xFF434343),
                  fontSize: responsive.fontSize(18),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  width: responsive.percentWidth(85),
                  margin: const EdgeInsets.only(
                      bottom: 10),
                  child: Text('잘못된 자세를 얼마나 유지했을 때 알림을 받을지 설정할 수 있어요.',
                    style: TextStyle(
                      color: const Color(0xFF434343),
                      fontSize: responsive.fontSize(14),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Container(
                    width: responsive.percentWidth(95),
                    margin: EdgeInsets.only(left: responsive.percentWidth(2.5)),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('탐지 즉시',
                            style: TextStyle(
                              color: const Color(0xFF434343),
                              fontSize: responsive.fontSize(14),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          leading: Radio(
                            value: 0,
                            groupValue: _alarmGap,
                            onChanged: (int? value) {
                              setState(() {
                                _alarmGap = value!;
                              });
                              detectStatus.setAlarmGap(_alarmGap);
                            },
                          ),
                        ),
                        ListTile(
                          title: Text('15초',
                            style: TextStyle(
                              color: const Color(0xFF434343),
                              fontSize: responsive.fontSize(14),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          leading: Radio(
                            value: 15,
                            groupValue: _alarmGap,
                            onChanged: (int? value) {
                              setState(() {
                                _alarmGap = value!;
                              });
                              detectStatus.setAlarmGap(_alarmGap);
                            },
                          ),
                        ),
                        ListTile(
                          title: Text('30초',
                            style: TextStyle(
                              color: const Color(0xFF434343),
                              fontSize: responsive.fontSize(14),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          leading: Radio(
                            value: 30,
                            groupValue: _alarmGap,
                            onChanged: (int? value) {
                              setState(() {
                                _alarmGap = value!;
                              });
                              detectStatus.setAlarmGap(_alarmGap);
                            },
                          ),
                        ),
                        ListTile(
                          title: Text('1분',
                            style: TextStyle(
                              color: const Color(0xFF434343),
                              fontSize: responsive.fontSize(14),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          leading: Radio(
                            value: 60,
                            groupValue: _alarmGap,
                            onChanged: (int? value) {
                              setState(() {
                                _alarmGap = value!;
                              });
                              detectStatus.setAlarmGap(_alarmGap);
                            },
                          ),
                        ),
                        ListTile(
                          title: Text('5분',
                            style: TextStyle(
                              color: const Color(0xFF434343),
                              fontSize: responsive.fontSize(14),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          leading: Radio(
                            value: 300,
                            groupValue: _alarmGap,
                            onChanged: (int? value) {
                              setState(() {
                                _alarmGap = value!;
                              });
                              detectStatus.setAlarmGap(_alarmGap);
                            },
                          ),
                        )
                      ],
                    )
                ),
              ],
            ),
            SizedBox(height: responsive.percentHeight(7)),
            Container(
              width: responsive.percentWidth(85),
              margin: EdgeInsets.only(bottom: 10, left: responsive.percentWidth(7.5)),
              child: Text('백색소음 설정',
                style: TextStyle(
                  color: const Color(0xFF434343),
                  fontSize: responsive.fontSize(18),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  width: responsive.percentWidth(85),
                  margin: const EdgeInsets.only(
                      bottom: 10),
                  child: Text('백색소음과 함께 일의 집중력을 높여보세요.\n이 설정은 변경 후에 탐지를 중지 후 다시 시작해주세요.',
                    style: TextStyle(
                      color: const Color(0xFF434343),
                      fontSize: responsive.fontSize(14),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Container(
                    width: responsive.percentWidth(95),
                    margin: EdgeInsets.only(left: responsive.percentWidth(2.5)),
                    padding: EdgeInsets.only(left: responsive.percentWidth(7.5), top: responsive.percentHeight(0.75), bottom: responsive.percentHeight(0.75), right: responsive.percentWidth(5)),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('백색소음 켜기',
                          style: TextStyle(
                            color: const Color(0xFF434343),
                            fontSize: responsive.fontSize(14),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
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
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}