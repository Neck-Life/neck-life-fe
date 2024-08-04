import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_airpods/models/device_motion_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mocksum_flutter/mac/flutter_airpods_mac.dart';
import 'package:mocksum_flutter/util/airpods/PositionDisplay.dart';
import 'package:mocksum_flutter/util/filter/KalmanFilterPosition.dart';
import 'package:mocksum_flutter/util/filter/KalmanFilterVelocity.dart';



///측정로직 클래스
class AirpodsCalMovingAvgZupt extends Filter{
  double lastTimestamp = 0.0;
  List<double> Raccelometers = [0.0];
  List<double> Rvelocities = [0.0];
  List<double> Rpositions = [0.0];
  List<double> Maccelometers = [0.0];
  List<double> Mvelocities = [0.0];
  List<double> Mpositions = [0.0];
  List<double> pastY = [0.0]; //가속도Y 히스토리
  List<double> pastZ = [0.0]; //가속도Z 히스토리
  List<double> rotation = [0,0,0,0];

  double accSum =0;
  bool alertFlag= false;




  static const double threshold = 1.5; //변위 최댓값 설정

  /// position값을 [0,limitValue]범위로 리턴, 비워두면 기존값그대로 리턴
  @override
  double getPosition([double limitValue=threshold]){
    return Rpositions.last * (limitValue / threshold);
  }

  /// <- processSensorData : 측정 1틱 진입점
  ///compensatePosition : 비정상 속도히스토리,위치 보상 알고리즘
  /// <- applyZUPT : 영속도 보정 알고리즘
  @override
  void processSensorData(DeviceMotionData data) {
    double currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    double deltaTime = Rpositions.length==1 ? 0 : currentTime - lastTimestamp;
    lastTimestamp = currentTime;
    double velocity = 0;

    List<double> nowRot = [data.attitude.quaternion.x.toDouble(),
      data.attitude.quaternion.y.toDouble(),
      data.attitude.quaternion.z.toDouble(),
      data.attitude.quaternion.w.toDouble()];
    double currentAccelY = data.userAcceleration.y.toDouble();

    var abs = (nowRot[0] - rotation[0]).abs() +
        (nowRot[1] - rotation[1]).abs()
        +(nowRot[2] - rotation[2]).abs()
        +(nowRot[3] - rotation[3]).abs();

    if(abs>0.005){
      currentAccelY=0;
    }

    rotation = [nowRot[0],nowRot[1],nowRot[2],nowRot[3]];


    //
    // if(currentAccelY< 0){
    //   currentAccelY = currentAccelY * 2;
    // }

    // if(currentAccelY.abs()<0.03){
    //   currentAccelY=0;
    // }

    if(!alertFlag) {
      accSum += currentAccelY;
    }
    if( accSum.abs()>0.15){
      alertFlag = true;
      Timer(Duration(seconds: 2), () {
        alertFlag = false;
      });
      if(accSum>0){
        print("앞으로 이동");
      }else{
        print("뒤로이동");
      }
      accSum= 0;
    }




    velocity = Rvelocities.last + currentAccelY * deltaTime;
    double position = Rpositions.last + velocity * deltaTime;



    if(Raccelometers.length > 100) Raccelometers.removeAt(0);
    if(Rvelocities.length > 100) Rvelocities.removeAt(0);
    if(Rpositions.length > 100) Rpositions.removeAt(0);
    if(Maccelometers.length > 100) Maccelometers.removeAt(0);
    if(Mvelocities.length > 100) Mvelocities.removeAt(0);
    if(Mpositions.length > 100) Mpositions.removeAt(0);








    Maccelometers.add(accSum);



    Raccelometers.add(currentAccelY);
    Rvelocities.add(velocity);
    Rpositions.add(position);



  }

  List<double> movingAverageFilter(List<double> data, int windowSize) {
    List<double> smoothedData = [];
    for (int i = 0; i < data.length; i++) {
      int start = max(0, i - windowSize + 1);
      int end = i + 1;
      double sum = 0;
      for (int j = start; j < end; j++) {
        sum += data[j];
      }
      smoothedData.add(sum / (end - start));
    }
    return smoothedData;
  }



  double linearInterpolation(double x0, double x1, double y0, double y1, double x) {
    return y0 + (y1 - y0) * ((x - x0) / (x1 - x0));
  }

  double lagrangeInterpolation(List<double> x, List<double> y, double t) {
    int n = x.length;
    double result = 0;

    for (int i = 0; i < n; i++) {
      double term = y[i];
      for (int j = 0; j < n; j++) {
        if (j != i) {
          term *= (t - x[j]) / (x[i] - x[j]);
        }
      }
      result += term;
    }

    return result;
  }

  List<double> interpolateData(List<double> data, int targetLength) {
    List<double> interpolatedData = [];
    double step = (data.length - 1) / (targetLength - 1);

    for (int i = 0; i < targetLength; i++) {
      double pos = i * step;
      int left = pos.floor();
      int right = pos.ceil();
      if (left == right) {
        interpolatedData.add(data[left]);
      } else {
        interpolatedData.add(linearInterpolation(left.toDouble(), right.toDouble(), data[left], data[right], pos));
      }
    }

    return interpolatedData;
  }

  //[velocity, postion] => [개선된 velocity, position] 제공
  List<double> applyZUPT(double velocity, double position){
    double deviation = 0.0;
    int windowSIZE = 10;
    if(Raccelometers.length < windowSIZE) return [velocity, position];

    for(int i=Raccelometers.length - windowSIZE;i<Raccelometers.length;i++){
      deviation += Raccelometers[i].abs();
    }
    deviation /= windowSIZE;
    // print(deviation);
    //편차 임계치 설정 추가 로직 필요 : 시간에 따라 가속도raw 측정값 자체의 오차가 커지는 현상 발견
    if(deviation > 0.002){
      print("deviation");
      return [velocity, position];}
    //위치 보상 알고리즘
    //속도가 비정상으로 뒤집힌 구간만큼 롤백
    // 위치 보상이 필요없으면 속도 합만큼 사용
    position = compensatePosition(velocity, position);
    velocity = 0;
    return [velocity, position];
  }

  ///위치 보상 알고리즘
  ///속도가 비정상으로 뒤집힌 구간만큼 롤백
  double compensatePosition(double velocity, double position){

    bool compensationFlag = false;
    int idx = Rvelocities.length -1;
    int flagIdx = 0;
    while(idx>=0 && velocity * Rvelocities[idx] > 0){
      idx--;
    }
    while(idx>=0 && velocity * Rvelocities[idx] < 0) {
      if(Rvelocities[idx].abs() > 0.001){
        compensationFlag = true;
        flagIdx = idx;
        break;
      }
      idx--;
    }

    double removeSum = 0;
    double moveSum = 0;

    if(compensationFlag){
      idx = Rvelocities.length - 1;
      while(idx>=0 &&velocity * Rvelocities[idx] > 0){
          removeSum+= Rvelocities[idx];
          Rvelocities[idx] = 0;
          idx--;
      }
      while(idx>=0 &&velocity * Rvelocities[idx] < 0){
        moveSum+= Rvelocities[idx];
        idx--;
      }
      if(moveSum.abs()<removeSum.abs()){
        position = Rpositions[idx] + removeSum/removeSum.abs();
     }
      else{
        position = Rpositions[idx] +  moveSum/moveSum.abs() ;
      }
      print("거리보상 보상 알고리즘 발동!");
    }

    ///위치 오차 보정 : 과도하게 커지거나 작아지면, limit값으로 강제 변경
    // if(position > 1) position = 1;
    // else if(position < -1) position = -1;
    return position;
  }




}





/**
 * 테스트 환경 진입점
 * */
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AirpodsExampleApp(),
    );
  }
}

class AirpodsExampleApp extends StatefulWidget {
  @override
  _AirpodsExampleAppState createState() => _AirpodsExampleAppState();
}

class _AirpodsExampleAppState extends State<AirpodsExampleApp> {
  StreamSubscription<DeviceMotionData>? _subscription;
  bool _isListening = false;
  List<double> Raccelometers  = [0.0];
  List<double> Rvelocities = [0.0];
  List<double> Rpositions = [0.0];
  List<double> Maccelometers  = [0.0];
  List<double> Mvelocities = [0.0];
  List<double> Mpositions = [0.0];
  @override
  void initState() {
    super.initState();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      Filter positionDisplay = AirpodsCalMovingAvgZupt();
      AirpodsCalMovingAvgZupt positionDisplayTest = positionDisplay as AirpodsCalMovingAvgZupt; //내부 테스트 용

      Raccelometers = positionDisplayTest.Raccelometers;
      Rvelocities = positionDisplayTest.Rvelocities;
      Rpositions = positionDisplayTest.Rpositions;
      Maccelometers = positionDisplayTest.Maccelometers;
      Mvelocities = positionDisplayTest.Mvelocities;
      Mpositions = positionDisplayTest.Mpositions;


      _subscription = FlutterAirpodsMac.getAirPodsDeviceMotionUpdates.listen((data) {
        // print(positionDisplay.getPosition(100)); // 최대값100으로 scaling하여 위치 출력
        positionDisplay.processSensorData(data);
        setState(() {
        });
      }, onError: (error) {
        print('Error: $error');
      });

    });
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _subscription?.cancel();
      _subscription = null;
    });
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Position Detection'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: -0.2, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.5, // Y축 최대값 설정
                lineBarsData: [
                  LineChartBarData(
                    spots: Maccelometers.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: -0.2, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.5, // Y축 최대값 설정
                lineBarsData: [
                  LineChartBarData(
                    spots: Mvelocities.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),


          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: -0.1, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.1, // Y축 최대값 설정
                lineBarsData: [
                  LineChartBarData(
                    spots: Mpositions.asMap().entries.map((e) =>FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),




          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: -0.2, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.2, // Y축 최대값 설정
                lineBarsData: [
                  LineChartBarData(
                    spots: Raccelometers.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),


          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: -0.2, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.2, // Y축 최대값 설정
                lineBarsData: [
                  LineChartBarData(
                    spots: Rvelocities.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),


          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: -0.1, // Y축 최소값 설정 측정값 크기 에 따라 수정 필요
                maxY: 0.1, // Y축 최대값 설정
                lineBarsData: [
                  LineChartBarData(
                    spots: Rpositions.asMap().entries.map((e) =>FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),






          ElevatedButton(
            onPressed: _isListening ? _stopListening : _startListening,
            child: Text(_isListening ? "Stop Listening" : "Start Listening"),
          ),

        ],
      ),
    );
  }
}