import 'package:mocksum_flutter/view/history/widgets/pose_time_tile.dart';

class PoseDuration {
  final double xOffset;
  final int width;
  final DurationType durationType;
  final String startTime;
  final int? durationSec;

  const PoseDuration({
    required this.xOffset,
    required this.width,
    required this.durationType,
    required this.startTime,
    this.durationSec
  });

  @override
  String toString() {
    // TODO: implement toString
    return '$durationType';
  }

}