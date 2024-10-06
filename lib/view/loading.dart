import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocksum_flutter/page_navbar.dart';
import 'package:mocksum_flutter/theme/component/person_icon.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:provider/provider.dart';

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
      await Provider.of<HistoryStatus>(context, listen: false).getScoreSeriesV2('MONTH6');
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
            const TextDefault(content: '자세 기록을 정리하는 중이에요.', fontSize: 20, isBold: true),
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
            const Column(
              children: [
                TextDefault(content: '인터넷 연결이 필요해요.', fontSize: 16, isBold: true, fontColor: Color(0xFFF25959), ),
                TextDefault(content: '인터넷 연결이 가능한 곳에서 앱을', fontSize: 16, isBold: true, fontColor: Color(0xFFF25959), ),
                TextDefault(content: '실행해주시면 다시 정리해드릴게요.', fontSize: 16, isBold: true, fontColor: Color(0xFFF25959), ),
              ],
            )
            ) :  const SizedBox()

          ],
        ),

      ),
    );
  }
}