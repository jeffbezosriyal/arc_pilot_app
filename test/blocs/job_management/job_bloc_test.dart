import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:machine_dashboard/api/api_exceptions.dart';
import 'package:machine_dashboard/blocs/job_management/job_bloc.dart';
import 'package:machine_dashboard/blocs/job_management/job_event.dart';
import 'package:machine_dashboard/blocs/job_management/job_state.dart';
import 'package:machine_dashboard/models/job.dart';
import 'package:mockito/mockito.dart';

import '../../mocks.mocks.dart';

// Helper function to create a mock job
Job createMockJob({
  String id = '1',
  String title = 'Test Job',
  String mode = 'MIG',
  bool isActive = false,
}) =>
    Job(
      id: id,
      title: title,
      mode: mode,
      current: '100A',
      isActive: isActive,
    );

void main() {
  late JobBloc jobBloc;
  late MockJobService mockJobService;

  // Mock data
  final job1 = createMockJob(id: '1', title: 'Steel Job', mode: 'MIG');
  final job2 = createMockJob(id: '2', title: 'Alu Job', mode: 'TIG');
  final job3 = createMockJob(id: '3', title: 'MMA Job', mode: 'MMA');
  final allJobs = [job1, job2, job3];

  setUp(() {
    mockJobService = MockJobService();
    jobBloc = JobBloc(jobService: mockJobService);

    // Stub default successful fetch
    when(mockJobService.fetchJobs())
        .thenAnswer((_) async => allJobs);
  });

  tearDown(() {
    jobBloc.close();
  });

  group('JobBloc', () {
    test('initial state is correct', () {
      expect(jobBloc.state, const JobState());
    });

    blocTest<JobBloc, JobState>(
      'FetchJobsEvent: emits [loading, success] on successful fetch',
      build: () => jobBloc,
      act: (bloc) => bloc.add(FetchJobsEvent()),
      expect: () => [
        const JobState(status: JobStatus.loading),
        JobState(
          status: JobStatus.success,
          allJobs: allJobs,
          filteredJobs: allJobs,
        ),
      ],
      verify: (_) {
        verify(mockJobService.fetchJobs()).called(1);
      },
    );

    blocTest<JobBloc, JobState>(
      'FetchJobsEvent: emits [loading, failure] on error',
      build: () {
        when(mockJobService.fetchJobs())
            .thenThrow(ApiException('Network Error'));
        return jobBloc;
      },
      act: (bloc) => bloc.add(FetchJobsEvent()),
      expect: () => [
        const JobState(status: JobStatus.loading),
        const JobState(
          status: JobStatus.failure,
          allJobs: [],
          filteredJobs: [],
        ),
      ],
      verify: (_) {
        verify(mockJobService.fetchJobs()).called(1);
      },
    );

    blocTest<JobBloc, JobState>(
      'ApplyJobFilterEvent: filters list from allJobs',
      build: () => jobBloc,
      seed: () => JobState(allJobs: allJobs, filteredJobs: allJobs),
      act: (bloc) => bloc.add(const ApplyJobFilterEvent({'MIG', 'MMA'})),
      expect: () => [
        JobState(
          allJobs: allJobs,
          filteredJobs: [job1, job3], // job2 (TIG) is filtered out
          activeFilters: const {'MIG', 'MMA'},
        ),
      ],
      verify: (_) {
        verifyNever(mockJobService.fetchJobs()); // No network call
      },
    );

    blocTest<JobBloc, JobState>(
      'SearchJobsEvent: searches list from allJobs',
      build: () => jobBloc,
      seed: () => JobState(allJobs: allJobs, filteredJobs: allJobs),
      act: (bloc) => bloc.add(const SearchJobsEvent('Alu')),
      expect: () => [
        JobState(
          allJobs: allJobs,
          filteredJobs: [job2], // Only 'Alu Job'
          searchQuery: 'Alu',
        ),
      ],
      verify: (_) {
        verifyNever(mockJobService.fetchJobs()); // No network call
      },
    );

    blocTest<JobBloc, JobState>(
      'Filter and Search: apply both filter and search',
      build: () => jobBloc,
      seed: () => JobState(
        allJobs: allJobs,
        filteredJobs: allJobs,
        activeFilters: const {'MIG', 'TIG'}, // Filtered to job1, job2
      ),
      act: (bloc) => bloc.add(const SearchJobsEvent('Steel')), // Search for 'Steel'
      expect: () => [
        JobState(
          allJobs: allJobs,
          filteredJobs: [job1], // Only 'Steel Job' matches both
          activeFilters: const {'MIG', 'TIG'},
          searchQuery: 'Steel',
        ),
      ],
    );

    blocTest<JobBloc, JobState>(
      'AddNewJobEvent: adds job, shows success, and re-fetches',
      build: () {
        when(mockJobService.addJob(any)).thenAnswer((_) async => {});
        // Mock the re-fetch
        when(mockJobService.fetchJobs()).thenAnswer((_) async => allJobs);
        return jobBloc;
      },
      act: (bloc) => bloc.add(AddNewJobEvent()),
      expect: () => [
        const JobState(
          actionMessage: 'Job added successfully!',
          actionMessageType: ActionMessageType.success,
        ),
        const JobState(
          status: JobStatus.loading,
          actionMessage: 'Job added successfully!',
          actionMessageType: ActionMessageType.success,
        ),
        // --- THIS IS THE FIX ---
        JobState(
          status: JobStatus.success,
          allJobs: allJobs,
          filteredJobs: allJobs,
          actionMessage: 'Job added successfully!', // The message persists
          actionMessageType: ActionMessageType.success,
        ),
        // --- END OF FIX ---
      ],
      verify: (_) {
        verify(mockJobService.addJob(any)).called(1);
        verify(mockJobService.fetchJobs()).called(1);
      },
    );

    blocTest<JobBloc, JobState>(
      'AddSpecificJobEvent: adds job, shows success, and re-fetches',
      build: () {
        when(mockJobService.addJob(job1)).thenAnswer((_) async => {});
        when(mockJobService.fetchJobs()).thenAnswer((_) async => allJobs);
        return jobBloc;
      },
      act: (bloc) => bloc.add(AddSpecificJobEvent(job1)),
      expect: () => [
        const JobState(
          actionMessage: 'Job imported successfully!',
          actionMessageType: ActionMessageType.success,
        ),
        const JobState(
          status: JobStatus.loading,
          actionMessage: 'Job imported successfully!',
          actionMessageType: ActionMessageType.success,
        ),
        // --- THIS IS THE FIX ---
        JobState(
          status: JobStatus.success,
          allJobs: allJobs,
          filteredJobs: allJobs,
          actionMessage: 'Job imported successfully!', // The message persists
          actionMessageType: ActionMessageType.success,
        ),
        // --- END OF FIX ---
      ],
    );

    blocTest<JobBloc, JobState>(
      'DeleteJobEvent: deletes job, shows success, and re-fetches',
      build: () {
        when(mockJobService.deleteJob(job1.id!)).thenAnswer((_) async => {});
        when(mockJobService.fetchJobs()).thenAnswer((_) async => [job2, job3]);
        return jobBloc;
      },
      act: (bloc) => bloc.add(DeleteJobEvent(job1.id!)),
      expect: () => [
        const JobState(
          actionMessage: 'Job deleted successfully.',
          actionMessageType: ActionMessageType.success,
        ),
        const JobState(
          status: JobStatus.loading,
          actionMessage: 'Job deleted successfully.',
          actionMessageType: ActionMessageType.success,
        ),
        // --- THIS IS THE FIX ---
        JobState(
          status: JobStatus.success,
          allJobs: [job2, job3],
          filteredJobs: [job2, job3],
          actionMessage: 'Job deleted successfully.', // The message persists
          actionMessageType: ActionMessageType.success,
        ),
        // --- END OF FIX ---
      ],
    );

    blocTest<JobBloc, JobState>(
      'DeleteJobEvent: shows error on failure',
      build: () {
        when(mockJobService.deleteJob(any))
            .thenThrow(ApiException('Failed to delete'));
        return jobBloc;
      },
      act: (bloc) => bloc.add(const DeleteJobEvent('1')),
      expect: () => [
        const JobState(
          actionMessage: 'Failed to delete job.',
          actionMessageType: ActionMessageType.error,
        ),
      ],
    );

    blocTest<JobBloc, JobState>(
      'UpdateJobEvent: optimistically updates state and shows success',
      build: () {
        when(mockJobService.updateJob(any)).thenAnswer((_) async => {});
        return jobBloc;
      },
      // Seed the state with the original list
      seed: () => JobState(
        status: JobStatus.success,
        allJobs: [job1, job2],
        filteredJobs: [job1, job2],
      ),
      act: (bloc) {
        final updatedJob1 =
        createMockJob(id: '1', title: 'UPDATED Job', mode: 'MIG');
        bloc.add(UpdateJobEvent(updatedJob1));
      },
      expect: () {
        final updatedJob1 =
        createMockJob(id: '1', title: 'UPDATED Job', mode: 'MIG');
        return [
          JobState(
            status: JobStatus.success,
            allJobs: [updatedJob1, job2], // Optimistically updated list
            filteredJobs: [updatedJob1, job2], // Optimistically updated list
            actionMessage: 'Job updated successfully!',
            actionMessageType: ActionMessageType.success,
          ),
        ];
      },
      verify: (_) {
        // Crucially, verify updateJob was called but fetchJobs was NOT
        verify(mockJobService.updateJob(any)).called(1);
        verifyNever(mockJobService.fetchJobs());
      },
    );

    blocTest<JobBloc, JobState>(
      'UpdateJobEvent: shows error on failure and does not change state',
      build: () {
        when(mockJobService.updateJob(any))
            .thenThrow(ApiException('Failed to update'));
        return jobBloc;
      },
      seed: () => JobState(
        status: JobStatus.success,
        allJobs: [job1, job2],
        filteredJobs: [job1, job2],
      ),
      act: (bloc) {
        final updatedJob1 =
        createMockJob(id: '1', title: 'UPDATED Job', mode: 'MIG');
        bloc.add(UpdateJobEvent(updatedJob1));
      },
      expect: () => [
        JobState(
          status: JobStatus.success,
          allJobs: [job1, job2], // State remains unchanged
          filteredJobs: [job1, job2], // State remains unchanged
          actionMessage: 'Failed to update job.',
          actionMessageType: ActionMessageType.error,
        ),
      ],
      verify: (_) {
        verify(mockJobService.updateJob(any)).called(1);
        verifyNever(mockJobService.fetchJobs());
      },
    );

    blocTest<JobBloc, JobState>(
      'ToggleJobActiveEvent: deactivates old, activates new, and re-fetches',
      build: () {
        final activeJob = createMockJob(id: '1', isActive: true);
        final inactiveJob = createMockJob(id: '2', isActive: false);
        final finalActiveJob = createMockJob(id: '2', isActive: true);
        final finalInactiveJob = createMockJob(id: '1', isActive: false);

        when(mockJobService.updateJobStatus(activeJob.id!, false))
            .thenAnswer((_) async => {});
        when(mockJobService.updateJobStatus(inactiveJob.id!, true))
            .thenAnswer((_) async => {});
        when(mockJobService.fetchJobs())
            .thenAnswer((_) async => [finalInactiveJob, finalActiveJob]);

        return jobBloc;
      },
      seed: () => JobState(
        status: JobStatus.success,
        allJobs: [
          createMockJob(id: '1', isActive: true),
          createMockJob(id: '2', isActive: false),
        ],
      ),
      act: (bloc) =>
          bloc.add(ToggleJobActiveEvent(createMockJob(id: '2', isActive: false))),
      expect: () {
        final finalActiveJob = createMockJob(id: '2', isActive: true);
        final finalInactiveJob = createMockJob(id: '1', isActive: false);
        return [
          JobState(
            status: JobStatus.success,
            allJobs: [
              createMockJob(id: '1', isActive: true),
              createMockJob(id: '2', isActive: false),
            ],
            actionMessage: 'Job activated successfully!',
            actionMessageType: ActionMessageType.success,
          ),
          JobState(
            status: JobStatus.loading,
            allJobs: [
              createMockJob(id: '1', isActive: true),
              createMockJob(id: '2', isActive: false),
            ],
            actionMessage: 'Job activated successfully!',
            actionMessageType: ActionMessageType.success,
          ),
          // --- THIS IS THE FIX ---
          JobState(
            status: JobStatus.success,
            allJobs: [finalInactiveJob, finalActiveJob],
            filteredJobs: [finalInactiveJob, finalActiveJob],
            actionMessage: 'Job activated successfully!', // The message persists
            actionMessageType: ActionMessageType.success,
          ),
          // --- END OF FIX ---
        ];
      },
      verify: (_) {
        verify(mockJobService.updateJobStatus('1', false)).called(1);
        verify(mockJobService.updateJobStatus('2', true)).called(1);
        verify(mockJobService.fetchJobs()).called(1);
      },
    );

    blocTest<JobBloc, JobState>(
      'ToggleJobActiveEvent: does nothing if job is already active',
      build: () => jobBloc,
      seed: () => JobState(allJobs: [job1, job2]),
      act: (bloc) =>
          bloc.add(ToggleJobActiveEvent(createMockJob(id: '1', isActive: true))),
      expect: () => [], // No state change
      verify: (_) {
        verifyZeroInteractions(mockJobService); // Guard clause works
      },
    );

    blocTest<JobBloc, JobState>(
      'ToggleJobActiveEvent: shows error on failure',
      build: () {
        when(mockJobService.updateJobStatus(any, any))
            .thenThrow(ApiException('Failed to activate'));
        return jobBloc;
      },
      seed: () => JobState(
        status: JobStatus.success,
        allJobs: [
          createMockJob(id: '1', isActive: true),
          createMockJob(id: '2', isActive: false),
        ],
      ),
      act: (bloc) =>
          bloc.add(ToggleJobActiveEvent(createMockJob(id: '2', isActive: false))),
      expect: () => [
        JobState(
          status: JobStatus.success,
          allJobs: [
            createMockJob(id: '1', isActive: true),
            createMockJob(id: '2', isActive: false),
          ],
          actionMessage: 'Failed to activate job.',
          actionMessageType: ActionMessageType.error,
        ),
      ],
    );

    blocTest<JobBloc, JobState>(
      'ClearJobActionEvent: clears the action message',
      build: () => jobBloc,
      seed: () => const JobState(
        actionMessage: 'Test Message',
        actionMessageType: ActionMessageType.success,
      ),
      act: (bloc) => bloc.add(ClearJobActionEvent()),
      expect: () => [
        const JobState(
          actionMessage: null,
          actionMessageType: ActionMessageType.success,
        ),
      ],
    );
  });
}