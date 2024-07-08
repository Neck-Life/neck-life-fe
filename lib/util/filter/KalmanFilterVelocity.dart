

import 'package:flutter_airpods/models/device_motion_data.dart';

import 'KalmanFilter.dart';

class KalmanfilterVelocity extends KalmanFilter{
  static double dt = 0.4;
  @override
  List<List<double>> A = [[1, dt], [0, 1]];
  @override
  List<List<double>> H =[[0,1]];
  @override
  List<List<double>> Q = [[0.3, 0], [0, 1]];
  @override
  List<List<double>> R = [[0.01]];
  @override
  List<List<double>> P = [[1, 0.005], [0, 1]];
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

  getVelocity(){
    return x_esti[0];
  }
  getAcceleration(){
    return x_esti[1];
  }

  double operation(double data, double dt) {
    setDt(dt);
    iterate([data]);
    return getVelocity();
  }


}