import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocksum_flutter/page_navbar.dart';
import 'package:mocksum_flutter/theme/component/person_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:provider/provider.dart';

import '../service/global_timer.dart';
import '../service/history_provider.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<StatefulWidget> createState() => _LoadingState();

}

class _LoadingState extends State<Loading> {

  bool _internetConnectness = true;

  @override
  void initState() {

    Future.delayed(const Duration(seconds: 2), () async {
      // await Provider.of<HistoryStatus>(context, listen: false).updateHistoryData(DateTime.now().year.toString(), DateTime.now().month.toString().padLeft(2, '0'));
      // await Provider.of<HistoryStatus>(context, listen: false).getScoreSeriesV2('MONTH6');
      Navigator.push(
          context, MaterialPageRoute(builder: (
          context) => PageNavBar(pageIdx: 1, key: UniqueKey())));
    });
    super.initState();
  }

  void checkInternetConnectness() async {
    bool internetConnectness = await InternetConnection().hasInternetAccess;
    setState(() {
      _internetConnectness = internetConnectness;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);

    return Scaffold(
      body: Container(
        width: res.deviceWidth,
        height: res.deviceHeight,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextDefault(content: 'loading.history_loading'.tr(), fontSize: 20, isBold: true),
            SizedBox(height: res.percentHeight(3),),
            SizedBox(
              width: res.percentWidth(27),
              height: res.percentWidth(27),
              child: const Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 4,
                    backgroundColor: Color(0xFFE2E2E2),
                    color: Color(0xFF236EF3),
                  ),
                  Center(
                      child: PersonIcon(size: 25,)
                  ),
                ],
              ),
            ),
            SizedBox(height: res.percentHeight(3),),
            !_internetConnectness ? (
             Column(
              children: [
                TextDefault(content: 'loading.internet1'.tr(), fontSize: 16, isBold: true, fontColor: const Color(0xFFF25959), ),
                TextDefault(content: 'loading.internet2'.tr(), fontSize: 16, isBold: true, fontColor: const Color(0xFFF25959), ),
                TextDefault(content: 'loading.internet3'.tr(), fontSize: 16, isBold: true, fontColor: const Color(0xFFF25959), ),
              ],
            )
            ) :  const SizedBox()

          ],
        ),

      ),
    );
  }
}