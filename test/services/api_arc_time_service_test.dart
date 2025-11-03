import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:machine_dashboard/api/api_exceptions.dart';
import 'package:machine_dashboard/blocs/arc_time_metric/arc_time_metric_bloc.dart';
import 'package:machine_dashboard/models/arc_time_metric.dart';
import 'package:mockito/mockito.dart';
import 'package:machine_dashboard/services/api_arc_time_service.dart';

import '../mocks.mocks.dart';

void main() {
  late MockClient mockClient;
  late ApiArcTimeService apiArcTimeService;
  final baseUrl = ApiArcTimeService.baseUrl;

  setUp(() {
    mockClient = MockClient();
    apiArcTimeService = ApiArcTimeService(client: mockClient);
  });

  // Helper for mock responses
  void setupMockGetResponse(
      Future<http.Response> Function(Invocation) response,
      ) {
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer(response);
  }

  // Helper to create mock metric JSON
  Map<String, dynamic> createMockMetricJson() => {
    'totalArcTimeInSeconds': 3600,
    'lastUpdated': '2023-01-01T12:00:00.000Z',
    'weeklyData': [
      {'label': 'Mon', 'value': 1.0}
    ],
    'monthlyData': [
      {'label': '01', 'value': 2.0}
    ],
    'yearlyData': [
      {'label': 'Jan', 'value': 3.0}
    ],
  };

  group('ApiArcTimeService', () {
    final testDate = DateTime(2023, 10, 27);
    const testRange = ArcTimeRange.week;
    final dateString = DateFormat('yyyy-MM-dd').format(testDate);
    final rangeString = describeEnum(testRange);
    final uri =
    Uri.parse('$baseUrl/arctime?date=$dateString&range=$rangeString');

    group('fetchArcTime', () {
      test('returns ArcTimeMetric on successful response (200)', () async {
        final mockJson = createMockMetricJson();
        setupMockGetResponse(
                (_) async => http.Response(json.encode(mockJson), 200));

        final metric = await apiArcTimeService.fetchArcTime(
          date: testDate,
          range: testRange,
        );

        expect(metric, isA<ArcTimeMetric>());
        expect(metric.totalArcTime, const Duration(seconds: 3600));
        expect(metric.weeklyData.first.label, 'Mon');
        verify(mockClient.get(uri));
      });

      test('returns ArcTimeMetric.initial() on 200 with empty body', () async {
        setupMockGetResponse((_) async => http.Response('', 200));

        final metric = await apiArcTimeService.fetchArcTime(
          date: testDate,
          range: testRange,
        );

        // The service logic explicitly handles null from _processResponse
        // by returning ArcTimeMetric.initial().
        expect(metric.totalArcTime, ArcTimeMetric.initial().totalArcTime);
        expect(metric.weeklyData.length, ArcTimeMetric.initial().weeklyData.length);
        verify(mockClient.get(uri));
      });

      test('throws ApiException on 400 response', () async {
        setupMockGetResponse((_) async => http.Response('{"message": "Invalid range"}', 400));

        expect(
              () => apiArcTimeService.fetchArcTime(date: testDate, range: testRange),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'Bad Request: The server could not process the request. Details: Invalid range',
          )),
        );
      });

      test('throws ApiException on 400 response with non-json body', () async {
        setupMockGetResponse((_) async => http.Response('Bad Request', 400));

        expect(
              () => apiArcTimeService.fetchArcTime(date: testDate, range: testRange),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            // --- THIS IS THE FIX ---
            // The original message is correct because the non-JSON body
            // causes the json.decode() to fail, and the catch block is empty.
            'Bad Request: The server could not process the request.',
            // --- END OF FIX ---
          )),
        );
      });

      test('throws ApiException on 404 response', () async {
        setupMockGetResponse((_) async => http.Response('Not Found', 404));

        expect(
              () => apiArcTimeService.fetchArcTime(date: testDate, range: testRange),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'Not Found: The requested endpoint ($baseUrl/arctime) does not exist or data is unavailable for the selected period.',
          )),
        );
      });

      test('throws ApiException on 500 response', () async {
        setupMockGetResponse((_) async => http.Response('Server Error', 500));

        expect(
              () => apiArcTimeService.fetchArcTime(date: testDate, range: testRange),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'Server Error (500): Could not connect to the server or an internal error occurred.',
          )),
        );
      });

      test('throws ApiException on 503 response', () async {
        setupMockGetResponse((_) async => http.Response('Service Unavailable', 503));

        expect(
              () => apiArcTimeService.fetchArcTime(date: testDate, range: testRange),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'Server Error (503): Could not connect to the server or an internal error occurred.',
          )),
        );
      });

      test('throws ApiException on SocketException (no network)', () async {
        when(mockClient.get(any))
            .thenThrow(const SocketException('No Internet'));

        expect(
              () => apiArcTimeService.fetchArcTime(date: testDate, range: testRange),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'No Internet connection. Please check your network.',
          )),
        );
      });

      test('throws ApiException on TimeoutException', () async {
        when(mockClient.get(any))
            .thenThrow(TimeoutException('Request timed out'));

        expect(
              () => apiArcTimeService.fetchArcTime(date: testDate, range: testRange),
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
              () => apiArcTimeService.fetchArcTime(date: testDate, range: testRange),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            'An unexpected error occurred. Please check logs.',
          )),
        );
      });
    });
  });
}