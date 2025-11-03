import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart'; // Still need this for Clock.fixed
import 'package:machine_dashboard/api/api_exceptions.dart';
import 'package:machine_dashboard/blocs/arc_time_metric/arc_time_metric_bloc.dart';
import 'package:machine_dashboard/models/arc_time_metric.dart';
import 'package:mockito/mockito.dart';

import '../../mocks.mocks.dart';

// Helper matcher for DateTime equality within a threshold
Matcher equalsDateTime(DateTime expected, {Duration threshold = const Duration(milliseconds: 10)}) {
  return predicate<DateTime?>((actual) { // Allow nullable actual for safety
    if (actual == null) return false;
    return actual.difference(expected).abs() < threshold;
  }, 'is within $threshold of $expected');
}


void main() {
  late MockArcTimeService mockArcTimeService;
  final fakeNow = DateTime(2023, 10, 27, 10, 0, 0);
  final fakeClock = Clock.fixed(fakeNow);

  // Expected initial state - created using the fake clock
  // Uses the patched ArcTimeMetricState.initial factory
  final initialState = ArcTimeMetricState.initial(injectedClock: fakeClock);

  // Helper metric
  final mockMetric = ArcTimeMetric(
    totalArcTime: const Duration(hours: 10),
    lastUpdated: fakeNow, // Match clock
    weeklyData: const [ArcTimeDataPoint(label: 'Mon', value: 1.0)],
    monthlyData: const [],
    yearlyData: const [],
  );

  setUp(() {
    mockArcTimeService = MockArcTimeService();
    // Stub default successful fetch
    when(mockArcTimeService.fetchArcTime(
      date: anyNamed('date'),
      range: anyNamed('range'),
    )).thenAnswer((_) async => mockMetric);
  });


  group('ArcTimeMetricBloc', () {
    test('initial state is correct', () {
      // Create the BLoC, explicitly passing the fakeClock
      final bloc = ArcTimeMetricBloc(arcTimeService: mockArcTimeService, clock: fakeClock);
      final actualState = bloc.state;
      bloc.close();

      // Compare against the pre-defined initialState
      expect(actualState, initialState);
      expect(actualState.status, ArcTimeStatus.initial);
      expect(actualState.selectedRange, ArcTimeRange.week);
      expect(actualState.errorMessage, isNull);
      expect(actualState.referenceDate, equalsDateTime(fakeNow));
      expect(actualState.metric.lastUpdated, equalsDateTime(fakeNow));
    });

    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'FetchArcTimeMetric: emits [loading, success] on successful fetch',
      // Ensure BLoC is built with the fakeClock
      build: () => ArcTimeMetricBloc(arcTimeService: mockArcTimeService, clock: fakeClock),
      act: (bloc) => bloc.add(FetchArcTimeMetric(date: fakeNow)),
      expect: () => [
        isA<ArcTimeMetricState>()
            .having((s) => s.status, 'status', ArcTimeStatus.loading)
            .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(fakeNow)),
        isA<ArcTimeMetricState>()
            .having((s) => s.status, 'status', ArcTimeStatus.success)
            .having((s) => s.metric, 'metric', mockMetric)
            .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(fakeNow))
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
      verify: (_) {
        verify(mockArcTimeService.fetchArcTime(
          date: fakeNow,
          range: ArcTimeRange.week,
        )).called(1);
      },
    );

    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'FetchArcTimeMetric: emits [loading, failure] on error',
      build: () {
        when(mockArcTimeService.fetchArcTime(
          date: anyNamed('date'),
          range: anyNamed('range'),
        )).thenThrow(ApiException('Network Error'));
        // Ensure BLoC is built with the fakeClock
        return ArcTimeMetricBloc(arcTimeService: mockArcTimeService, clock: fakeClock);
      },
      act: (bloc) => bloc.add(FetchArcTimeMetric(date: fakeNow)),
      expect: () => [
        isA<ArcTimeMetricState>()
            .having((s) => s.status, 'status', ArcTimeStatus.loading)
            .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(fakeNow)),
        isA<ArcTimeMetricState>()
            .having((s) => s.status, 'status', ArcTimeStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Network Error')
            .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(fakeNow)),
      ],
    );

    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'UpdateArcTimeRange: updates range, resets date to fakeNow, and re-fetches',
      // Ensure BLoC is built with the fakeClock
      build: () => ArcTimeMetricBloc(arcTimeService: mockArcTimeService, clock: fakeClock),
      act: (bloc) => bloc.add(const UpdateArcTimeRange(ArcTimeRange.month)),
      expect: () => [
        isA<ArcTimeMetricState>()
            .having((s) => s.selectedRange, 'selectedRange', ArcTimeRange.month)
        // BLoC uses injected _clock.now() which is fakeNow
            .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(fakeNow)),
        isA<ArcTimeMetricState>()
            .having((s) => s.selectedRange, 'selectedRange', ArcTimeRange.month)
            .having((s) => s.status, 'status', ArcTimeStatus.loading)
            .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(fakeNow)),
        isA<ArcTimeMetricState>()
            .having((s) => s.selectedRange, 'selectedRange', ArcTimeRange.month)
            .having((s) => s.status, 'status', ArcTimeStatus.success)
            .having((s) => s.metric, 'metric', mockMetric)
            .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(fakeNow))
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
      verify: (_) {
        verify(mockArcTimeService.fetchArcTime(
          // BLoC._onUpdateArcTimeRange uses _clock.now() -> fakeNow
          date: fakeNow,
          range: ArcTimeRange.month,
        )).called(1);
      },
    );

    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'UpdateArcTimeRange: does nothing if range is the same',
      // Ensure BLoC is built with the fakeClock
      build: () => ArcTimeMetricBloc(arcTimeService: mockArcTimeService, clock: fakeClock),
      act: (bloc) => bloc.add(const UpdateArcTimeRange(ArcTimeRange.week)), // Initial range is week
      expect: () => [],
      verify: (_) {
        verifyNever(mockArcTimeService.fetchArcTime(
          date: anyNamed('date'),
          range: anyNamed('range'),
        ));
      },
    );

    // --- Test Navigation Events ---

    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'NavigatePreviousPeriod: (Week) subtracts 7 days and re-fetches',
      // Ensure BLoC is built with the fakeClock
      build: () => ArcTimeMetricBloc(arcTimeService: mockArcTimeService, clock: fakeClock),
      act: (bloc) => bloc.add(NavigatePreviousPeriod()),
      expect: () {
        final newDate = fakeNow.subtract(const Duration(days: 7));
        return [
          isA<ArcTimeMetricState>()
              .having((s) => s.status, 'status', ArcTimeStatus.loading)
              .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(newDate)),
          isA<ArcTimeMetricState>()
              .having((s) => s.status, 'status', ArcTimeStatus.success)
              .having((s) => s.metric, 'metric', mockMetric)
              .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(newDate))
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ];
      },
      verify: (_) {
        final newDate = fakeNow.subtract(const Duration(days: 7));
        verify(mockArcTimeService.fetchArcTime(
          date: newDate,
          range: ArcTimeRange.week,
        )).called(1);
      },
    );

    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'NavigateNextPeriod: (Month) adds 1 month and re-fetches',
      // Ensure BLoC is built with the fakeClock
      build: () => ArcTimeMetricBloc(arcTimeService: mockArcTimeService, clock: fakeClock),
      // Seed uses initialState which was created with fakeClock
      seed: () => initialState.copyWith(selectedRange: ArcTimeRange.month),
      act: (bloc) => bloc.add(NavigateNextPeriod()),
      expect: () {
        final newDate = DateTime(fakeNow.year, fakeNow.month + 1, fakeNow.day);
        return [
          isA<ArcTimeMetricState>()
              .having((s) => s.status, 'status', ArcTimeStatus.loading)
              .having((s) => s.selectedRange, 'selectedRange', ArcTimeRange.month)
              .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(newDate)),
          isA<ArcTimeMetricState>()
              .having((s) => s.status, 'status', ArcTimeStatus.success)
              .having((s) => s.selectedRange, 'selectedRange', ArcTimeRange.month)
              .having((s) => s.metric, 'metric', mockMetric)
              .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(newDate))
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ];
      },
      verify: (_) {
        final newDate = DateTime(fakeNow.year, fakeNow.month + 1, fakeNow.day);
        verify(mockArcTimeService.fetchArcTime(
          date: newDate,
          range: ArcTimeRange.month,
        )).called(1);
      },
    );

    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'NavigatePreviousPeriod: (Year) subtracts 1 year and re-fetches',
      // Ensure BLoC is built with the fakeClock
      build: () => ArcTimeMetricBloc(arcTimeService: mockArcTimeService, clock: fakeClock),
      seed: () => initialState.copyWith(selectedRange: ArcTimeRange.year),
      act: (bloc) => bloc.add(NavigatePreviousPeriod()),
      expect: () {
        final newDate = DateTime(fakeNow.year - 1, fakeNow.month, fakeNow.day);
        return [
          isA<ArcTimeMetricState>()
              .having((s) => s.status, 'status', ArcTimeStatus.loading)
              .having((s) => s.selectedRange, 'selectedRange', ArcTimeRange.year)
              .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(newDate)),
          isA<ArcTimeMetricState>()
              .having((s) => s.status, 'status', ArcTimeStatus.success)
              .having((s) => s.selectedRange, 'selectedRange', ArcTimeRange.year)
              .having((s) => s.metric, 'metric', mockMetric)
              .having((s) => s.referenceDate, 'referenceDate', equalsDateTime(newDate))
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ];
      },
      verify: (_) {
        final newDate = DateTime(fakeNow.year - 1, fakeNow.month, fakeNow.day);
        verify(mockArcTimeService.fetchArcTime(
          date: newDate,
          range: ArcTimeRange.year,
        )).called(1);
      },
    );

    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'NavigatePreviousPeriod: (Custom) does nothing',
      // Ensure BLoC is built with the fakeClock
      build: () => ArcTimeMetricBloc(arcTimeService: mockArcTimeService, clock: fakeClock),
      seed: () => initialState.copyWith(selectedRange: ArcTimeRange.custom),
      act: (bloc) => bloc.add(NavigatePreviousPeriod()),
      expect: () => [],
      verify: (_) {
        verifyNever(mockArcTimeService.fetchArcTime(
          date: anyNamed('date'),
          range: anyNamed('range'),
        ));
      },
    );

    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'NavigateNextPeriod: (Custom) does nothing',
      // Ensure BLoC is built with the fakeClock
      build: () => ArcTimeMetricBloc(arcTimeService: mockArcTimeService, clock: fakeClock),
      seed: () => initialState.copyWith(selectedRange: ArcTimeRange.custom),
      act: (bloc) => bloc.add(NavigateNextPeriod()),
      expect: () => [],
      verify: (_) {
        verifyNever(mockArcTimeService.fetchArcTime(
          date: anyNamed('date'),
          range: anyNamed('range'),
        ));
      },
    );
  });
}