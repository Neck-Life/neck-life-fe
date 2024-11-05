import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/theme/component/text_default.dart';
import 'package:mocksum_flutter/theme/component/white_container.dart';
import 'package:mocksum_flutter/view/stretch/data/stretching_data.dart';
import 'package:provider/provider.dart';

import '../../../util/responsive.dart';
import '../models/stretching_action.dart';


class StretchingList extends StatefulWidget {
  const StretchingList({super.key});

  @override
  State<StatefulWidget> createState() => _StretchingListState();
}

class _StretchingListState extends State<StretchingList> {

  List<StretchingGroup> _stretchingList = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        _stretchingList = StretchingData.init(context.locale.languageCode);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    return Container(
      child: Column(
        children: _stretchingList.map((group) {
          return WhiteContainer(
            padding: EdgeInsets.symmetric(horizontal: res.percentWidth(4), vertical: res.percentHeight(2)),
            margin: EdgeInsets.only(top: res.percentHeight(2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextDefault(content: group.groupName, fontSize: 16, isBold: true),
                SizedBox(height: res.percentHeight(0.5),),
                TextDefault(content: '${group.time}${context.locale.languageCode == 'ko' ? '초' : ' seconds'}', fontSize: 13, isBold: false)
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
