// import 'package:flutter/material.dart';
// import 'package:flutter_airpods/flutter_airpods.dart';
// import 'package:flutter_airpods/models/device_motion_data.dart';
// import 'dart:async';
// import 'dart:math';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: AirpodsExampleApp(),
//     );
//   }
// }
//
// class AirpodsExampleApp extends StatefulWidget {
//   @override
//   _AirpodsExampleAppState createState() => _AirpodsExampleAppState();
// }
//
// class _AirpodsExampleAppState extends State<AirpodsExampleApp> {
//   StreamSubscription<DeviceMotionData>? _subscription;
//   List<DataPoint> _xData = [];
//   List<DataPoint> _yData = [];
//   List<DataPoint> _zData = [];
//   double sampleRate = 100.0;
//   List<double> velocity = [0.0, 0.0, 0.0];
//   List<double> position = [0.0, 0.0, 0.0];
//   List<double> prevAcceleration = [0.0, 0.0, 0.0];
//   List<bool> isMoving = [];
//   int margin = 40; // 100 ms margin
//   List<IsMovingPeriod> isMovingPeriods = [];
//   List<List<double>> velocityDrift = [];
//   int _time = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeVelocityDrift();
//   }
//
//   void _initializeVelocityDrift() {
//     for (int i = 0; i < 3; i++) {
//       velocityDrift.add(List.filled(100, 0.0));
//     }
//   }
//
//   void _startListening() {
//     setState(() {
//       _subscription = FlutterAirpods.getAirPodsDeviceMotionUpdates.listen((data) {
//         _processSensorData(data);
//       }, onError: (error) {
//         print('Error: $error');
//       });
//     });
//   }
//
//   void _stopListening() {
//     setState(() {
//       _subscription?.cancel();
//       _subscription = null;
//     });
//   }
//
//   void _processSensorData(DeviceMotionData data) {
//     List<double> acceleration = [
//       data.userAcceleration.x * 9.81,
//       data.userAcceleration.y * 9.81,
//       data.userAcceleration.z * 9.81,
//     ];
//
//     double deltaTime = 1 / sampleRate;
//     for (int i = 0; i < 3; i++) {
//       velocity[i] += (prevAcceleration[i] + acceleration[i]) / 2 * deltaTime;
//       position[i] += velocity[i] * deltaTime;
//     }
//     prevAcceleration = acceleration;
//
//     bool moving = sqrt(acceleration[0] * acceleration[0] + acceleration[1] * acceleration[1] + acceleration[2] * acceleration[2]) > 3.0;
//     isMoving.add(moving);
//     if (isMoving.length > 100) {
//       isMoving.removeAt(0);
//     }
//
//     _findMovingPeriods();
//     _removeVelocityDrift();
//
//     setState(() {
//       _updateChartData();
//     });
//   }
//
//   void _findMovingPeriods() {
//     isMovingPeriods.clear();
//     IsMovingPeriod isMovingPeriod = IsMovingPeriod();
//
//     for (int i = 0; i < isMoving.length; i++) {
//       if (isMovingPeriod.startIndex == -1) {
//         if (isMoving[i]) {
//           isMovingPeriod.startIndex = i;
//         }
//       } else {
//         if (!isMoving[i]) {
//           isMovingPeriod.stopIndex = i;
//           isMovingPeriods.add(isMovingPeriod);
//           isMovingPeriod = IsMovingPeriod();
//         }
//       }
//     }
//
//     if (isMovingPeriod.startIndex != -1 && isMovingPeriod.stopIndex == -1) {
//       isMovingPeriod.stopIndex = isMoving.length - 1;
//       isMovingPeriods.add(isMovingPeriod);
//     }
//   }
//
//   void _removeVelocityDrift() {
//     for (var isMovingPeriod in isMovingPeriods) {
//       int startIndex = isMovingPeriod.startIndex;
//       int stopIndex = isMovingPeriod.stopIndex;
//
//       if (startIndex < 0 || stopIndex < 0) continue;
//
//       List<double> t = [startIndex.toDouble(), stopIndex.toDouble()];
//       List<double> x = [velocity[startIndex], velocity[stopIndex]];
//       List<double> y = [velocity[startIndex], velocity[stopIndex]];
//       List<double> z = [velocity[startIndex], velocity[stopIndex]];
//
//       for (int i = startIndex; i <= stopIndex; i++) {
//         double tNew = i.toDouble();
//         velocityDrift[0][i] = _linearInterpolate(t, x, tNew);
//         velocityDrift[1][i] = _linearInterpolate(t, y, tNew);
//         velocityDrift[2][i] = _linearInterpolate(t, z, tNew);
//       }
//     }
//
//     for (int i = 0; i < 3; i++) {
//       for (int j = 0; j < velocity.length; j++) {
//         velocity[j] -= velocityDrift[i][j];
//       }
//     }
//   }
//
//   double _linearInterpolate(List<double> t, List<double> values, double tNew) {
//     if (t[1] - t[0] == 0) return values[0];
//     return values[0] + (values[1] - values[0]) * ((tNew - t[0]) / (t[1] - t[0]));
//   }
//
//   void _updateChartData() {
//
//     print(position);
//
//     _xData.add(DataPoint(time: _time, value: position[0]));
//     _yData.add(DataPoint(time: _time, value: position[1]));
//     _zData.add(DataPoint(time: _time, value: position[2]));
//     _time++;
//
//     if (_xData.length > 100) {
//       _xData.removeAt(0);
//       _yData.removeAt(0);
//       _zData.removeAt(0);
//     }
//   }
//
//   @override
//   void dispose() {
//     _stopListening();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Airpods Example App'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Expanded(
//             child: SfCartesianChart(
//               primaryXAxis: NumericAxis(
//                 title: AxisTitle(text: 'Time'),
//               ),
//               primaryYAxis: NumericAxis(
//                 title: AxisTitle(text: 'Position'),
//               ),
//               series: <CartesianSeries>[
//                 LineSeries<DataPoint, int>(
//                   dataSource: _xData,
//                   xValueMapper: (DataPoint point, _) => point.time,
//                   yValueMapper: (DataPoint point, _) => point.value,
//                   name: 'X',
//                   color: Colors.red,
//                 ),
//                 LineSeries<DataPoint, int>(
//                   dataSource: _yData,
//                   xValueMapper: (DataPoint point, _) => point.time,
//                   yValueMapper: (DataPoint point, _) => point.value,
//                   name: 'Y',
//                   color: Colors.green,
//                 ),
//                 LineSeries<DataPoint, int>(
//                   dataSource: _zData,
//                   xValueMapper: (DataPoint point, _) => point.time,
//                   yValueMapper: (DataPoint point, _) => point.value,
//                   name: 'Z',
//                   color: Colors.blue,
//                 ),
//               ],
//             ),
//           ),
//           ElevatedButton(
//             onPressed: _subscription == null ? _startListening : _stopListening,
//             child: Text(_subscription == null ? 'Start' : 'Stop'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class DataPoint {
//   final int time;
//   final double value;
//
//   DataPoint({required this.time, required this.value});
// }
//
// class IsMovingPeriod {
//   int startIndex;
//   int stopIndex;
//
//   IsMovingPeriod({this.startIndex = -1, this.stopIndex = -1});
// }