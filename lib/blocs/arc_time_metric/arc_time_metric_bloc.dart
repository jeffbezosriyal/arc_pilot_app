import 'package:bloc/bloc.dart';
import 'package:clock/clock.dart'; // <<< IMPORT MOVED HERE
import 'package:equatable/equatable.dart';
import 'package:machine_dashboard/models/arc_time_metric.dart';
import 'package:machine_dashboard/services/arc_time_service.dart';
part 'arc_time_metric_event.dart';
part 'arc_time_metric_state.dart';


class ArcTimeMetricBloc extends Bloc<ArcTimeMetricEvent, ArcTimeMetricState> {
  final ArcTimeService _arcTimeService;
  final Clock _clock;

  ArcTimeMetricBloc({
    required ArcTimeService arcTimeService,
    Clock? clock,
  })  : _arcTimeService = arcTimeService,
        _clock = clock ?? const Clock(),
        super(ArcTimeMetricState.initial(injectedClock: clock ?? const Clock())) {

    // Register the event handlers
    on<FetchArcTimeMetric>(_onFetchArcTime);
    on<UpdateArcTimeRange>(_onUpdateArcTimeRange);
    on<NavigatePreviousPeriod>(_onNavigatePrevious);
    on<NavigateNextPeriod>(_onNavigateNext);
  }

  /// Handles the event to fetch arc time data for a specific date/range
  Future<void> _onFetchArcTime(
      FetchArcTimeMetric event,
      Emitter<ArcTimeMetricState> emit,
      ) async {

    final DateTime dateToFetch = event.date ?? state.referenceDate;

    emit(state.copyWith(
        status: ArcTimeStatus.loading,
        referenceDate: dateToFetch
    ));

    try {
      // --- MODIFICATION: RESTORED 'range' parameter ---
      final metric = await _arcTimeService.fetchArcTime(
          date: dateToFetch,
          range: state.selectedRange // <-- This parameter is restored
      );
      // --- END MODIFICATION ---

      emit(state.copyWith(
        status: ArcTimeStatus.success,
        metric: metric,
        referenceDate: dateToFetch,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ArcTimeStatus.failure,
        errorMessage: e.toString(), // Use e.toString()
        referenceDate: dateToFetch,
      ));
    }
  }

  /// Handles the event to update the selected time range
  Future<void> _onUpdateArcTimeRange(
      UpdateArcTimeRange event,
      Emitter<ArcTimeMetricState> emit,
      ) async {
    // Only emit if the range has actually changed
    if (event.newRange != state.selectedRange) {

      // --- MODIFICATION ---
      // This logic is now correct. The API requires the range,
      // so we must trigger a new fetch when the range changes.
      // We also reset the date to 'now' when changing ranges.
      final newReferenceDate = _clock.now();

      emit(state.copyWith(
          selectedRange: event.newRange,
          referenceDate: newReferenceDate
      ));

      add(FetchArcTimeMetric(date: newReferenceDate));
      // --- END MODIFICATION ---
    }
  }

  void _onNavigatePrevious(
      NavigatePreviousPeriod event,
      Emitter<ArcTimeMetricState> emit,
      ) {
    DateTime newReferenceDate = state.referenceDate;
    switch (state.selectedRange) {
      case ArcTimeRange.week:
        newReferenceDate = state.referenceDate.subtract(const Duration(days: 7));
        break;
      case ArcTimeRange.month:
        newReferenceDate = DateTime(state.referenceDate.year, state.referenceDate.month - 1, state.referenceDate.day);
        break;
      case ArcTimeRange.year:
        newReferenceDate = DateTime(state.referenceDate.year - 1, state.referenceDate.month, state.referenceDate.day);
        break;
      case ArcTimeRange.custom:
        return;
    }
    add(FetchArcTimeMetric(date: newReferenceDate));
  }

  void _onNavigateNext(
      NavigateNextPeriod event,
      Emitter<ArcTimeMetricState> emit,
      ) {
    DateTime newReferenceDate = state.referenceDate;
    switch (state.selectedRange) {
      case ArcTimeRange.week:
        newReferenceDate = state.referenceDate.add(const Duration(days: 7));
        break;
      case ArcTimeRange.month:
        newReferenceDate = DateTime(state.referenceDate.year, state.referenceDate.month + 1, state.referenceDate.day);
        break;
      case ArcTimeRange.year:
        newReferenceDate = DateTime(state.referenceDate.year + 1, state.referenceDate.month, state.referenceDate.day);
        break;
      case ArcTimeRange.custom:
        return;
    }
    add(FetchArcTimeMetric(date: newReferenceDate));
  }
}