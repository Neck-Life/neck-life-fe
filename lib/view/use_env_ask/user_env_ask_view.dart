import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/service/global_timer.dart';
import 'package:mocksum_flutter/service/stretching_timer.dart';
import 'package:mocksum_flutter/service/user_provider.dart';
import 'package:mocksum_flutter/theme/component/person_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/view/start_position/start_position_view.dart';
import 'package:mocksum_flutter/view/start_position/widget/animated_man.dart';
import 'package:mocksum_flutter/view/start_position/widget/spinning_timer.dart';
import 'package:mocksum_flutter/view/start_position/widget/time_display.dart';
import 'package:mocksum_flutter/view/use_env_ask/widget/env_item.dart';
import '../../../theme/asset_icon.dart';
import '../../../theme/component/button.dart';
import '../../../util/localization_string.dart';
import '../../../util/responsive.dart';
import 'package:provider/provider.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:wheel_picker/wheel_picker.dart';


class UserEnvAsk extends StatefulWidget {
  final void Function(bool, int)? onStart;

  const UserEnvAsk({super.key, this.onStart});
  @override
  State<StatefulWidget> createState() => _UserEnvAskState();
}

class _UserEnvAskState extends State<UserEnvAsk> {

  UserEnvType _seletedEnv = UserEnvType.no_setting;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    DetectStatus detectStatus = context.read();

    return Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: EdgeInsets.only(left: res.percentWidth(7.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: res.percentHeight(9),),
                const PersonIcon(),
                Container(
                    margin: const EdgeInsets.only(top: 12.5),
                    child: TextDefault(
                      content: LS.tr("user_env.when"),
                      fontSize: 28,
                      isBold: true,
                    )
                ),
                SizedBox(height: res.percentHeight(2),),
                TextDefault(
                  content: LS.tr('user_env.desc'),
                  fontSize: 16,
                  isBold: false,
                  fontColor: const Color(0xFF115FE9),
                ),
                Column(
                  children: [
                    SizedBox(height: res.percentHeight(2),),
                    WhiteContainer(
                      margin: EdgeInsets.only(bottom: res.percentHeight(2)),
                      padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
                      radius: 20,
                      child: Column(
                        children: [
                          EnvItem(desc: 'user_env.book'.tr(), isSelected: _seletedEnv == UserEnvType.book, onChange: () {
                            setState(() {
                              _seletedEnv = UserEnvType.book;
                            });
                          }),
                          EnvItem(desc: 'user_env.moving'.tr(), isSelected: _seletedEnv == UserEnvType.moving, onChange: () {
                            setState(() {
                              _seletedEnv = UserEnvType.moving;
                            });
                          }),
                          EnvItem(desc: 'user_env.phone'.tr(), isSelected: _seletedEnv == UserEnvType.phone, onChange: () {
                            setState(() {
                              _seletedEnv = UserEnvType.phone;
                            });
                          }),
                          EnvItem(desc: 'user_env.laptop'.tr(), isSelected: _seletedEnv == UserEnvType.laptop, onChange: () {
                            setState(() {
                              _seletedEnv = UserEnvType.laptop;
                            });
                          }),
                          EnvItem(desc: 'user_env.monitor'.tr(), isSelected: _seletedEnv == UserEnvType.monitor, onChange: () {
                            setState(() {
                              _seletedEnv = UserEnvType.monitor;
                            });
                          }),
                          EnvItem(desc: LS.tr('user_env.no_setting'), isSelected: _seletedEnv == UserEnvType.no_setting, onChange: () {
                            setState(() {
                              _seletedEnv = UserEnvType.no_setting;
                            });
                          }),
                        ],
                      ),
                    ),
                    Button(
                      onPressed: () {
                        detectStatus.setUserEnvType(_seletedEnv);
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => StartPosition(selectedEnv: _seletedEnv, onStart: widget.onStart,)));
                      },
                      text: 'start_position_view.start'.tr(),
                      backgroundColor: const Color(0xFF236EF3),
                      color: Colors.white,
                      width: res.percentWidth(85),
                      padding: res.percentWidth(4),
                    )
                  ],
                )
              ],
            ),
          ),
        )
    );
  }
}
