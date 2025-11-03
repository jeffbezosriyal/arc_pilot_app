import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:machine_dashboard/api/api_exceptions.dart';
import 'package:machine_dashboard/models/job.dart';
import 'package:machine_dashboard/services/api_job_service.dart';
import 'package:mockito/mockito.dart';

// Import the generated mocks
import '../mocks.mocks.dart';

void main() {
  late MockClient mockClient;
  late ApiJobService apiJobService;
  final baseUrl = ApiJobService.baseUrl;

  setUp(() {
    mockClient = MockClient();
    apiJobService = ApiJobService(client: mockClient);
  });

  // Helper function to create a mock job
  Job createMockJob({String id = '1', String title = 'Test Job'}) => Job(
    id: id,
    title: title,
    mode: 'MIG',
    current: '100A',
    isActive: false,
  );

  // Helper for mock responses
  void setupMockResponse(
      Future<http.Response> Function(Invocation) response,
      ) {
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer(response);
    when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer(response);
    when(mockClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer(response);
    when(mockClient.delete(any, headers: anyNamed('headers')))
        .thenAnswer(response);
  }

  group('ApiJobService', () {
    group('fetchJobs', () {
      test('returns list of jobs on successful response (200)', () async {
        final mockJobs = [
          createMockJob(id: '1', title: 'Job 1'),
          createMockJob(id: '2', title: 'Job 2'),
        ];
        final mockJson = json.encode(mockJobs.map((j) => j.toJson()).toList());

        setupMockResponse((_) async => http.Response(mockJson, 200));

        final jobs = await apiJobService.fetchJobs();

        expect(jobs, isA<List<Job>>());
        expect(jobs.length, 2);
        expect(jobs[0].title, 'Job 1');
        verify(mockClient.get(Uri.parse(baseUrl)));
      });

      test('throws ApiException on server error (500)', () async {
        setupMockResponse((_) async => http.Response('Server Error', 500));

        expect(
              () => apiJobService.fetchJobs(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'Server Error: An internal server error occurred.',
          )),
        );
      });

      test('throws ApiException on SocketException (no network)', () async {
        when(mockClient.get(any)).thenThrow(const SocketException('No Internet'));

        expect(
              () => apiJobService.fetchJobs(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'No Internet connection. Please check your network.',
          )),
        );
      });

      test('throws ApiException on TimeoutException', () async {
        when(mockClient.get(any)).thenThrow(TimeoutException('Request timed out'));

        expect(
              () => apiJobService.fetchJobs(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'The request timed out. Please try again.',
          )),
        );
      });

      test('throws ApiException on unexpected error', () async {
        when(mockClient.get(any)).thenThrow(Exception('Unexpected'));

        expect(
              () => apiJobService.fetchJobs(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'An unexpected error occurred: Exception: Unexpected',
          )),
        );
      });
    });

    group('addJob', () {
      test('completes successfully on 201 response', () async {
        final newJob = createMockJob(id: 'temp', title: 'New Job');
        setupMockResponse((_) async => http.Response('', 201));

        await apiJobService.addJob(newJob);

        verify(mockClient.post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newJob.toJson()),
        ));
      });

      test('throws ApiException on 400 response', () async {
        final newJob = createMockJob(title: 'Bad Job');
        setupMockResponse((_) async => http.Response('Bad Request', 400));

        expect(
              () => apiJobService.addJob(newJob),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'Bad Request: The server could not process the request.',
          )),
        );
      });
    });

    group('updateJobStatus', () {
      test('completes successfully on 200 response', () async {
        const jobId = '123';
        const isActive = true;
        setupMockResponse((_) async => http.Response('', 200));

        await apiJobService.updateJobStatus(jobId, isActive);

        verify(mockClient.put(
          Uri.parse('$baseUrl/$jobId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'isActive': isActive}),
        ));
      });

      test('throws ApiException on 404 response', () async {
        setupMockResponse((_) async => http.Response('Not Found', 404));

        expect(
              () => apiJobService.updateJobStatus('123', true),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'Not Found: The requested endpoint does not exist.',
          )),
        );
      });
    });

    group('deleteJob', () {
      test('completes successfully on 200 response', () async {
        const jobId = '123';
        setupMockResponse((_) async => http.Response('', 200));

        await apiJobService.deleteJob(jobId);

        verify(mockClient.delete(Uri.parse('$baseUrl/$jobId')));
      });

      test('throws ApiException on 500 response', () async {
        setupMockResponse((_) async => http.Response('Server Error', 500));

        expect(
              () => apiJobService.deleteJob('123'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateJob', () {
      test('completes successfully on 200 response', () async {
        final job = createMockJob(id: '123', title: 'Updated Job');
        setupMockResponse((_) async => http.Response(json.encode(job.toJson()), 200));

        await apiJobService.updateJob(job);

        verify(mockClient.put(
          Uri.parse('$baseUrl/${job.id}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(job.toJson()),
        ));
      });

      test('throws ApiException if job ID is null', () async {
        final job = Job(title: 'No ID Job', mode: 'MIG', current: '100A');

        expect(
              () => apiJobService.updateJob(job),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'Cannot update job without an ID.',
          )),
        );
        // Verify no network call was made
        verifyZeroInteractions(mockClient);
      });
    });

    group('_processResponse (edge cases)', () {
      test('returns null on 200 with empty body', () async {
        // We test this by calling a method that expects a JSON body
        // but receives an empty one. fetchJobs expects a list.
        setupMockResponse((_) async => http.Response('', 200));

        // The service's _processResponse returns null, which
        // json.decode(null) would fail on. Here, the service's
        // `(data as List)` casting will fail.
        expect(
              () => apiJobService.fetchJobs(),
          throwsA(isA<TypeError>()),
        );
      });

      test('throws ApiException on 503 response', () async {
        setupMockResponse((_) async => http.Response('Service Unavailable', 503));

        expect(
              () => apiJobService.fetchJobs(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'Server Error: 503. Service Unavailable',
          )),
        );
      });
    });
  });
}