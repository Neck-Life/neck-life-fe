import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mocksum_flutter/view/stretch/subpages/strethcing_alarm_setting.dart';
import 'package:provider/provider.dart';

import '../../../service/stretching_timer.dart';
import '../../../theme/component/text_default.dart';
import '../../../theme/component/white_container.dart';
import '../../../util/responsive.dart';
import '../data/stretching_data.dart';
import '../models/stretching_action.dart';

class StretchingSelection extends StatefulWidget {
  const StretchingSelection({Key? key}) : super(key: key);

  @override
  _StretchingSelectionState createState() => _StretchingSelectionState();
}

class _StretchingSelectionState extends State<StretchingSelection> {
  int _anchorIdx = 0;
  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
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
                  TextDefault(
                    content: '스트레칭종류 선택',
                    fontSize: 18,
                    isBold: true,
                  ),
                  DropdownButton<StretchingGroup>(
                    value: selectedStretchingGroup,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.blue),
                    underline: Container(
                      height: 2,
                      color: Colors.blueAccent,
                    ),
                    onChanged: (StretchingGroup? newValue) {
                      setState(() {
                        selectedStretchingGroup = newValue!;
                      });
                    },
                    items: stretchingGroups
                        .map<DropdownMenuItem<StretchingGroup>>((StretchingGroup group) {
                      return DropdownMenuItem<StretchingGroup>(
                        value: group,
                        child: TextDefault(content: group.groupName, fontSize: 16, isBold: false),
                      );
                    }).toList(),
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
