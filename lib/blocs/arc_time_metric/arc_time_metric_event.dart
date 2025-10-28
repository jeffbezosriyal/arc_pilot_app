part of 'arc_time_metric_bloc.dart'; // Keep this directive

// --- Defines the possible time ranges for the chart ---
enum ArcTimeRange { week, month, year, custom }

// --- Base class for all ArcTimeMetric events ---
abstract class ArcTimeMetricEvent extends Equatable {
  const ArcTimeMetricEvent();

  @override
  List<Object?> get props => []; // Allow nullable objects
}

// --- Event to load or refresh data for a specific date/range ---
/// Event triggered to fetch the arc time data from the repository.
/// Can optionally include a specific date to fetch for.
class FetchArcTimeMetric extends ArcTimeMetricEvent {
  final DateTime? date; // <-- ADDED: Optional date parameter

  const FetchArcTimeMetric({this.date}); // <-- UPDATED constructor

  @override
  List<Object?> get props => [date]; // <-- UPDATED props
}


// --- Event to change the chart's time range ---
/// Event triggered to change the selected time range for the chart.
class UpdateArcTimeRange extends ArcTimeMetricEvent {
  final ArcTimeRange newRange;

  const UpdateArcTimeRange(this.newRange); // Constructor

  @override
  List<Object> get props => [newRange];
}

// --- Events for navigating periods ---
/// Event triggered when the 'previous' arrow is tapped.
class NavigatePreviousPeriod extends ArcTimeMetricEvent {}

/// Event triggered when the 'next' arrow is tapped.
class NavigateNextPeriod extends ArcTimeMetricEvent {}
