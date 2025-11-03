import 'package:equatable/equatable.dart';
import 'package:clock/clock.dart'; // <<< ADD THIS IMPORT

/// Represents a single data point for the bar chart.
class ArcTimeDataPoint extends Equatable {
  final String label; // e.g., "Mon", "Jan", "2023"
  final double value; // e.g., 8.5 (hours), 120.5 (hours), 1500.0 (hours)

  const ArcTimeDataPoint({required this.label, required this.value});

  /// Creates a data point from a JSON map (e.g., {"label": "Mon", "value": 8.5})
  factory ArcTimeDataPoint.fromJson(Map<String, dynamic> json) {
    return ArcTimeDataPoint(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object> get props => [label, value];
}

/// Represents the data model for the Arc Time Metric.
/// Fetched from the /api/arctime endpoint.
class ArcTimeMetric extends Equatable {
  final Duration totalArcTime;
  final DateTime lastUpdated;
  final List<ArcTimeDataPoint> weeklyData;   // Data for the week view
  final List<ArcTimeDataPoint> monthlyData;  // Data for the month view
  final List<ArcTimeDataPoint> yearlyData;   // Data for the year view

  const ArcTimeMetric({
    required this.totalArcTime,
    required this.lastUpdated,
    required this.weeklyData,
    required this.monthlyData,
    required this.yearlyData,
  });

  /// Creates a [ArcTimeMetric] from a JSON map.
  factory ArcTimeMetric.fromJson(Map<String, dynamic> json) {
    final int seconds = json['totalArcTimeInSeconds'] ?? 0;
    // Use clock.now() for consistency if lastUpdated is null
    final String dateString = json['lastUpdated'] ?? clock.now().toIso8601String();

    // Helper function to parse data points
    List<ArcTimeDataPoint> parseDataPoints(List<dynamic>? dataList) {
      if (dataList == null) return [];
      return dataList
          .map((item) => ArcTimeDataPoint.fromJson(item))
          .toList();
    }

    // Parse all three data lists from the JSON
    final List<ArcTimeDataPoint> weekly = parseDataPoints(json['weeklyData']);
    final List<ArcTimeDataPoint> monthly = parseDataPoints(json['monthlyData']);
    final List<ArcTimeDataPoint> yearly = parseDataPoints(json['yearlyData']);

    return ArcTimeMetric(
      totalArcTime: Duration(seconds: seconds),
      lastUpdated: DateTime.parse(dateString),
      weeklyData: weekly,
      monthlyData: monthly,
      yearlyData: yearly,
    );
  }

  /// Creates a default/initial state for the metric.
  // --- PATCH: Added {Clock? injectedClock} ---
  factory ArcTimeMetric.initial({Clock? injectedClock}) {
    // Helper to generate empty points
    List<ArcTimeDataPoint> generateInitialPoints(List<String> labels) {
      return labels.map((label) => ArcTimeDataPoint(label: label, value: 0.0)).toList();
    }

    return ArcTimeMetric(
      totalArcTime: Duration.zero,
      // --- PATCH: Use injected clock or global clock ---
      lastUpdated: (injectedClock ?? clock).now(),
      weeklyData: generateInitialPoints(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']),
      monthlyData: generateInitialPoints(List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'))), // Days 01-31
      yearlyData: generateInitialPoints(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']),
    );
  }

  // Helper method for testing
  ArcTimeMetric copyWith({
    Duration? totalArcTime,
    DateTime? lastUpdated,
    List<ArcTimeDataPoint>? weeklyData,
    List<ArcTimeDataPoint>? monthlyData,
    List<ArcTimeDataPoint>? yearlyData,
  }) {
    return ArcTimeMetric(
      totalArcTime: totalArcTime ?? this.totalArcTime,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      weeklyData: weeklyData ?? this.weeklyData,
      monthlyData: monthlyData ?? this.monthlyData,
      yearlyData: yearlyData ?? this.yearlyData,
    );
  }


  @override
  List<Object> get props => [
    totalArcTime,
    // lastUpdated, // <-- EXCLUDED
    weeklyData,
    monthlyData,
    yearlyData
  ];
}