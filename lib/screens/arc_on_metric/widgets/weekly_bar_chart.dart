import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:machine_dashboard/blocs/arc_time_metric/arc_time_metric_bloc.dart';
import 'package:machine_dashboard/models/arc_time_metric.dart';

/// A widget that displays arc time data as a bar chart with tooltips.
/// Renders the given dataPoints and adapts styling based on timeRange.
class WeeklyBarChart extends StatelessWidget {
  final List<ArcTimeDataPoint> dataPoints;
  final ArcTimeRange timeRange;

  const WeeklyBarChart({
    super.key,
    required this.dataPoints,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    double maxY;
    double yInterval;
    double minY;

    if (timeRange == ArcTimeRange.week || timeRange == ArcTimeRange.month) {
      maxY = 25.0;
      yInterval = 4;
      minY = 0.0;
    } else if (timeRange == ArcTimeRange.year) {
      minY = 90.0;
      maxY = 650.0; // keep 650 to preserve scale
      yInterval = 90.0;
    } else if (dataPoints.isNotEmpty) {
      final double maxValue = dataPoints.map((data) => data.value).reduce((a, b) => a > b ? a : b);
      minY = 0.0;
      if (maxValue <= 0) {
        maxY = 10;
        yInterval = 2;
      } else {
        yInterval = (maxValue / 6 / 10).ceil() * 10.0;
        if (yInterval == 0) yInterval = 10;
        maxY = (maxValue / yInterval).ceil() * yInterval;
        maxY += yInterval * 0.5;
      }
    } else {
      minY = 0.0;
      maxY = 25.0;
      yInterval = 4;
    }

    // --- ADD THIS WRAPPER ---
    // This builder animates the bar heights from 0.0 to 1.0 on load
    // by interpolating the 'toY' value for each bar.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        // --- END OF ADD ---

        return Padding(
          padding: const EdgeInsets.only(top: 10.0), // headroom for top label
          child: BarChart(
            BarChartData(
              minY: minY,
              maxY: maxY,
              backgroundColor: Colors.transparent,
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade900, width: 1.5),
                  top: const BorderSide(color: Colors.transparent, width: 1.5),
                  left: const BorderSide(color: Colors.transparent),
                  right: const BorderSide(color: Colors.transparent),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (value) {
                  if (value >= maxY) return const FlLine(color: Colors.transparent);
                  if (value == 0) return FlLine(color: Colors.grey.shade900, strokeWidth: 1.5);
                  return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= dataPoints.length) return const SizedBox();
                      final String label = dataPoints[index].label;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          label,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.visible,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    interval: yInterval,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value >= meta.max) return const SizedBox();
                      if (timeRange != ArcTimeRange.year && value == 0) return const SizedBox();

                      // top label visible with bottom padding
                      if (value == meta.max) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '${value.toInt()}h',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        );
                      }

                      String label;
                      if (value >= 1000) {
                        label = '${(value / 1000).toStringAsFixed(1)}k';
                      } else {
                        label = '${value.toInt()}h';
                      }

                      return Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12));
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                // --- ADDED THIS SECTION FOR STYLED TOOLTIPS ---
                touchTooltipData: BarTouchTooltipData(
                  // tooltipBackgroundColor: Colors.black,
                  tooltipBorder: const BorderSide(color: Colors.blue, width: 1),
                  tooltipRoundedRadius: 4,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final int dataIndex = group.x.toInt();
                    if (dataIndex < 0 || dataIndex >= dataPoints.length) {
                      return null;
                    }

                    final dataPoint = dataPoints[dataIndex];
                    // --- MODIFICATION: Read the original, non-animated value ---
                    final double value = dataPoint.value;
                    // --- END OF MODIFICATION ---

                    // Format as "20hrs, 29mins"
                    final int totalMinutes = (value * 60).round();
                    final int hoursPart = totalMinutes ~/ 60;
                    final int minutesPart = totalMinutes % 60;
                    final String timeString =
                        '${hoursPart}hrs, ${minutesPart}mins';

                    // Get the label from the data (e.g., "Tue", "02", "mar")
                    String labelString = dataPoint.label;

                    // --- ADDED THIS LOGIC ---
                    // If it's the week view, calculate the specific date
                    if (timeRange == ArcTimeRange.week) {
                      final now = DateTime.now();
                      // Calculate the start of the week (assuming Sunday is index 0)
                      // dataPoint.label "Sun" corresponds to index 0
                      final daysToSubtract = now.weekday % 7; // Sunday=0, Monday=1...
                      final startOfWeek = now.subtract(Duration(days: daysToSubtract));

                      // Get the date for the tapped bar
                      final dateForBar = startOfWeek.add(Duration(days: dataIndex));

                      // Format as "EEE, d MMM" (e.g., "Tue, 11 Feb")
                      labelString = DateFormat('EEE, d MMM').format(dateForBar);
                    }
                    // --- END OF ADDED LOGIC ---

                    return BarTooltipItem(
                      '$timeString\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: labelString, // Use the dynamically set labelString
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                // --- END OF ADDED SECTION ---
                touchCallback: (FlTouchEvent event, BarTouchResponse? response) {},
              ),
              // Pass the animated progress to the bar builder
              barGroups: _buildBarGroups(progress),
            ),
          ),
        );
        // --- ADD THIS ---
      },
    );
    // --- END OF ADD ---
  }

  double _getBarWidth() {
    switch (timeRange) {
      case ArcTimeRange.week:
        return 25;
      case ArcTimeRange.month:
        return 18;
      case ArcTimeRange.year:
        return 20;
      case ArcTimeRange.custom:
        return 20;
    }
  }

  // --- MODIFICATION: Accept the 'progress' value ---
  List<BarChartGroupData> _buildBarGroups([double progress = 1.0]) {
    double barWidth = _getBarWidth();

    return List.generate(dataPoints.length, (index) {
      final dataPoint = dataPoints[index];
      double barValue = dataPoint.value;
      if ((timeRange == ArcTimeRange.week || timeRange == ArcTimeRange.month) && barValue > 24.0) {
        barValue = 24.0;
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            // --- MODIFICATION: Apply the animation progress to the bar height ---
            toY: barValue * progress,
            // --- END OF MODIFICATION ---
            color: Colors.blueAccent,
            width: barWidth,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });
  }
}



