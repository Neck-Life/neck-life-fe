import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mocksum_flutter/main.dart';
import 'package:mocksum_flutter/view/stretch/subpages/strethcing_alarm_setting.dart';
import 'package:provider/provider.dart';

import '../../../service/stretching_timer.dart';
import '../../../theme/component/text_default.dart';
import '../../../theme/component/white_container.dart';
import '../../../util/responsive.dart';
import '../data/stretching_data.dart';
import '../models/stretching_action.dart';

class StretchingSelection extends StatefulWidget {
  const StretchingSelection({super.key});

  @override
  _StretchingSelectionState createState() => _StretchingSelectionState();
}

class _StretchingSelectionState extends State<StretchingSelection> {
  int _anchorIdx = 0;
  List<StretchingGroup> stretchingGroups = [];
  
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        stretchingGroups = StretchingData.init(context.locale.languageCode);
      });
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    StretchingTimer stretchingTimer = context.watch();
    return Center(
      child: SizedBox(
        width: res.deviceWidth,
        child: WhiteContainer(
          width: 87.5,
          padding: EdgeInsets.symmetric(horizontal: res.percentWidth(5), vertical: res.percentHeight(2.5)),
          radius: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset('assets/icons/Document.svg'),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextDefault(
                    content: '스트레칭 종류 선택',
                    fontSize: 18,
                    isBold: true,
                  ),
                  DropdownButton<int>(
                    value: stretchingTimer.selectedStretchingIndex,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.blue),
                    underline: Container(
                      height: 2,
                      color: Colors.blueAccent,
                    ),
                    onChanged: (int? newValue) {
                      setState(() {
                        // selectedStretchingGroup = newValue!;
                        stretchingTimer.setStretchingTypeIndex(newValue!);
                      });
                    },
                    items: List.generate(stretchingGroups.length, (idx) {
                      return DropdownMenuItem(
                        value: idx,
                        child: TextDefault(content: stretchingGroups[idx].groupName, fontSize: 16, isBold: false),
                      );
                    }),
                    // items: stretchingGroups
                    //     .map<DropdownMenuItem<StretchingGroup>>((StretchingGroup group) {

                    // }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
