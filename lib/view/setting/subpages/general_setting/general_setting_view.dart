import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/service/status_provider.dart';
import 'package:mocksum_flutter/view/setting/subpages/alarm_setting/widgets/time_delay_tile.dart';
import 'package:provider/provider.dart';

import '../../../../theme/asset_icon.dart';
import '../../../../theme/component/text_default.dart';
import '../../../../util/localization_string.dart';

class GeneralSetting extends StatefulWidget {
  const GeneralSetting({super.key});

  @override
  State<StatefulWidget> createState() => _GeneralSettingState();
}

class _GeneralSettingState extends State<GeneralSetting> {

  int _chosenLocaleIdx = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _chosenLocaleIdx = context.locale.languageCode == 'en' ? 0 : 1;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
            backgroundColor: const Color(0xFFF4F4F7),
            title:TextDefault(
              content: 'setting_view.general'.tr(),
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
                    TextDefault(content: 'setting_view.lang'.tr(), fontSize: 18, isBold: true),
                    SizedBox(height: res.percentHeight(0.5),),
                    TextDefault(
                      content: LS.tr('setting_view.lang_exp'),
                      fontSize: 13,
                      isBold: false,
                      fontColor: const Color(0xFF8991A0),
                    ),
                    TextDefault(
                      content: LS.tr('setting_view.lang_noti'),
                      fontSize: 13,
                      isBold: false,
                    ),
                    SizedBox(height: res.percentHeight(2),),
                    GestureDetector(
                      onTap: () {
                        _chosenLocaleIdx = 0;
                        context.setLocale(const Locale('en', 'US'));
                      },
                      child: Row(
                        children: [
                          Container(
                            width: res.percentWidth(5),
                            height: res.percentWidth(5),
                            padding: EdgeInsets.all(res.percentWidth(0.5)),
                            decoration: BoxDecoration(
                                color: _chosenLocaleIdx == 0 ? const Color(0xFF236EF3) : const Color(0xFFF4F4F7),
                                borderRadius: BorderRadius.circular(res.percentWidth(3))
                            ),
                            child: AssetIcon('check', size: 1, color: _chosenLocaleIdx == 0 ? Colors.white : const Color(0xFF101E32),),
                          ),
                          SizedBox(width: res.percentWidth(3),),
                          const TextDefault(content: 'English', fontSize: 16, isBold: false,),
                        ],
                      ),
                    ),
                    SizedBox(height: res.percentHeight(1.5),),
                    GestureDetector(
                      onTap: () {
                        _chosenLocaleIdx = 1;
                        context.setLocale(const Locale('ko', 'KR'));
                      },
                      child: Row(
                        children: [
                          Container(
                            width: res.percentWidth(5),
                            height: res.percentWidth(5),
                            padding: EdgeInsets.all(res.percentWidth(0.5)),
                            decoration: BoxDecoration(
                                color: _chosenLocaleIdx == 1 ? const Color(0xFF236EF3) : const Color(0xFFF4F4F7),
                                borderRadius: BorderRadius.circular(res.percentWidth(3))
                            ),
                            child: AssetIcon('check', size: 1, color: _chosenLocaleIdx == 1 ? Colors.white : const Color(0xFF101E32),),
                          ),
                          SizedBox(width: res.percentWidth(3),),
                          const TextDefault(content: '한국어', fontSize: 16, isBold: false,),
                        ],
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