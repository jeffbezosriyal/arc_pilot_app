part of 'arc_time_metric_bloc.dart'; // Keep this directive

// Enum to represent the status of the data fetching
enum ArcTimeStatus { initial, loading, success, failure }

class ArcTimeMetricState extends Equatable {
  final ArcTimeStatus status;
  final ArcTimeMetric metric;
  final String? errorMessage;
  final ArcTimeRange selectedRange; // Stores the current range
  final DateTime referenceDate; // <-- ADDED: Date to base navigation on

  const ArcTimeMetricState({
    this.status = ArcTimeStatus.initial,
    required this.metric,
    this.errorMessage,
    this.selectedRange = ArcTimeRange.week, // Default to week
    required this.referenceDate, // <-- ADDED
  });

  // Factory constructor for the initial state
  factory ArcTimeMetricState.initial() {
    return ArcTimeMetricState(
      status: ArcTimeStatus.initial,
      metric: ArcTimeMetric.initial(),
      errorMessage: null,
      selectedRange: ArcTimeRange.week, // Set initial range
      referenceDate: DateTime.now(), // <-- ADDED: Initialize with current date
    );
  }

  ArcTimeMetricState copyWith({
    ArcTimeStatus? status,
    ArcTimeMetric? metric,
    String? errorMessage,
    ArcTimeRange? selectedRange,
    DateTime? referenceDate, // <-- ADDED
  }) {
    return ArcTimeMetricState(
      status: status ?? this.status,
      metric: metric ?? this.metric,
      // Clear error message on success or loading, keep on failure if no new message
      errorMessage: (status == ArcTimeStatus.success || status == ArcTimeStatus.loading)
          ? null
          : errorMessage ?? this.errorMessage,
      selectedRange: selectedRange ?? this.selectedRange,
      referenceDate: referenceDate ?? this.referenceDate, // <-- ADDED
    );
  }

  @override
  // FIX: Ensure referenceDate is included for proper state comparison
  List<Object?> get props => [status, metric, errorMessage, selectedRange, referenceDate]; // <-- UPDATED
}
