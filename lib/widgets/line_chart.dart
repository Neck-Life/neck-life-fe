import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScoreChart extends StatefulWidget {
  final Map<dynamic, dynamic> scoreValues;
  final String duration;

  const ScoreChart({required this.scoreValues, required this.duration, super.key});
  // const ScoreChart({super.key});

  @override
  State<StatefulWidget> createState() => _ScoreChartState();
}

class _ScoreChartState extends State<ScoreChart> {

  late Map<String, dynamic> _scoreValues;

  List<int> showingTooltipOnSpots = [];
  
  @override
  void initState() {
    super.initState();

  }

  void initScoreValue() {
    DateTime now = DateTime.now();
    int daySubtracted = 6;
    if (widget.duration == 'WEEK') {
      daySubtracted = 6;
    } else if (widget.duration == 'MONTH1') {
      daySubtracted = 29;
    } else if (widget.duration == 'MONTH3') {
      daySubtracted = 89;
    } else if (widget.duration == 'MONTH6') {
      daySubtracted = 179;
    }
    now = now.subtract(Duration(days: daySubtracted));

    _scoreValues = {};

    print('score ${widget.scoreValues}');

    for (int i = 0; i < daySubtracted+1; i++, now = now.add(const Duration(days: 1))) {
      String dateStr = '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      if (widget.scoreValues.containsKey(dateStr)) {
        print(dateStr);
        _scoreValues[dateStr] = widget.scoreValues[dateStr];
      } else {
        _scoreValues[dateStr] = 0;
      }
    }
    // _scoreValues = {
    //   '2024-09-01': 70,
    //   '2024-09-02': 75,
    //   '2024-09-03': 80,
    //   '2024-09-04': 90,
    //   '2024-09-05': 100,
    //   '2024-09-06': 95,
    //   '2024-09-07': 70,
    // };
    // if (showingTooltipOnSpots.isNotEmpty && showingTooltipOnSpots[0] > daySubtracted) {
    //   showingTooltipOnSpots.removeAt(0);
    // }
    showingTooltipOnSpots = [_scoreValues.length-1];
    // showingTooltipOnSpots.add(_scoreValues.length-1);
  }

  double getLineWidth() {
    if (widget.duration == 'WEEK') return 5;
    if (widget.duration == 'MONTH1') return 3.5;
    if (widget.duration == 'MONTH3') return 2.5;
    if (widget.duration == 'MONTH6') return 2;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    initScoreValue();

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              mainData(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      showingTooltipIndicators: showingTooltipOnSpots.map((index)  {
        return ShowingTooltipIndicators([
          LineBarSpot(
            LineChartBarData(
              spots: List.generate(_scoreValues.length, (idx) {
                return FlSpot((idx).toDouble(), _scoreValues[_scoreValues.keys.toList()[idx]].toDouble());
              }),
              isCurved: false,
              color: const Color(0xFF3077F4),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: false,
              ),
            ),
            0,
            List.generate(_scoreValues.length, (idx) {
              return FlSpot((idx).toDouble(), _scoreValues[_scoreValues.keys.toList()[idx]].toDouble());
            })[index],
          ),
        ]);
      }).toList(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xFFF4F4F7),
            strokeWidth: 2,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xffF4F4F7), width: 2),
        ),
      ),
      minX: 0,
      maxX: _scoreValues.length.toDouble()-1,
      minY: 0,
      maxY: 110,
      lineBarsData: [
        LineChartBarData(
          showingIndicators: showingTooltipOnSpots,
          spots: List.generate(_scoreValues.length, (idx) {
            return FlSpot((idx).toDouble(), _scoreValues[_scoreValues.keys.toList()[idx]].toDouble());
          }),
          isCurved: false,
          color: const Color(0xFF3077F4),
          barWidth: getLineWidth(),
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: false,
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              const FlLine(
                color: Color(0xFF3077F4),
                dashArray: [4,4]
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: const Color(0xFF3077F4)
                  )
              )
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (value) {
            return value.map((e) => LineTooltipItem("${e.y.toInt()}점", const TextStyle( // _scoreValues.keys.toList()[e.x.toInt()]}\n
              color: Color(0xFF236EF3),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),)).toList();
          },
          getTooltipColor: (group) => Colors.transparent,

        ),
      )
    );
  }
}