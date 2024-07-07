import 'package:flutter_airpods/models/device_motion_data.dart';

import 'KalmanFilter.dart';

class KalmanfilterPosition extends KalmanFilter{
  static double dt = 0.4;
  @override
  List<List<double>> A = [[1, dt], [0, 1]];
  @override
  List<List<double>> H =[[0,1]];
  @override
  List<List<double>> Q = [[1, 0], [0, 3]];
  @override
  List<List<double>> R = [[10]];
  @override
  List<List<double>> P = [[5,0], [0, 5]];
  @override
  List<double> x_esti = [0.0, 0.0];


  @override
  void iterate(List<double> z) {
    super.iterate(z);
  }

  @override
  void setDt(double d) {
    super.setDt(d);
  }

  @override
  void setX(List<double> x) {
    super.setX(x);
  }


  getPosition(){
    return x_esti[0];
  }
  getVelocity(){
    return x_esti[1];
  }

  double operation(DeviceMotionData data, double dt) {
    setDt(dt);
    setX([getPosition(),0.0]);
    iterate([data.userAcceleration.y.toDouble()]);
    return getPosition();
  }


}