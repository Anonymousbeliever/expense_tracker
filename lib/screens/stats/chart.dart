import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/data/data.dart';

class MyChart extends StatefulWidget {
  final String timeFilter; // "7 Days" or "30 Days"
  const MyChart({super.key, required this.timeFilter});

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  int touchedIndex = -1; // For tooltip interaction

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpensesProvider>(context);
    final expenses = provider.expenses;

    // Filter expenses based on time range
    final now = DateTime.now();
    final days = widget.timeFilter == '7 Days' ? 7 : 30;
    final startDate = now.subtract(Duration(days: days - 1));
    final filteredExpenses = expenses
        .where((e) => e.date.isAfter(startDate.subtract(const Duration(days: 1))))
        .toList();

    // Aggregate expenses by day
    final dailyTotals = <DateTime, double>{};
    for (var expense in filteredExpenses) {
      final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + expense.amount;
    }

    // Generate bar groups (last `days` days)
    final barGroups = List.generate(days, (i) {
      final date = now.subtract(Duration(days: days - 1 - i));
      final dayKey = DateTime(date.year, date.month, date.day);
      final total = dailyTotals[dayKey] ?? 0.0;
      return makeGroupData(i, total, dailyTotals);
    });

    // Calculate max Y for scaling
    final maxY = dailyTotals.values.isEmpty ? 5.0 : dailyTotals.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY < 5 ? 5 : maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
            getTooltipItem: (group, groupIdx, rod, rodIdx) {
              final date = now.subtract(Duration(days: days - 1 - group.x));
              return BarTooltipItem(
                'KSH ${rod.toY.toStringAsFixed(2)}\n${DateFormat('MMM dd').format(date)}',
                TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            });
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, meta) => getTiles(value, meta, days, now),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: maxY / 5,
              getTitlesWidget: leftTiles,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.outlineVariant,
            strokeWidth: 1,
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y, Map<DateTime, double> dailyTotals) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: touchedIndex == x
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.7),
          width: 12,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: dailyTotals.isEmpty ? 5 : dailyTotals.values.reduce((a, b) => a > b ? a : b) * 1.2,
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget getTiles(double value, TitleMeta meta, int days, DateTime now) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      fontSize: 12,
    );
    final date = now.subtract(Duration(days: days - 1 - value.toInt()));
    final text = DateFormat('MMM dd').format(date);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: style),
    );
  }

  Widget leftTiles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      fontSize: 12,
    );
    String text;
    if (value == 0) {
      text = '0';
    } else if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      text = value.toStringAsFixed(0);
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: style),
    );
  }
}