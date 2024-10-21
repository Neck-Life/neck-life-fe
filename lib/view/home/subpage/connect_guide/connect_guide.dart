import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/view/home/widgets/app_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../util/responsive.dart';

class ConnectGuide extends StatefulWidget {
  const ConnectGuide({super.key});
  @override
  State<StatefulWidget> createState() => _ConnectGuideState();
}

class _ConnectGuideState extends State<ConnectGuide> {

  late PermissionStatus _isAuthorized = PermissionStatus.denied;

  @override
  void initState() {
    checkPermission();
    super.initState();
  }

  void checkPermission() async {
    final sensorPermission = await Permission.sensors.status;
    setState(() {
      _isAuthorized = sensorPermission;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: HomeAppBar()
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(7.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleText('connect_guide.title'.tr(), res),
                SizedBox(height: res.percentHeight(5),),
                !_isAuthorized.isGranted ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleText('connect_guide.permission_txt'.tr(), res),
                    descText('connect_guide.permission_desc'.tr()),
                    SizedBox(height: res.percentHeight(1),),
                    GestureDetector(
                      onTap: () {
                        AppSettings.openAppSettings();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: res.percentWidth(4), vertical: res.percentHeight(1)),
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: descText('connect_guide.go_setting'.tr()),
                      ),
                    ),
                    SizedBox(height: res.percentHeight(5),),
                  ],
                ) : const SizedBox(),
                titleText('connect_guide.model_txt'.tr(), res),
                descText('connect_guide.model_desc'.tr()),
                SizedBox(height: res.percentHeight(5),),
                titleText('connect_guide.conn_txt'.tr(), res),
                descText('connect_guide.conn_desc'.tr()),
                SizedBox(height: res.percentHeight(5),),
                descText('connect_guide.last'.tr()),
                SizedBox(height: res.percentHeight(5),)
              ],
            ),
          )
      ),
    );
  }
  
  Widget titleText(String str, Responsive res) {
    return TextDefault(
        content: str,
        fontSize: 20,
        isBold: true
    );
  }

  Widget descText(String str) {
    return TextDefault(
        content: str,
        fontSize: 16,
        isBold: false
    );
  }
}