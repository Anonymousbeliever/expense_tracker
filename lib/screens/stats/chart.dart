import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

class MyChart extends StatefulWidget {
  const MyChart({super.key});

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      mainBarData(),
    );
  }

  BarChartData mainBarData () {
    return BarChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false)
        ),
        topTitles:  AxisTitles(                                                                                                                                                                                                                                                                                                                                                                                                                      
          sideTitles: SideTitles(showTitles: false)
        ),
        bottomTitles:  AxisTitles(
          sideTitles: SideTitles( showTitles: true)          
        ),
        leftTitles:  AxisTitles(
          sideTitles: SideTitles( showTitles: true)          
        ),
      )
    );
  }
  }
