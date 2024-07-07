import 'package:flutter_airpods/models/device_motion_data.dart';

DeviceMotionData? changeDeviceMotionData(DeviceMotionData data, double accerationY) {
  var json = data.toJson();
  json['userAcceleration']['y'] = accerationY;
  var deviceMotionData = DeviceMotionData.fromJson(json);
  return deviceMotionData;
}