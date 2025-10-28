import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/job.dart';
import '../../services/job_service.dart';
import 'job_event.dart';
import 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final JobService _jobService;

  JobBloc({required JobService jobService})
      : _jobService = jobService,
        super(const JobState()) {
    on<FetchJobsEvent>(_onFetchJobs);
    on<AddNewJobEvent>(_onAddNewJob);
    on<DeleteJobEvent>(_onDeleteJob);
    on<ToggleJobActiveEvent>(_onToggleJobActive);
    on<ClearJobActionEvent>(_onClearJobAction);
    on<ApplyJobFilterEvent>(_onApplyJobFilter);
    on<AddSpecificJobEvent>(_onAddSpecificJob);
    on<SearchJobsEvent>(_onSearchJobs);
    on<UpdateJobEvent>(_onUpdateJob);
  }

  /// Helper method to apply both filters and search to a list of jobs
  List<Job> _applyFiltersAndSearch({
    required List<Job> jobs,
    required Set<String> filters,
    required String query,
  }) {
    List<Job> filteredList = [];

    // 1. Apply Mode Filters
    if (filters.isEmpty) {
      filteredList = List<Job>.from(jobs);
    } else {
      filteredList =
          jobs.where((job) => filters.contains(job.mode)).toList();
    }

    // 2. Apply Search Query
    if (query.isEmpty) {
      return filteredList;
    }

    final lowerCaseQuery = query.toLowerCase();
    return filteredList
        .where((job) => job.title.toLowerCase().contains(lowerCaseQuery))
        .toList();
  }

  Future<void> _onFetchJobs(
      FetchJobsEvent event, Emitter<JobState> emit) async {
    emit(state.copyWith(status: JobStatus.loading));
    try {
      final jobs = await _jobService.fetchJobs();

      final filteredJobs = _applyFiltersAndSearch(
        jobs: jobs,
        filters: state.activeFilters,
        query: state.searchQuery,
      );

      emit(state.copyWith(
        status: JobStatus.success,
        allJobs: jobs,
        filteredJobs: filteredJobs,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStatus.failure,
        allJobs: [],
        filteredJobs: [],
      ));
    }
  }

  Future<void> _onApplyJobFilter(
      ApplyJobFilterEvent event, Emitter<JobState> emit) async {
    final filteredJobs = _applyFiltersAndSearch(
      jobs: state.allJobs,
      filters: event.filters,
      query: state.searchQuery,
    );
    emit(state.copyWith(
      filteredJobs: filteredJobs,
      activeFilters: event.filters,
    ));
  }

  Future<void> _onSearchJobs(
      SearchJobsEvent event, Emitter<JobState> emit) async {
    final filteredJobs = _applyFiltersAndSearch(
      jobs: state.allJobs,
      filters: state.activeFilters,
      query: event.query,
    );
    emit(state.copyWith(
      filteredJobs: filteredJobs,
      searchQuery: event.query,
    ));
  }

  Future<void> _onAddNewJob(
      AddNewJobEvent event, Emitter<JobState> emit) async {
    final newJob = Job(
      title: 'New Custom Job',
      mode: 'MIG DP',
      current: '85A',
      wire: 'Alu',
      shieldingGas: 'Argon',
    );
    try {
      await _jobService.addJob(newJob);
      emit(state.copyWith(
        actionMessage: 'Job added successfully!',
        actionMessageType: ActionMessageType.success,
      ));
      add(FetchJobsEvent());
    } catch (e) {
      emit(state.copyWith(
        actionMessage: 'Failed to add job.',
        actionMessageType: ActionMessageType.error,
      ));
    }
  }

  Future<void> _onAddSpecificJob(
      AddSpecificJobEvent event, Emitter<JobState> emit) async {
    try {
      await _jobService.addJob(event.job);
      emit(state.copyWith(
        actionMessage: 'Job imported successfully!',
        actionMessageType: ActionMessageType.success,
      ));
      add(FetchJobsEvent());
    } catch (e) {
      emit(state.copyWith(
        actionMessage: 'Failed to import job.',
        actionMessageType: ActionMessageType.error,
      ));
    }
  }

  // --- THIS IS THE CORRECTED METHOD ---
  Future<void> _onUpdateJob(
      UpdateJobEvent event, Emitter<JobState> emit) async {
    try {
      // 1. Send the update to the API
      await _jobService.updateJob(event.updatedJob);

      // 2. If successful, update the local state manually
      //    This avoids the re-fetch and any race conditions.

      // Create new, updated versions of our local lists
      final newAllJobs = state.allJobs.map((job) {
        return job.id == event.updatedJob.id ? event.updatedJob : job;
      }).toList();

      final newFilteredJobs = state.filteredJobs.map((job) {
        return job.id == event.updatedJob.id ? event.updatedJob : job;
      }).toList();

      // 3. Emit the new state with the updated lists
      emit(state.copyWith(
        actionMessage: 'Job updated successfully!',
        actionMessageType: ActionMessageType.success,
        allJobs: newAllJobs,
        filteredJobs: newFilteredJobs,
      ));

    } catch (e) {
      // If the update fails, we DON'T re-fetch.
      // We just show the error. The UI remains unchanged.
      emit(state.copyWith(
        actionMessage: 'Failed to update job.',
        actionMessageType: ActionMessageType.error,
      ));
    }
  }
  // --- END OF CORRECTED METHOD ---

  Future<void> _onDeleteJob(
      DeleteJobEvent event, Emitter<JobState> emit) async {
    try {
      await _jobService.deleteJob(event.jobId);
      emit(state.copyWith(
        actionMessage: 'Job deleted successfully.',
        actionMessageType: ActionMessageType.success,
      ));
      add(FetchJobsEvent());
    } catch (e) {
      emit(state.copyWith(
        actionMessage: 'Failed to delete job.',
        actionMessageType: ActionMessageType.error,
      ));
    }
  }

  Future<void> _onToggleJobActive(
      ToggleJobActiveEvent event, Emitter<JobState> emit) async {
    if (event.job.isActive) return;

    try {
      for (final job in state.allJobs) {
        if (job.isActive && job.id != event.job.id) {
          await _jobService.updateJobStatus(job.id!, false);
        }
      }
      await _jobService.updateJobStatus(event.job.id!, true);
      emit(state.copyWith(
        actionMessage: 'Job activated successfully!',
        actionMessageType: ActionMessageType.success,
      ));
      add(FetchJobsEvent());
    } catch (e) {
      emit(state.copyWith(
        actionMessage: 'Failed to activate job.',
        actionMessageType: ActionMessageType.error,
      ));
    }
  }

  void _onClearJobAction(ClearJobActionEvent event, Emitter<JobState> emit) {
    emit(state.copyWith(clearActionMessage: true));
  }
}