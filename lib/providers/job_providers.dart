// import 'dart:async';
// import '../blocs/job_management/job_event.dart';
// import '../blocs/job_management/job_state.dart';
// import 'package.flutter_bloc/flutter_bloc.dart';
// import '../../models/job.dart';
// import '../../services/job_service.dart';
// import 'job_event.dart';
// import 'job_state.dart';
//
// class JobBloc extends Bloc<JobEvent, JobState> {
//   final JobService _jobService;
//
//   JobBloc({required JobService jobService})
//       : _jobService = jobService,
//         super(const JobState()) {
//     on<FetchJobsEvent>(_onFetchJobs);
//     on<AddNewJobEvent>(_onAddNewJob);
//     on<DeleteJobEvent>(_onDeleteJob);
//     on<ToggleJobActiveEvent>(_onToggleJobActive);
//     on<ClearJobActionEvent>(_onClearJobAction);
//   }
//
//   Future<void> _onFetchJobs(
//       FetchJobsEvent event, Emitter<JobState> emit) async {
//     emit(state.copyWith(status: JobStatus.loading));
//     try {
//       final jobs = await _jobService.fetchJobs();
//       emit(state.copyWith(status: JobStatus.success, jobs: jobs));
//     } catch (e) {
//       emit(state.copyWith(status: JobStatus.failure));
//     }
//   }
//
//   Future<void> _onAddNewJob(
//       AddNewJobEvent event, Emitter<JobState> emit) async {
//     final newJob = Job(
//       title: 'New Custom Job',
//       mode: 'MIG DP',
//       current: '85A',
//       wire: 'Alu',
//       shieldingGas: 'Argon',
//     );
//     try {
//       await _jobService.addJob(newJob);
//       emit(state.copyWith(
//         actionMessage: 'Job added successfully!',
//         actionMessageType: ActionMessageType.success,
//       ));
//       add(FetchJobsEvent());
//     } catch (e) {
//       emit(state.copyWith(
//         actionMessage: 'Failed to add job.',
//         actionMessageType: ActionMessageType.error,
//       ));
//     }
//   }
//
//   Future<void> _onDeleteJob(
//       DeleteJobEvent event, Emitter<JobState> emit) async {
//     try {
//       await _jobService.deleteJob(event.jobId);
//       emit(state.copyWith(
//         actionMessage: 'Job deleted successfully.',
//         actionMessageType: ActionMessageType.success,
//       ));
//       add(FetchJobsEvent());
//     } catch (e) {
//       emit(state.copyWith(
//         actionMessage: 'Failed to delete job.',
//         actionMessageType: ActionMessageType.error,
//       ));
//     }
//   }
//
//   Future<void> _onToggleJobActive(
//       ToggleJobActiveEvent event, Emitter<JobState> emit) async {
//     if (event.job.isActive) return;
//
//     try {
//       for (final job in state.jobs) {
//         if (job.isActive && job.id != event.job.id) {
//           await _jobService.updateJobStatus(job.id!, false);
//         }
//       }
//       await _jobService.updateJobStatus(event.job.id!, true);
//       emit(state.copyWith(
//         actionMessage: 'Job activated successfully!',
//         actionMessageType: ActionMessageType.success,
//       ));
//       add(FetchJobsEvent());
//     } catch (e) {
//       emit(state.copyWith(
//         actionMessage: 'Failed to activate job.',
//         actionMessageType: ActionMessageType.error,
//       ));
//     }
//   }
//
//   void _onClearJobAction(ClearJobActionEvent event, Emitter<JobState> emit) {
//     emit(state.copyWith(clearActionMessage: true));
//   }
// }