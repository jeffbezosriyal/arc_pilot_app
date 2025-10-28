import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:machine_dashboard/api/api_exceptions.dart';
import 'package:machine_dashboard/models/job.dart';
import 'package:machine_dashboard/services/api_job_service.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  late ApiJobService apiJobService;
  late MockHttpClient mockHttpClient;
  late Job testJob;
  late Uri jobsUri;

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiJobService = ApiJobService(client: mockHttpClient);
    testJob = Job(
      id: '1',
      title: 'Test Job',
      mode: 'MIG',
      current: '100A',
    );
    jobsUri = Uri.parse(ApiJobService.baseUrl);

    // Register fallback values for mocktail's any() matcher
    registerFallbackValue(jobsUri);
    registerFallbackValue(testJob);
  });

  // --- Helper Functions ---

  void stubGetSuccess() {
    final successResponse = [testJob.toJson()];
    when(() => mockHttpClient.get(any()))
        .thenAnswer((_) async => http.Response(json.encode(successResponse), 200));
  }

  void stubPostSuccess() {
    when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response(json.encode(testJob.toJson()), 201));
  }

  void stubPutSuccess() {
    when(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('', 200));
  }

  void stubDeleteSuccess() {
    when(() => mockHttpClient.delete(any()))
        .thenAnswer((_) async => http.Response('', 200));
  }

  void stubError(Future<http.Response> Function() mockCall, int statusCode) {
    when(mockCall)
        .thenAnswer((_) async => http.Response('Error', statusCode));
  }

  // --- Tests ---

  group('ApiJobService', () {
    group('fetchJobs', () {
      test('returns List<Job> on success (200)', () async {
        stubGetSuccess();
        final jobs = await apiJobService.fetchJobs();
        expect(jobs, isA<List<Job>>());
        expect(jobs.first.id, testJob.id);
      });

      test('throws ApiException on server error (500)', () {
        stubError(() => mockHttpClient.get(any()), 500);
        expect(
              () => apiJobService.fetchJobs(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('addJob', () {
      test('completes successfully on success (201)', () async {
        stubPostSuccess();
        expect(
          apiJobService.addJob(testJob),
          completes,
        );
      });

      test('throws ApiException on bad request (400)', () {
        stubError(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')), 400);
        expect(
              () => apiJobService.addJob(testJob),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateJob', () {
      test('completes successfully on success (200)', () async {
        stubPutSuccess();
        expect(
          apiJobService.updateJob(testJob),
          completes,
        );
      });

      test('throws ApiException on server error (500)', () {
        stubError(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body')), 500);
        expect(
              () => apiJobService.updateJob(testJob),
          throwsA(isA<ApiException>()),
        );
      });

      test('throws ApiException if job ID is null', () {
        final jobWithoutId = Job(title: 'No ID', mode: 'MMA', current: '50A');
        expect(
              () => apiJobService.updateJob(jobWithoutId),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'Cannot update job without an ID.',
          )),
        );
      });
    });

    group('updateJobStatus', () {
      test('completes successfully on success (200)', () async {
        stubPutSuccess();
        expect(
          apiJobService.updateJobStatus('1', true),
          completes,
        );
      });

      test('throws ApiException on not found (404)', () {
        stubError(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body')), 404);
        expect(
              () => apiJobService.updateJobStatus('1', true),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('deleteJob', () {
      test('completes successfully on success (200)', () async {
        stubDeleteSuccess();
        expect(
          apiJobService.deleteJob('1'),
          completes,
        );
      });

      test('throws ApiException on server error (500)', () {
        stubError(() => mockHttpClient.delete(any()), 500);
        expect(
              () => apiJobService.deleteJob('1'),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}

