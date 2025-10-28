import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:machine_dashboard/models/arc_time_metric.dart';
import 'package:machine_dashboard/services/arc_time_service.dart';
part 'arc_time_metric_event.dart';
part 'arc_time_metric_state.dart';


class ArcTimeMetricBloc extends Bloc<ArcTimeMetricEvent, ArcTimeMetricState> {
  final ArcTimeService _arcTimeService;

  ArcTimeMetricBloc({required ArcTimeService arcTimeService})
      : _arcTimeService = arcTimeService,
        super(ArcTimeMetricState.initial()) {

    // Register the event handlers
    on<FetchArcTimeMetric>(_onFetchArcTime);
    on<UpdateArcTimeRange>(_onUpdateArcTimeRange);
    on<NavigatePreviousPeriod>(_onNavigatePrevious); // <-- ADDED HANDLER
    on<NavigateNextPeriod>(_onNavigateNext);       // <-- ADDED HANDLER
  }

  /// Handles the event to fetch arc time data for a specific date/range
  Future<void> _onFetchArcTime(
      FetchArcTimeMetric event,
      Emitter<ArcTimeMetricState> emit,
      ) async {

    // Determine the reference date: use event date if provided, otherwise current state's date
    final DateTime dateToFetch = event.date ?? state.referenceDate;

    // Emit a loading state, preserving range and setting the *new* reference date
    emit(state.copyWith(
        status: ArcTimeStatus.loading,
        referenceDate: dateToFetch // Ensure state reflects the date being fetched
    ));

    try {
      // --- UPDATE: Pass date and range to the service ---
      final metric = await _arcTimeService.fetchArcTime(
          date: dateToFetch,
          range: state.selectedRange
      );
      // --- END UPDATE ---

      // Emit a success state with the new data and confirmed reference date
      emit(state.copyWith(
        status: ArcTimeStatus.success,
        metric: metric,
        referenceDate: dateToFetch, // Explicitly set the date for success state
      ));
    } catch (e) {
      // Emit a failure state with the error message, keeping the reference date
      emit(state.copyWith(
        status: ArcTimeStatus.failure,
        errorMessage: e.toString(),
        referenceDate: dateToFetch, // Keep the date that failed
      ));
    }
  }

  /// Handles the event to update the selected time range
  Future<void> _onUpdateArcTimeRange(
      UpdateArcTimeRange event,
      Emitter<ArcTimeMetricState> emit,
      ) async {
    // Only update if the range actually changed
    if (event.newRange != state.selectedRange) {
      // Emit the new range immediately for UI feedback
      // Reset reference date to 'now' when range changes? Or keep current period?
      // Let's reset to now for simplicity.
      final newReferenceDate = DateTime.now();
      emit(state.copyWith(
          selectedRange: event.newRange,
          referenceDate: newReferenceDate
      ));

      // Trigger a data fetch for the new range and current date
      add(FetchArcTimeMetric(date: newReferenceDate));
    }
  }

  // --- NEW METHOD: Handle Previous Navigation ---
  void _onNavigatePrevious(
      NavigatePreviousPeriod event,
      Emitter<ArcTimeMetricState> emit,
      ) {
    DateTime newReferenceDate = state.referenceDate;
    switch (state.selectedRange) {
      case ArcTimeRange.week:
      // Subtract 7 days
        newReferenceDate = state.referenceDate.subtract(const Duration(days: 7));
        break;
      case ArcTimeRange.month:
      // Subtract 1 month
        newReferenceDate = DateTime(state.referenceDate.year, state.referenceDate.month - 1, state.referenceDate.day);
        break;
      case ArcTimeRange.year:
      // Subtract 1 year
        newReferenceDate = DateTime(state.referenceDate.year - 1, state.referenceDate.month, state.referenceDate.day);
        break;
      case ArcTimeRange.custom:
      // Navigation not defined for custom range yet
        return;
    }
    // Trigger fetch for the new date
    add(FetchArcTimeMetric(date: newReferenceDate));
  }
  // --- END NEW METHOD ---

  // --- NEW METHOD: Handle Next Navigation ---
  void _onNavigateNext(
      NavigateNextPeriod event,
      Emitter<ArcTimeMetricState> emit,
      ) {
    DateTime newReferenceDate = state.referenceDate;
    switch (state.selectedRange) {
      case ArcTimeRange.week:
      // Add 7 days
        newReferenceDate = state.referenceDate.add(const Duration(days: 7));
        break;
      case ArcTimeRange.month:
      // Add 1 month
        newReferenceDate = DateTime(state.referenceDate.year, state.referenceDate.month + 1, state.referenceDate.day);
        break;
      case ArcTimeRange.year:
      // Add 1 year
        newReferenceDate = DateTime(state.referenceDate.year + 1, state.referenceDate.month, state.referenceDate.day);
        break;
      case ArcTimeRange.custom:
      // Navigation not defined for custom range yet
        return;
    }

    // Optional: Prevent navigating into the future?
    // if (newReferenceDate.isAfter(DateTime.now())) {
    //   return; // Or maybe fetch for DateTime.now()?
    // }

    // Trigger fetch for the new date
    add(FetchArcTimeMetric(date: newReferenceDate));
  }
// --- END NEW METHOD ---
}
