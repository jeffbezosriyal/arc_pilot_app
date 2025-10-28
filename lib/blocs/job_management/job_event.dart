import 'package:equatable/equatable.dart'; // <-- ADD THIS LINE
import '../../models/job.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered to fetch the list of jobs from the repository.
class FetchJobsEvent extends JobEvent {}

/// Event triggered when the user wants to add a new default job.
class AddNewJobEvent extends JobEvent {}

/// Event triggered to delete a specific job.
class DeleteJobEvent extends JobEvent {
  final String jobId;

  const DeleteJobEvent(this.jobId);

  @override
  List<Object> get props => [jobId];
}

/// Event triggered to toggle the active status of a job.
class ToggleJobActiveEvent extends JobEvent {
  final Job job;

  const ToggleJobActiveEvent(this.job);

  @override
  List<Object> get props => [job];
}

/// Event to clear any snackbar messages from the state.
class ClearJobActionEvent extends JobEvent {}

/// Event to filter the job list based on a set of selected modes.
class ApplyJobFilterEvent extends JobEvent {
  final Set<String> filters;

  const ApplyJobFilterEvent(this.filters);

  @override
  List<Object> get props => [filters];
}

/// Event triggered to add a specific job (e.g., from import).
class AddSpecificJobEvent extends JobEvent {
  final Job job;

  const AddSpecificJobEvent(this.job);

  @override
  List<Object> get props => [job];
}

/// Event triggered to update an existing job's details.
class UpdateJobEvent extends JobEvent {
  final Job updatedJob;

  const UpdateJobEvent(this.updatedJob);

  @override
  List<Object> get props => [updatedJob];
}

/// Event to filter the job list based on a search query.
class SearchJobsEvent extends JobEvent {
  final String query;

  const SearchJobsEvent(this.query);

  @override
  List<Object> get props => [query];
}

