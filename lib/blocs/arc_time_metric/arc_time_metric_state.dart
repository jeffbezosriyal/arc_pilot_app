part of 'arc_time_metric_bloc.dart'; // Keep this directive

// <<< IMPORT REMOVED FROM HERE ---

// Enum to represent the status of the data fetching
enum ArcTimeStatus { initial, loading, success, failure }

class ArcTimeMetricState extends Equatable {
  final ArcTimeStatus status;
  final ArcTimeMetric metric;
  final String? errorMessage;
  final ArcTimeRange selectedRange; // Stores the current range
  final DateTime referenceDate;

  const ArcTimeMetricState({
    this.status = ArcTimeStatus.initial,
    required this.metric,
    this.errorMessage,
    this.selectedRange = ArcTimeRange.week,
    required this.referenceDate,
  });

  // Factory constructor for the initial state
  factory ArcTimeMetricState.initial({Clock? injectedClock}) {
    final clk = injectedClock ?? clock; // Use injected or global clock
    return ArcTimeMetricState(
      status: ArcTimeStatus.initial,
      // Pass clock down to metric
      metric: ArcTimeMetric.initial(injectedClock: clk),
      errorMessage: null,
      selectedRange: ArcTimeRange.week,
      // Use clock for referenceDate
      referenceDate: clk.now(),
    );
  }

  ArcTimeMetricState copyWith({
    ArcTimeStatus? status,
    ArcTimeMetric? metric,
    String? errorMessage,
    ArcTimeRange? selectedRange,
    DateTime? referenceDate,
  }) {
    return ArcTimeMetricState(
      status: status ?? this.status,
      metric: metric ?? this.metric,
      errorMessage: (status == ArcTimeStatus.success || status == ArcTimeStatus.loading)
          ? null
          : errorMessage ?? this.errorMessage,
      selectedRange: selectedRange ?? this.selectedRange,
      referenceDate: referenceDate ?? this.referenceDate,
    );
  }

  @override
  List<Object?> get props => [status, metric, errorMessage, selectedRange, referenceDate];
}