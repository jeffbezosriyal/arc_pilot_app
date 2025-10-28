import 'package:equatable/equatable.dart';
import '../../models/job.dart';

/// Enum to represent the status of the job list fetching operation.
enum JobStatus { initial, loading, success, failure }

/// Enum to represent the type of action message for the UI (e.g., for SnackBars).
enum ActionMessageType { success, error }

class JobState extends Equatable {
  final JobStatus status;
  final List<Job> allJobs; // <-- Holds the master list
  final List<Job> filteredJobs; // <-- Holds the list to be displayed
  final Set<String> activeFilters; // <-- Holds the active filter modes
  final String searchQuery; // <-- Holds the current search text
  final String? actionMessage;
  final ActionMessageType actionMessageType;

  const JobState({
    this.status = JobStatus.initial,
    this.allJobs = const [],
    this.filteredJobs = const [],
    this.activeFilters = const {},
    this.searchQuery = '', // <-- Initialize as empty string
    this.actionMessage,
    this.actionMessageType = ActionMessageType.success,
  });

  JobState copyWith({
    JobStatus? status,
    List<Job>? allJobs,
    List<Job>? filteredJobs,
    Set<String>? activeFilters,
    String? searchQuery,
    String? actionMessage,
    ActionMessageType? actionMessageType,
    bool clearActionMessage = false,
  }) {
    return JobState(
      status: status ?? this.status,
      allJobs: allJobs ?? this.allJobs,
      filteredJobs: filteredJobs ?? this.filteredJobs,
      activeFilters: activeFilters ?? this.activeFilters,
      searchQuery: searchQuery ?? this.searchQuery,
      actionMessage:
      clearActionMessage ? null : actionMessage ?? this.actionMessage,
      actionMessageType: actionMessageType ?? this.actionMessageType,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allJobs,
    filteredJobs,
    activeFilters,
    searchQuery, // <-- Add to props
    actionMessage,
    actionMessageType
  ];
}