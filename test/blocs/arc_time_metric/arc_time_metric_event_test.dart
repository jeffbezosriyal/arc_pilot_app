import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/blocs/arc_time_metric/arc_time_metric_bloc.dart';

void main() {
  group('ArcTimeMetricEvent', () {

    group('FetchArcTimeMetric', () {
      test('supports value equality when date is null', () {
        // Test constructor with no date
        expect(
          const FetchArcTimeMetric(),
          equals(const FetchArcTimeMetric()),
        );
      });

      test('supports value equality when date is provided', () {
        final date = DateTime(2023, 1, 1);
        expect(
          FetchArcTimeMetric(date: date),
          equals(FetchArcTimeMetric(date: date)),
        );
      });

      test('props are correct when date is null', () {
        // props list should contain [null]
        expect(const FetchArcTimeMetric().props, [null]);
      });

      test('props are correct when date is provided', () {
        final date = DateTime(2023, 1, 1);
        expect(FetchArcTimeMetric(date: date).props, [date]);
      });
      // Test inequality
      test('instances with different dates are not equal', () {
        final date1 = DateTime(2023, 1, 1);
        final date2 = DateTime(2023, 1, 2);
        expect(FetchArcTimeMetric(date: date1), isNot(FetchArcTimeMetric(date: date2)));
      });
      test('instance with date is not equal to instance without date', () {
        final date1 = DateTime(2023, 1, 1);
        expect(FetchArcTimeMetric(date: date1), isNot(const FetchArcTimeMetric()));
      });

    });

    group('UpdateArcTimeRange', () {
      test('supports value equality', () {
        expect(
          const UpdateArcTimeRange(ArcTimeRange.week),
          equals(const UpdateArcTimeRange(ArcTimeRange.week)),
        );
      });

      test('instances with different ranges are not equal', () {
        expect(
          const UpdateArcTimeRange(ArcTimeRange.week),
          isNot(const UpdateArcTimeRange(ArcTimeRange.month)),
        );
      });

      test('props are correct', () {
        expect(
          const UpdateArcTimeRange(ArcTimeRange.month).props,
          [ArcTimeRange.month],
        );
      });
    });

    group('NavigatePreviousPeriod', () {
      test('supports value equality', () {
        expect(NavigatePreviousPeriod(), equals(NavigatePreviousPeriod()));
      });

      test('props are empty', () {
        expect(NavigatePreviousPeriod().props, isEmpty);
      });
    });

    group('NavigateNextPeriod', () {
      test('supports value equality', () {
        expect(NavigateNextPeriod(), equals(NavigateNextPeriod()));
      });

      test('props are empty', () {
        expect(NavigateNextPeriod().props, isEmpty);
      });
    });

    // Test base class coverage (optional but good practice)
    test('Base ArcTimeMetricEvent props is correct', () {
      // Create an instance of a concrete class to test the base class logic if needed
      // Although typically covered by testing subclasses
      expect(const FetchArcTimeMetric().props, isNotNull);
    });

  });
}