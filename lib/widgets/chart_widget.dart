import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExpenseChart extends StatefulWidget {
  final List<Expense> expenses;
  final String timeFilter; // "7 Days" or "30 Days"

  const ExpenseChart({
    super.key,
    required this.expenses,
    required this.timeFilter,
  });

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Filter expenses based on time range
    final now = DateTime.now();
    final days = widget.timeFilter == '7 Days' ? 7 : 30;
    final startDate = now.subtract(Duration(days: days - 1));
    final filteredExpenses = widget.expenses
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
      return _makeGroupData(i, total, dailyTotals, theme);
    });

    // Calculate max Y for scaling
    final maxY = dailyTotals.values.isEmpty 
        ? 5.0 
        : dailyTotals.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: theme.colorScheme.inverseSurface,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = now.subtract(Duration(days: days - 1 - group.x.toInt()));
              return BarTooltipItem(
                '${DateFormat('MMM dd').format(date)}\n',
                TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'KSH ${NumberFormat('#,##0.00').format(rod.toY)}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = now.subtract(Duration(days: days - 1 - value.toInt()));
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 16,
                  child: Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.surfaceContainerHighest,
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(
    int x, 
    double y, 
    Map<DateTime, double> dailyTotals,
    ThemeData theme,
  ) {
    final maxValue = dailyTotals.values.isEmpty 
        ? 1.0 
        : dailyTotals.values.reduce((a, b) => a > b ? a : b);
    
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: touchedIndex == x 
              ? theme.colorScheme.primary.withOpacity(0.8)
              : theme.colorScheme.primary.withOpacity(0.6),
          width: widget.timeFilter == '7 Days' ? 20 : 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxValue * 1.2,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}