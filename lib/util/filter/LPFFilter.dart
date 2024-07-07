import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:turtleneck/util/filter/util/changeDeviceMotionData.dart';

import 'Filter.dart';

class LPFFilter extends Filter{

  double alpha;
  double? beforeData;

  // Alpha가 커질수록 이전 데이터의 영향력이 커짐
  LPFFilter(this.alpha);

  double filter(double data){
    if(beforeData == null){
      beforeData = data;
      return data;
    }


    return alpha * beforeData! + (1 - alpha) * data;
  }

  @override
  DeviceMotionData? operation(DeviceMotionData data) {
    var afterLPF = this.filter(data.userAcceleration.y.toDouble());

    var deviceMotionData = changeDeviceMotionData(data, afterLPF);



    return deviceMotionData;
  }

}