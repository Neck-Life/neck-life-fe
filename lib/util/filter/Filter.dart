import 'package:flutter_airpods/models/device_motion_data.dart';

abstract class Filter{

  DeviceMotionData? operation(DeviceMotionData data);

}