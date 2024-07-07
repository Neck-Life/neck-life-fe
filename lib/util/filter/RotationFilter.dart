import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:turtleneck/util/filter/Filter.dart';
import 'package:turtleneck/util/filter/util/changeDeviceMotionData.dart';

class Rotationfilter extends Filter{

  List<double> rotationRatesX = [0.0];
  List<double> rotationRatesY = [0.0];
  List<double> rotationRatesZ = [0.0];

  @override
  DeviceMotionData? operation(DeviceMotionData data) {
    // TODO: implement operation
    var currentAccelY = data.userAcceleration.y;


    if((data.rotationRate.x-rotationRatesX.last).abs()
        + (data.rotationRate.y-rotationRatesY.last).abs()
        + (data.rotationRate.z-rotationRatesZ.last).abs() > 0.0000000000001) {

      currentAccelY =0;
    }
    if(currentAccelY.abs() < 0.01) currentAccelY = 0.0;


    rotationRatesX.add(data.rotationRate.x.toDouble());
    rotationRatesY.add(data.rotationRate.y.toDouble());
    rotationRatesZ.add(data.rotationRate.z.toDouble());

    return changeDeviceMotionData(data, currentAccelY.toDouble());




  }


}