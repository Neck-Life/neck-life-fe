import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/view/stretch/subpages/stretching_list.dart';
import 'package:mocksum_flutter/view/stretch/subpages/stretching_selection.dart';
import 'package:mocksum_flutter/view/stretch/subpages/stretching_test_env.dart';
import 'package:mocksum_flutter/view/stretch/subpages/strethcing_alarm_setting.dart';

import '../../util/localization_string.dart';
import '../../util/responsive.dart';
import '../home/widgets/app_bar.dart';

// final GlobalKey<NavigatorState> stretchingNavigatorKey = GlobalKey<NavigatorState>();
late BuildContext stretchingContext;
class Stretching extends StatefulWidget {
  const Stretching({super.key});

  @override
  _StretchingState createState() => _StretchingState();
}

class _StretchingState extends State<Stretching>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 탭의 개수를 설정
    stretchingContext = context;
    // print('스트레칭 컨텍스트: ${stretchingContext}');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60), // 고정된 높이
        child: HomeAppBar(), // 사용자 정의 AppBar 위젯
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            // 탭 너비를 텍스트 길이에 맞게 조절
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Color(0xFF101010),
                width: 3,
              ),
              // insets: EdgeInsets.symmetric(horizontal: res.percentWidth(1)), // 테두리 양쪽 여백 설정
            ),
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: LS.tr('stretching.stretching_alarm.title')),
              // Tab(text: '스트레칭 선택'),
              //Tab(text: LS.tr('stretching.recommended_stretching.title')),
              Tab(text: LS.tr('stretching.stretching_alarm.title2')),
            ],
          ),
          SizedBox(height: res.percentWidth(1),),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                StretchingAlarmSetting(),
                // StretchingSelection(),
                // RecommendedStretching(),
                // StretchingDevEnv(),
                StretchingList()
                // FavoritesPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendedStretching extends StatelessWidget {
  const RecommendedStretching({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('추천 스트레칭 페이지\nTo Be Announced'));
  }
}