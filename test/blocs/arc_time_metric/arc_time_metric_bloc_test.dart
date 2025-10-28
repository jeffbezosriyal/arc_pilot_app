import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/blocs/arc_time_metric/arc_time_metric_bloc.dart';
import 'package:machine_dashboard/models/arc_time_metric.dart';
import 'package:mocktail/mocktail.dart';
import 'package:machine_dashboard/api/api_exceptions.dart';


import '../../mocks.dart'; // Import mocks

void main() {
  late MockArcTimeService mockArcTimeService;
  late ArcTimeMetricBloc arcTimeMetricBloc;
  late ArcTimeMetric mockMetric;

  // Define a fixed date to use in tests instead of DateTime.now()
  final testDate = DateTime(2025, 10, 24, 12, 0, 0);

  setUp(() {
    mockArcTimeService = MockArcTimeService();
    // Register fallback values for parameters used in mocked service calls
    registerFallbackValue(ArcTimeRange.week);
    registerFallbackValue(testDate);


    arcTimeMetricBloc = ArcTimeMetricBloc(arcTimeService: mockArcTimeService);

    // Mock data using the fixed testDate
    mockMetric = ArcTimeMetric(
      totalArcTime: const Duration(hours: 100),
      lastUpdated: testDate, // Use fixed date
      weeklyData: const [ArcTimeDataPoint(label: 'Mon', value: 10.0)],
      monthlyData: const [ArcTimeDataPoint(label: '01', value: 20.0)],
      yearlyData: const [ArcTimeDataPoint(label: 'Jan', value: 30.0)],
    );
  });

  tearDown(() {
    arcTimeMetricBloc.close();
  });

  test('initial state is correct', () {
    // Use testDate for initial state comparison if relevant
    // The initial state uses DateTime.now(), so direct comparison might still fail
    // Better to check individual properties
    final initialState = ArcTimeMetricState.initial();
    expect(initialState.status, ArcTimeStatus.initial);
    expect(initialState.metric, ArcTimeMetric.initial());
    expect(initialState.errorMessage, isNull);
    expect(initialState.selectedRange, ArcTimeRange.week);
    // We don't compare referenceDate strictly here as it uses DateTime.now()
  });

  group('FetchArcTimeMetric', () {
    // --- Helper to create expected state, ensuring testDate is used ---
    ArcTimeMetricState createExpectedState({
      required ArcTimeStatus status,
      ArcTimeMetric? metric,
      String? errorMessage,
      ArcTimeRange? range,
      DateTime? refDate, // Allow overriding refDate if needed
    }) {
      // Use initial() factory and copyWith to ensure consistency
      return ArcTimeMetricState.initial().copyWith(
        status: status,
        // Use provided metric or initial one if null
        metric: metric ?? ArcTimeMetric.initial(),
        errorMessage: errorMessage,
        // Use provided range or initial one if null
        selectedRange: range ?? ArcTimeRange.week,
        // IMPORTANT: Use the fixed testDate unless overridden
        referenceDate: refDate ?? testDate,
      );
    }


    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'emits [loading, success] when fetch is successful',
      setUp: () {
        // Mock service call with any date/range to return success
        when(() => mockArcTimeService.fetchArcTime(
            date: any(named: 'date'),
            range: any(named: 'range')
        )).thenAnswer((_) async => mockMetric);
      },
      build: () => arcTimeMetricBloc,
      // Use the fixed date in the event
      act: (bloc) => bloc.add(FetchArcTimeMetric(date: testDate)),
      expect: () => <ArcTimeMetricState>[
        // Expect loading state with the correct referenceDate
        createExpectedState(status: ArcTimeStatus.loading),
        // Expect success state with mock metric and correct referenceDate
        createExpectedState(status: ArcTimeStatus.success, metric: mockMetric),
      ],
      verify: (_) {
        // Verify fetch was called once with the correct date and initial range
        verify(() => mockArcTimeService.fetchArcTime(date: testDate, range: ArcTimeRange.week)).called(1);
      },
    );

    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'emits [loading, failure] when fetch fails',
      setUp: () {
        // Mock service call to throw an exception
        when(() => mockArcTimeService.fetchArcTime(
            date: any(named: 'date'),
            range: any(named: 'range')
        )).thenThrow(ApiException('Failed to load'));
      },
      build: () => arcTimeMetricBloc,
      // Use the fixed date in the event
      act: (bloc) => bloc.add(FetchArcTimeMetric(date: testDate)),
      expect: () => <ArcTimeMetricState>[
        // Expect loading state with correct referenceDate
        createExpectedState(status: ArcTimeStatus.loading),
        // --- FIX: Expect error message as String ---
        createExpectedState(
          status: ArcTimeStatus.failure,
          // Compare with the string representation of the exception
          errorMessage: ApiException('Failed to load').toString(),
        ),
        // --- END FIX ---
      ],
      verify: (_) {
        // Verify fetch was called once with the correct date and initial range
        verify(() => mockArcTimeService.fetchArcTime(date: testDate, range: ArcTimeRange.week)).called(1);
      },
    );
  });

  group('UpdateArcTimeRange', () {
    // --- Helper identical to the one above ---
    ArcTimeMetricState createExpectedState({
      required ArcTimeStatus status,
      ArcTimeMetric? metric,
      String? errorMessage,
      ArcTimeRange? range,
      DateTime? refDate,
    }) {
      return ArcTimeMetricState.initial().copyWith(
        status: status,
        metric: metric ?? ArcTimeMetric.initial(),
        errorMessage: errorMessage,
        selectedRange: range ?? ArcTimeRange.week,
        // Use DateTime.now() for the *expected* refDate when range changes
        // because the BLoC resets it to now() in _onUpdateArcTimeRange
        referenceDate: refDate ?? DateTime.now(),
      );
    }

    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'updates range and triggers a successful fetch',
      setUp: () {
        // Mock the fetch call that happens *after* range update
        when(() => mockArcTimeService.fetchArcTime(
          // Expecting 'any' date close to now(), and the new range 'month'
            date: any(named: 'date'),
            range: ArcTimeRange.month
        )).thenAnswer((_) async => mockMetric);
      },
      build: () => arcTimeMetricBloc,
      act: (bloc) => bloc.add(const UpdateArcTimeRange(ArcTimeRange.month)),
      // We cannot predict DateTime.now() exactly, so we use matchers or ignore it
      expect: () => <dynamic>[ // Use dynamic list to allow matchers
        // 1. State with updated range, referenceDate is reset (use matcher)
        isA<ArcTimeMetricState>()
            .having((s) => s.selectedRange, 'selectedRange', ArcTimeRange.month)
            .having((s) => s.status, 'status', ArcTimeStatus.initial) // Status should still be initial here
            .having((s) => s.referenceDate, 'referenceDate', isNotNull), // Check it's set

        // 2. State goes to loading (range persists, refDate persists)
        isA<ArcTimeMetricState>()
            .having((s) => s.selectedRange, 'selectedRange', ArcTimeRange.month)
            .having((s) => s.status, 'status', ArcTimeStatus.loading)
            .having((s) => s.referenceDate, 'referenceDate', isNotNull),

        // 3. Final success state (data, updated range, refDate persists)
        isA<ArcTimeMetricState>()
            .having((s) => s.selectedRange, 'selectedRange', ArcTimeRange.month)
            .having((s) => s.status, 'status', ArcTimeStatus.success)
            .having((s) => s.metric, 'metric', mockMetric) // Check metric data
            .having((s) => s.referenceDate, 'referenceDate', isNotNull),
      ],
      verify: (_) {
        // Verify fetch was called once with *any* date and the *new* range
        verify(() => mockArcTimeService.fetchArcTime(
            date: any(named: 'date'),
            range: ArcTimeRange.month)
        ).called(1);
      },
    );

    // Test case for when the range doesn't change
    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'does not emit new states or fetch if range is the same',
      build: () => arcTimeMetricBloc,
      // Seed state with the same range we're about to dispatch
      seed: () => createExpectedState(status: ArcTimeStatus.success, range: ArcTimeRange.week),
      act: (bloc) => bloc.add(const UpdateArcTimeRange(ArcTimeRange.week)), // Try updating to the same range
      expect: () => <ArcTimeMetricState>[], // Expect no emissions
      verify: (_) {
        // Verify fetch was NOT called
        verifyNever(() => mockArcTimeService.fetchArcTime(
            date: any(named: 'date'),
            range: any(named: 'range'))
        );
      },
    );
  });

  // --- Group for Navigation Events ---
  group('Navigation Events', () {
    // --- Helper (same as above) ---
    ArcTimeMetricState createExpectedState({
      required ArcTimeStatus status,
      ArcTimeMetric? metric,
      String? errorMessage,
      ArcTimeRange? range,
      required DateTime refDate, // Navigation requires specific dates
    }) {
      return ArcTimeMetricState.initial().copyWith(
        status: status,
        metric: metric ?? ArcTimeMetric.initial(),
        errorMessage: errorMessage,
        selectedRange: range ?? ArcTimeRange.week,
        referenceDate: refDate,
      );
    }

    // Test Previous Week
    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'NavigatePreviousPeriod (week) calculates correct date and fetches',
      setUp: () {
        when(() => mockArcTimeService.fetchArcTime(date: any(named: 'date'), range: any(named: 'range')))
            .thenAnswer((_) async => mockMetric);
      },
      build: () => arcTimeMetricBloc,
      // Seed state with the fixed testDate
      seed: () => createExpectedState(status: ArcTimeStatus.success, refDate: testDate, range: ArcTimeRange.week),
      act: (bloc) => bloc.add(NavigatePreviousPeriod()),
      expect: () => <dynamic>[ // Use dynamic + matchers
        // 1. Loading state with the *new* previous week's date
        isA<ArcTimeMetricState>()
            .having((s) => s.status, 'status', ArcTimeStatus.loading)
            .having((s) => s.selectedRange, 'range', ArcTimeRange.week)
            .having((s) => s.referenceDate, 'date', testDate.subtract(const Duration(days: 7))),
        // 2. Success state with the *new* previous week's date
        isA<ArcTimeMetricState>()
            .having((s) => s.status, 'status', ArcTimeStatus.success)
            .having((s) => s.selectedRange, 'range', ArcTimeRange.week)
            .having((s) => s.metric, 'metric', mockMetric)
            .having((s) => s.referenceDate, 'date', testDate.subtract(const Duration(days: 7))),
      ],
      verify: (_) {
        // Verify fetch was called with the calculated previous date
        verify(() => mockArcTimeService.fetchArcTime(
            date: testDate.subtract(const Duration(days: 7)),
            range: ArcTimeRange.week
        )).called(1);
      },
    );

    // Test Next Month
    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'NavigateNextPeriod (month) calculates correct date and fetches',
      setUp: () {
        when(() => mockArcTimeService.fetchArcTime(date: any(named: 'date'), range: any(named: 'range')))
            .thenAnswer((_) async => mockMetric);
      },
      build: () => arcTimeMetricBloc,
      // Seed state with fixed date and month range
      seed: () => createExpectedState(status: ArcTimeStatus.success, refDate: testDate, range: ArcTimeRange.month),
      act: (bloc) => bloc.add(NavigateNextPeriod()),
      expect: () => <dynamic>[
        // 1. Loading state with next month's date
        isA<ArcTimeMetricState>()
            .having((s) => s.status, 'status', ArcTimeStatus.loading)
            .having((s) => s.selectedRange, 'range', ArcTimeRange.month)
            .having((s) => s.referenceDate, 'date', DateTime(testDate.year, testDate.month + 1, testDate.day)),
        // 2. Success state with next month's date
        isA<ArcTimeMetricState>()
            .having((s) => s.status, 'status', ArcTimeStatus.success)
            .having((s) => s.selectedRange, 'range', ArcTimeRange.month)
            .having((s) => s.metric, 'metric', mockMetric)
            .having((s) => s.referenceDate, 'date', DateTime(testDate.year, testDate.month + 1, testDate.day)),
      ],
      verify: (_) {
        // Verify fetch was called with the calculated next date
        verify(() => mockArcTimeService.fetchArcTime(
            date: DateTime(testDate.year, testDate.month + 1, testDate.day),
            range: ArcTimeRange.month
        )).called(1);
      },
    );

    // Test Previous Year
    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'NavigatePreviousPeriod (year) calculates correct date and fetches',
      setUp: () {
        when(() => mockArcTimeService.fetchArcTime(date: any(named: 'date'), range: any(named: 'range')))
            .thenAnswer((_) async => mockMetric);
      },
      build: () => arcTimeMetricBloc,
      // Seed state with fixed date and year range
      seed: () => createExpectedState(status: ArcTimeStatus.success, refDate: testDate, range: ArcTimeRange.year),
      act: (bloc) => bloc.add(NavigatePreviousPeriod()),
      expect: () => <dynamic>[
        // 1. Loading state with previous year's date
        isA<ArcTimeMetricState>()
            .having((s) => s.status, 'status', ArcTimeStatus.loading)
            .having((s) => s.selectedRange, 'range', ArcTimeRange.year)
            .having((s) => s.referenceDate, 'date', DateTime(testDate.year - 1, testDate.month, testDate.day)),
        // 2. Success state with previous year's date
        isA<ArcTimeMetricState>()
            .having((s) => s.status, 'status', ArcTimeStatus.success)
            .having((s) => s.selectedRange, 'range', ArcTimeRange.year)
            .having((s) => s.metric, 'metric', mockMetric)
            .having((s) => s.referenceDate, 'date', DateTime(testDate.year - 1, testDate.month, testDate.day)),
      ],
      verify: (_) {
        // Verify fetch was called with the calculated previous date
        verify(() => mockArcTimeService.fetchArcTime(
            date: DateTime(testDate.year - 1, testDate.month, testDate.day),
            range: ArcTimeRange.year
        )).called(1);
      },
    );

    // Test that Custom range navigation does nothing
    blocTest<ArcTimeMetricBloc, ArcTimeMetricState>(
      'NavigatePreviousPeriod (custom) does not emit or fetch',
      build: () => arcTimeMetricBloc,
      seed: () => createExpectedState(status: ArcTimeStatus.success, refDate: testDate, range: ArcTimeRange.custom),
      act: (bloc) => bloc.add(NavigatePreviousPeriod()),
      expect: () => <ArcTimeMetricState>[], // No state changes expected
      verify: (_) {
        verifyNever(() => mockArcTimeService.fetchArcTime(date: any(named: 'date'), range: any(named: 'range')));
      },
    );
  });
}

