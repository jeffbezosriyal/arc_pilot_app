import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/models/arc_time_metric.dart';

void main() {
  group('ArcTimeDataPoint', () {
    test('fromJson handles complete data', () {
      final json = {'label': 'Mon', 'value': 8.5};
      final dataPoint = ArcTimeDataPoint.fromJson(json);

      expect(dataPoint.label, 'Mon');
      expect(dataPoint.value, 8.5);
    });

    test('fromJson handles missing/null data', () {
      final json = {'label': null, 'value': null};
      final dataPoint = ArcTimeDataPoint.fromJson(json);

      expect(dataPoint.label, '');
      expect(dataPoint.value, 0.0);
    });

    test('fromJson handles integer value', () {
      final json = {'label': 'Tue', 'value': 7};
      final dataPoint = ArcTimeDataPoint.fromJson(json);

      expect(dataPoint.label, 'Tue');
      expect(dataPoint.value, 7.0); // Should convert int to double
    });

    test('props are correct for Equatable', () {
      const dataPoint = ArcTimeDataPoint(label: 'Wed', value: 1.2);
      expect(dataPoint.props, ['Wed', 1.2]);
    });
  });

  group('ArcTimeMetric', () {
    final mockWeeklyData = [
      {'label': 'Mon', 'value': 1.0},
      {'label': 'Tue', 'value': 2.0}
    ];
    final mockMonthlyData = [
      {'label': '01', 'value': 10.0}
    ];
    final mockYearlyData = [
      {'label': 'Jan', 'value': 100.0}
    ];

    final mockJson = {
      'totalArcTimeInSeconds': 3661, // 1 hour, 1 minute, 1 second
      'lastUpdated': '2023-10-27T10:00:00.000Z',
      'weeklyData': mockWeeklyData,
      'monthlyData': mockMonthlyData,
      'yearlyData': mockYearlyData,
    };

    test('fromJson handles complete data', () {
      final metric = ArcTimeMetric.fromJson(mockJson);

      expect(metric.totalArcTime, const Duration(seconds: 3661));
      expect(metric.lastUpdated, DateTime.parse('2023-10-27T10:00:00.000Z'));
      expect(metric.weeklyData.length, 2);
      expect(metric.weeklyData[0].label, 'Mon');
      expect(metric.weeklyData[0].value, 1.0);
      expect(metric.monthlyData.length, 1);
      expect(metric.monthlyData[0].label, '01');
      expect(metric.monthlyData[0].value, 10.0);
      expect(metric.yearlyData.length, 1);
      expect(metric.yearlyData[0].label, 'Jan');
      expect(metric.yearlyData[0].value, 100.0);
    });

    test('fromJson handles missing/null data', () {
      final json = {
        'totalArcTimeInSeconds': null,
        'lastUpdated': null,
        'weeklyData': null,
        'monthlyData': null,
        'yearlyData': null,
      };

      final metric = ArcTimeMetric.fromJson(json);

      expect(metric.totalArcTime, Duration.zero);
      // lastUpdated should parse to "now" (we can't test "now", so we check it's recent)
      expect(
          DateTime.now().difference(metric.lastUpdated),
          lessThan(
              const Duration(seconds: 2))); // Check it's very recent
      expect(metric.weeklyData, isEmpty);
      expect(metric.monthlyData, isEmpty);
      expect(metric.yearlyData, isEmpty);
    });

    test('initial factory creates correct default state', () {
      final metric = ArcTimeMetric.initial();

      expect(metric.totalArcTime, Duration.zero);
      expect(
          DateTime.now().difference(metric.lastUpdated),
          lessThan(
              const Duration(seconds: 2))); // Check it's very recent
      expect(metric.weeklyData.length, 7);
      expect(metric.weeklyData[0].label, 'Mon');
      expect(metric.weeklyData[0].value, 0.0);
      expect(metric.monthlyData.length, 31);
      expect(metric.monthlyData[0].label, '01');
      expect(metric.monthlyData[0].value, 0.0);
      expect(metric.yearlyData.length, 12);
      expect(metric.yearlyData[0].label, 'Jan');
      expect(metric.yearlyData[0].value, 0.0);
    });

    test('props are correct for Equatable', () {
      final metric = ArcTimeMetric.fromJson(mockJson);
      // 'lastUpdated' is intentionally excluded from props in the production model
      // to prevent unnecessary UI rebuilds if only the timestamp changes.
      expect(metric.props, [
        metric.totalArcTime,
        metric.weeklyData,
        metric.monthlyData,
        metric.yearlyData
      ]);
    });
  });
}