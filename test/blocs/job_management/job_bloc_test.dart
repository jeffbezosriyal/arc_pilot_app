import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/blocs/job_management/job_bloc.dart';
import 'package:machine_dashboard/blocs/job_management/job_event.dart';
import 'package:machine_dashboard/blocs/job_management/job_state.dart';
import 'package:machine_dashboard/models/job.dart';
import 'package:mocktail/mocktail.dart';
import 'package:machine_dashboard/api/api_exceptions.dart';


import '../../mocks.dart'; // Import mocks

// Helper Job instances for testing
final job1 = Job(id: '1', title: 'Job 1', mode: 'MIG', current: '100A', isActive: false);
final job2 = Job(id: '2', title: 'Job 2', mode: 'TIG', current: '150A', isActive: true);
final job3 = Job(id: '3', title: 'Test 3', mode: 'MIG', current: '120A', isActive: false);

// Create a valid, non-const dummy Job instance for fallback
final fallbackJob = Job(title: '', mode: '', current: '');

void main() {
  late MockJobService mockJobService;
  late JobBloc jobBloc;

  // --- FIX: Register fallback value OUTSIDE setUp ---
  setUpAll(() {
    registerFallbackValue(fallbackJob); // Use the helper instance
  });
  // --- END FIX ---


  setUp(() {
    mockJobService = MockJobService();
    jobBloc = JobBloc(jobService: mockJobService);

    // Default stub for addJob (can be overridden in specific tests)
    // Use any() for the Job parameter because we registered a fallback
    when(() => mockJobService.addJob(any())).thenAnswer((_) async => {});

    // Default stub for updateJob
    when(() => mockJobService.updateJob(any())).thenAnswer((_) async => {});

    // Default stub for updateJobStatus
    when(() => mockJobService.updateJobStatus(any(), any())).thenAnswer((
        _) async => {});

    // Default stub for deleteJob
    when(() => mockJobService.deleteJob(any())).thenAnswer((_) async => {});
  });

  tearDown(() {
    jobBloc.close();
  });

  test('initial state is correct', () {
    expect(jobBloc.state, const JobState());
  });

  group('FetchJobsEvent', () {
    blocTest<JobBloc, JobState>(
      'emits [loading, success] when fetch is successful',
      setUp: () {
        when(() => mockJobService.fetchJobs()).thenAnswer((_) async =>
        [
          job1,
          job2
        ]);
      },
      build: () => jobBloc,
      act: (bloc) => bloc.add(FetchJobsEvent()),
      expect: () =>
      <JobState>[
        const JobState(status: JobStatus.loading),
        JobState(
            status: JobStatus.success,
            allJobs: [job1, job2],
            filteredJobs: [job1, job2]),
      ],
      verify: (_) {
        verify(() => mockJobService.fetchJobs()).called(1);
      },
    );

    blocTest<JobBloc, JobState>(
      'emits [loading, failure] when fetch fails',
      setUp: () {
        when(() => mockJobService.fetchJobs()).thenThrow(
            ApiException('Failed'));
      },
      build: () => jobBloc,
      act: (bloc) => bloc.add(FetchJobsEvent()),
      expect: () =>
      <JobState>[
        const JobState(status: JobStatus.loading),
        const JobState(
            status: JobStatus.failure, allJobs: [], filteredJobs: []),
        // Ensure lists are empty on failure
      ],
      verify: (_) {
        verify(() => mockJobService.fetchJobs()).called(1);
      },
    );
  });

  group('SearchJobsEvent', () {
    blocTest<JobBloc, JobState>(
      'correctly filters the job list',
      build: () => jobBloc,
      // Seed state with some initial jobs
      seed: () =>
          JobState(
            status: JobStatus.success,
            allJobs: [job1, job2, job3],
            filteredJobs: [job1, job2, job3],
          ),
      act: (bloc) => bloc.add(const SearchJobsEvent('Job')), // Search for 'Job'
      expect: () =>
      <JobState>[
        // Expect state with filtered list containing only job1 and job2
        JobState(
          status: JobStatus.success,
          allJobs: [job1, job2, job3],
          filteredJobs: [job1, job2], // Only job1 and job2 match 'Job'
          searchQuery: 'Job', // Search query is updated
        ),
      ],
      // No API calls expected for search
    );
  });

  group('ApplyJobFilterEvent', () {
    blocTest<JobBloc, JobState>(
      'correctly filters the job list',
      build: () => jobBloc,
      seed: () =>
          JobState(
            status: JobStatus.success,
            allJobs: [job1, job2, job3],
            filteredJobs: [job1, job2, job3],
          ),
      act: (bloc) => bloc.add(const ApplyJobFilterEvent({'MIG'})),
      // Filter for 'MIG'
      expect: () =>
      <JobState>[
        // Expect state with filtered list containing only job1 and job3
        JobState(
          status: JobStatus.success,
          allJobs: [job1, job2, job3],
          filteredJobs: [job1, job3], // Only job1 and job3 have mode 'MIG'
          activeFilters: const {'MIG'}, // Filters are updated
        ),
      ],
      // No API calls expected for filter
    );
  });

  group('Search and Filter Combination', () {
    blocTest<JobBloc, JobState>(
      'Search and Filter events work together',
      build: () => jobBloc,
      seed: () =>
          JobState(
            status: JobStatus.success,
            allJobs: [job1, job2, job3],
            filteredJobs: [job1, job2, job3],
          ),
      act: (bloc) async {
        bloc.add(const ApplyJobFilterEvent({'MIG'})); // Apply filter first
        await Future.delayed(Duration.zero); // Allow filter to process
        bloc.add(const SearchJobsEvent('Job')); // Then apply search
      },
      skip: 1,
      // Skip the intermediate state after filtering
      expect: () =>
      <JobState>[
        // Expect final state after both filter and search
        JobState(
          status: JobStatus.success,
          allJobs: [job1, job2, job3],
          filteredJobs: [job1],
          // Only job1 matches 'MIG' AND 'Job'
          activeFilters: const {'MIG'},
          searchQuery: 'Job',
        ),
      ],
    );
  });


  group('AddNewJobEvent', () {
    final newJobList = [job1, job2, job3]; // Simulate list after refetch

    // --- FIX: Use Matchers ---
    blocTest<JobBloc, JobState>(
      'adds a job and refetches the list',
      setUp: () {
        // Mock addJob to succeed
        when(() => mockJobService.addJob(any())).thenAnswer((_) async => {});
        // Mock the subsequent fetchJobs to return the new list
        when(() => mockJobService.fetchJobs()).thenAnswer((
            _) async => newJobList);
      },
      build: () => jobBloc,
      // Seed with initial state if needed, e.g., existing jobs
      seed: () =>
          JobState(status: JobStatus.success,
          allJobs: [job1, job2],
          filteredJobs: [job1, job2]),
      act: (bloc) => bloc.add(AddNewJobEvent()),
      expect: () =>
      <dynamic>[
        // Use dynamic list for Matchers
        // 1. Action message state (intermediate)
        isA<JobState>()
            .having((s) => s.actionMessage, 'actionMessage',
            'Job added successfully!')
            .having((s) => s.actionMessageType, 'messageType',
            ActionMessageType.success)
        // Important: Check that lists haven't changed yet
            .having((s) => s.allJobs.length, 'allJobs length', 2)
            .having((s) => s.filteredJobs.length, 'filteredJobs length', 2),

        // 2. Loading state during refetch (action message persists)
        isA<JobState>()
            .having((s) => s.status, 'status', JobStatus.loading)
            .having((s) => s.actionMessage, 'actionMessage',
            'Job added successfully!'),

        // 3. Final success state with the NEW list (action message persists briefly)
        isA<JobState>()
            .having((s) => s.status, 'status', JobStatus.success)
            .having((s) => s.allJobs, 'allJobs', newJobList)
            .having((s) => s.filteredJobs, 'filteredJobs',
            newJobList) // Assuming no filters active
            .having((s) => s.actionMessage, 'actionMessage',
            'Job added successfully!'),
      ],
      verify: (_) {
        verify(() => mockJobService.addJob(any())).called(1);
        verify(() => mockJobService.fetchJobs()).called(1); // Verify refetch
      },
    );
    // --- END FIX ---

    blocTest<JobBloc, JobState>(
      'emits error message when addJob fails',
      setUp: () {
        when(() => mockJobService.addJob(any())).thenThrow(
            ApiException('Failed'));
      },
      build: () => jobBloc,
      act: (bloc) => bloc.add(AddNewJobEvent()),
      expect: () =>
      <JobState>[
        const JobState(
          actionMessage: 'Failed to add job.',
          actionMessageType: ActionMessageType.error,
        ),
      ],
      verify: (_) {
        verify(() => mockJobService.addJob(any())).called(1);
        verifyNever(() => mockJobService.fetchJobs()); // No refetch on failure
      },
    );
  });

  group('AddSpecificJobEvent', () {
    final specificJob = Job(title: 'Imported', mode: 'MMA', current: '70A');
    final newJobList = [job1, job2, specificJob];

    blocTest<JobBloc, JobState>(
      'adds the specific job and refetches',
      setUp: () {
        when(() => mockJobService.addJob(specificJob)).thenAnswer((_) async =>
        {
        });
        when(() => mockJobService.fetchJobs()).thenAnswer((
            _) async => newJobList);
      },
      build: () => jobBloc,
      seed: () =>
          JobState(status: JobStatus.success,
          allJobs: [job1, job2],
          filteredJobs: [job1, job2]),
      act: (bloc) => bloc.add(AddSpecificJobEvent(specificJob)),
      // Similar pattern to AddNewJobEvent using matchers
      expect: () =>
      <dynamic>[
        isA<JobState>()
            .having((s) => s.actionMessage, 'actionMessage',
            'Job imported successfully!')
            .having((s) => s.actionMessageType, 'messageType',
            ActionMessageType.success),
        isA<JobState>()
            .having((s) => s.status, 'status', JobStatus.loading)
            .having((s) => s.actionMessage, 'actionMessage',
            'Job imported successfully!'),
        isA<JobState>()
            .having((s) => s.status, 'status', JobStatus.success)
            .having((s) => s.allJobs, 'allJobs', newJobList)
            .having((s) => s.filteredJobs, 'filteredJobs', newJobList)
            .having((s) => s.actionMessage, 'actionMessage',
            'Job imported successfully!'),
      ],
      verify: (_) {
        verify(() => mockJobService.addJob(specificJob)).called(1);
        verify(() => mockJobService.fetchJobs()).called(1);
      },
    );
  });


  group('DeleteJobEvent', () {
    final remainingJobs = [job2]; // job1 is deleted

    // Using matchers similar to AddNewJobEvent
    blocTest<JobBloc, JobState>(
      'deletes a job and refetches the list',
      setUp: () {
        when(() => mockJobService.deleteJob('1')).thenAnswer((_) async => {});
        when(() => mockJobService.fetchJobs()).thenAnswer((
            _) async => remainingJobs);
      },
      build: () => jobBloc,
      seed: () =>
          JobState(status: JobStatus.success,
          allJobs: [job1, job2],
          filteredJobs: [job1, job2]),
      act: (bloc) => bloc.add(const DeleteJobEvent('1')),
      expect: () =>
      <dynamic>[
        isA<JobState>()
            .having((s) => s.actionMessage, 'actionMessage',
            'Job deleted successfully.')
            .having((s) => s.actionMessageType, 'messageType',
            ActionMessageType.success),
        isA<JobState>()
            .having((s) => s.status, 'status', JobStatus.loading)
            .having((s) => s.actionMessage, 'actionMessage',
            'Job deleted successfully.'),
        isA<JobState>()
            .having((s) => s.status, 'status', JobStatus.success)
            .having((s) => s.allJobs, 'allJobs', remainingJobs)
            .having((s) => s.filteredJobs, 'filteredJobs', remainingJobs)
            .having((s) => s.actionMessage, 'actionMessage',
            'Job deleted successfully.'),
      ],
      verify: (_) {
        verify(() => mockJobService.deleteJob('1')).called(1);
        verify(() => mockJobService.fetchJobs()).called(1); // Verify refetch
      },
    );

    blocTest<JobBloc, JobState>(
      'emits error message when deleteJob fails',
      setUp: () {
        when(() => mockJobService.deleteJob('1')).thenThrow(
            ApiException('Failed'));
      },
      build: () => jobBloc,
      act: (bloc) => bloc.add(const DeleteJobEvent('1')),
      expect: () =>
      <JobState>[
        // Expect only the error message state, keeping existing lists
        JobState(
          status: JobStatus.success,
          // Status remains from seed
          allJobs: [job1, job2],
          // List remains unchanged
          filteredJobs: [job1, job2],
          // List remains unchanged
          actionMessage: 'Failed to delete job.',
          actionMessageType: ActionMessageType.error,
        ),
      ],
      verify: (_) {
        verify(() => mockJobService.deleteJob('1')).called(1);
        verifyNever(() => mockJobService.fetchJobs()); // No refetch on failure
      },
    );
  });

  group('UpdateJobEvent', () {
    final updatedJob1 = Job(id: '1',
        title: 'Updated Job 1',
        mode: 'MIG',
        current: '110A',
        isActive: false);
    final updatedAllJobs = [updatedJob1, job2]; // job1 is updated
    final updatedFilteredJobs = [updatedJob1, job2];

    // --- FIX: Use Matchers ---
    blocTest<JobBloc, JobState>(
      'updates job locally without refetching',
      setUp: () {
        when(() => mockJobService.updateJob(updatedJob1)).thenAnswer((
            _) async => {});
      },
      build: () => jobBloc,
      seed: () =>
          JobState(status: JobStatus.success,
          allJobs: [job1, job2],
          filteredJobs: [job1, job2]),
      act: (bloc) => bloc.add(UpdateJobEvent(updatedJob1)),
      expect: () =>
      <dynamic>[ // Use dynamic list for Matchers
        isA<JobState>()
            .having((s) => s.status, 'status',
            JobStatus.success) // Status remains success
            .having((s) => s.allJobs, 'allJobs',
            updatedAllJobs) // Verify updated list
            .having((s) => s.filteredJobs, 'filteredJobs',
            updatedFilteredJobs) // Verify updated list
            .having((s) => s.actionMessage, 'actionMessage',
            'Job updated successfully!')
            .having((s) => s.actionMessageType, 'messageType',
            ActionMessageType.success),
      ],
      verify: (_) {
        verify(() => mockJobService.updateJob(updatedJob1)).called(1);
        verifyNever(() =>
            mockJobService.fetchJobs()); // Ensure refetch doesn't happen
      },
    );
    // --- END FIX ---

    blocTest<JobBloc, JobState>(
      'emits error message when updateJob fails',
      setUp: () {
        when(() => mockJobService.updateJob(updatedJob1)).thenThrow(
            ApiException('Failed'));
      },
      build: () => jobBloc,
      seed: () =>
          JobState(status: JobStatus.success,
          allJobs: [job1, job2],
          filteredJobs: [job1, job2]),
      act: (bloc) => bloc.add(UpdateJobEvent(updatedJob1)),
      expect: () =>
      <JobState>[
        // Only emit error state, lists remain unchanged from seed
        JobState(
          status: JobStatus.success,
          // Status doesn't change on failed update
          allJobs: [job1, job2],
          filteredJobs: [job1, job2],
          actionMessage: 'Failed to update job.',
          actionMessageType: ActionMessageType.error,
        ),
      ],
      verify: (_) {
        verify(() => mockJobService.updateJob(updatedJob1)).called(1);
        verifyNever(() => mockJobService.fetchJobs());
      },
    );
  });


  group('ToggleJobActiveEvent', () {
    // Simulate the state after refetch: job1 active, job2 inactive
    final toggledJobList = [
      Job(id: '1',
          title: 'Job 1',
          mode: 'MIG',
          current: '100A',
          isActive: true),
      Job(id: '2',
          title: 'Job 2',
          mode: 'TIG',
          current: '150A',
          isActive: false)
    ];

    // --- FIX: Use Matchers ---
    blocTest<JobBloc, JobState>(
      'updates statuses and refetches',
      setUp: () {
        // Mock the update status calls: set job2 to false, job1 to true
        when(() => mockJobService.updateJobStatus('2', false)).thenAnswer((
            _) async => {});
        when(() => mockJobService.updateJobStatus('1', true)).thenAnswer((
            _) async => {});
        // Mock the subsequent fetch
        when(() => mockJobService.fetchJobs()).thenAnswer((
            _) async => toggledJobList);
      },
      build: () => jobBloc,
      // Initial state: job1 inactive, job2 active
      seed: () =>
          JobState(status: JobStatus.success,
          allJobs: [job1, job2],
          filteredJobs: [job1, job2]),
      act: (bloc) => bloc.add(ToggleJobActiveEvent(job1)),
      // Activate job1
      expect: () =>
      <dynamic>[ // Use dynamic list for Matchers
        // 1. Action message state (intermediate)
        isA<JobState>()
            .having((s) => s.actionMessage, 'actionMessage',
            'Job activated successfully!')
            .having((s) => s.actionMessageType, 'messageType',
            ActionMessageType.success),

        // 2. Loading state during refetch
        isA<JobState>()
            .having((s) => s.status, 'status', JobStatus.loading)
            .having((s) => s.actionMessage, 'actionMessage',
            'Job activated successfully!'),

        // 3. Final success state with updated list
        isA<JobState>()
            .having((s) => s.status, 'status', JobStatus.success)
            .having((s) => s.allJobs, 'allJobs', toggledJobList)
            .having((s) => s.filteredJobs, 'filteredJobs', toggledJobList)
            .having((s) => s.actionMessage, 'actionMessage',
            'Job activated successfully!'),
      ],
      verify: (_) {
        verify(() => mockJobService.updateJobStatus('2', false)).called(
            1); // Deactivate job2
        verify(() => mockJobService.updateJobStatus('1', true)).called(
            1); // Activate job1
        verify(() => mockJobService.fetchJobs()).called(1); // Verify refetch
      },
    );
    // --- END FIX ---

    blocTest<JobBloc, JobState>(
      'does nothing if the job is already active',
      build: () => jobBloc,
      // Initial state: job2 is already active
      seed: () =>
          JobState(status: JobStatus.success,
          allJobs: [job1, job2],
          filteredJobs: [job1, job2]),
      act: (bloc) => bloc.add(ToggleJobActiveEvent(job2)),
      // Try to activate job2 again
      expect: () => <JobState>[],
      // No state changes expected
      verify: (_) {
        // Verify no status updates were called
        verifyNever(() => mockJobService.updateJobStatus(any(), any()));
        verifyNever(() => mockJobService.fetchJobs());
      },
    );

    blocTest<JobBloc, JobState>(
      'emits error message when toggle fails',
      setUp: () {
        // Make one of the status updates fail
        when(() => mockJobService.updateJobStatus('2', false)).thenAnswer((
            _) async => {});
        when(() => mockJobService.updateJobStatus('1', true)).thenThrow(
            ApiException('Failed'));
      },
      build: () => jobBloc,
      seed: () =>
          JobState(status: JobStatus.success,
          allJobs: [job1, job2],
          filteredJobs: [job1, job2]),
      act: (bloc) => bloc.add(ToggleJobActiveEvent(job1)),
      expect: () =>
      <JobState>[
        JobState(
          status: JobStatus.success,
          // Status remains success from seed
          allJobs: [job1, job2],
          filteredJobs: [job1, job2],
          actionMessage: 'Failed to activate job.',
          actionMessageType: ActionMessageType.error,
        ),
      ],
      verify: (_) {
        verify(() => mockJobService.updateJobStatus('2', false)).called(1);
        verify(() => mockJobService.updateJobStatus('1', true)).called(1);
        verifyNever(() => mockJobService.fetchJobs()); // No refetch on failure
      },
    );
  });

  group('ClearJobActionEvent', () {
    blocTest<JobBloc, JobState>(
      'clears the action message',
      build: () => jobBloc,
      seed: () => const JobState(actionMessage: 'Some message'),
      act: (bloc) => bloc.add(ClearJobActionEvent()),
      expect: () =>
      <JobState>[
        const JobState(actionMessage: null), // Message should be null
      ],
    );
  });
}
