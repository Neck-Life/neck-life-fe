import 'package:flutter/material.dart';
import 'package:mocksum_flutter/model/pose_duration.dart';
import 'package:mocksum_flutter/util/responsive.dart';
import 'package:mocksum_flutter/view/history/widgets/pose_time_tile.dart';


class PoseTimeMap extends StatelessWidget {

  final List<PoseDuration> poseDurationList;
  final void Function(int) notifyTap;

  const PoseTimeMap({
    super.key,
    required this.poseDurationList,
    required this.notifyTap
  });

  @override
  Widget build(BuildContext context) {
    Responsive res = Responsive(context);
    List<PoseDuration> poseDurationList_ = poseDurationList;

    return Row(
      // children: [
      //   PoseTimeTile(widthRate: 0.1, durationType: DurationType.normal),
      //   PoseTimeTile(widthRate: 0.2, durationType: DurationType.abnormal),
      //   PoseTimeTile(widthRate: 0.1, durationType: DurationType.none),
      //   PoseTimeTile(widthRate: 0.1, durationType: DurationType.normal),
      //   PoseTimeTile(widthRate: 0.2, durationType: DurationType.abnormal),
      // ],
      children: <Widget>[
        Container(
          width: 2,
          height: res.percentHeight(8),
          decoration: const BoxDecoration(
              color: Colors.black
          ),
        )
      ] + List.generate(poseDurationList_.length, (idx)  {
        return GestureDetector(
          onTap: () {
            if (poseDurationList_[idx].durationType == DurationType.abnormal) {
              notifyTap(idx);
            }
          },
          child: PoseTimeTile(widthRate: (poseDurationList_[idx].width < 3 ? 3 : (poseDurationList_[idx].width > 60 ? 60 : poseDurationList_[idx].width)) /100,
              durationType: poseDurationList_[idx].durationType),
        );
      }) + <Widget>[
            Container(
              width: 2,
              height: res.percentHeight(8),
              decoration: const BoxDecoration(
                  color: Colors.black
              ),
            )
          ],
    );
  }
}
