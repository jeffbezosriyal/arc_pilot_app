// import 'dart:convert';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart' as http;
// import 'package:machine_dashboard/api/api_exceptions.dart';
// import 'package:machine_dashboard/models/arc_time_metric.dart';
// import 'package:machine_dashboard/services/api_arc_time_service.dart';
// import 'package:mocktail/mocktail.dart';
// import '../mocks.dart'; // Import mocks
//
// void main() {
//   late ApiArcTimeService service;
//   late MockHttpClient mockHttpClient;
//
//   setUp(() {
//     mockHttpClient = MockHttpClient();
//     service = ApiArcTimeService(client: mockHttpClient);
//     // Register fallback values for Uri
//     registerFallbackValue(Uri());
//   });
//
//   // --- Helper to stub successful GET response ---
//   void stubGetSuccess(Map<String, dynamic> responseJson) {
//     when(() => mockHttpClient.get(any())).thenAnswer(
//           (_) async => http.Response(json.encode(responseJson), 200),
//     );
//   }
//
//   // --- Helper to stub failed GET response ---
//   void stubGetFailure(int statusCode, String body) {
//     when(() => mockHttpClient.get(any())).thenAnswer(
//           (_) async => http.Response(body, statusCode),
//     );
//   }
//
//   group('ApiArcTimeService', () {
//     // Example valid JSON response from the API
//     final validJsonResponse = {
//       "totalArcTimeInSeconds": 3600, // 1 hour
//       "lastUpdated": "2025-01-01T00:00:00.000",
//       "weeklyData": [{"label": "Mon", "value": 1.0}],
//       "monthlyData": [{"label": "01", "value": 2.0}],
//       "yearlyData": [{"label": "Jan", "value": 3.0}],
//     };
//
//     test('fetchArcTime returns ArcTimeMetric on success (200)', () async {
//       // Arrange
//       stubGetSuccess(validJsonResponse);
//
//       // Act
//       final result = await service.fetchArcTime();
//
//       // Assert
//       expect(result, isA<ArcTimeMetric>());
//       expect(result.totalArcTime, const Duration(hours: 1));
//       expect(result.weeklyData.first.label, 'Mon');
//       verify(() => mockHttpClient.get(Uri.parse('${ApiArcTimeService.baseUrl}/arctime'))).called(1);
//     });
//
//     test('fetchArcTime throws ApiException on server error (500)', () async {
//       // Arrange
//       stubGetFailure(500, 'Server Error');
//
//       // Act & Assert
//       expect(
//             () => service.fetchArcTime(),
//         throwsA(isA<ApiException>().having(
//               (e) => e.message,
//           'message',
//           // --- FIX: Correct expected message ---
//           'Server Error: An internal server error occurred.',
//           // --- END FIX ---
//         )),
//       );
//       verify(() => mockHttpClient.get(any())).called(1);
//     });
//
//     test('fetchArcTime throws ApiException on not found (404)', () async {
//       // Arrange
//       stubGetFailure(404, 'Not Found');
//
//       // Act & Assert
//       expect(
//             () => service.fetchArcTime(),
//         throwsA(isA<ApiException>().having(
//               (e) => e.message,
//           'message',
//           'Not Found: The requested endpoint does not exist.',
//         )),
//       );
//     });
//
//     test('fetchArcTime throws ApiException on bad request (400)', () async {
//       // Arrange
//       stubGetFailure(400, 'Bad Request');
//
//       // Act & Assert
//       expect(
//             () => service.fetchArcTime(),
//         throwsA(isA<ApiException>().having(
//               (e) => e.message,
//           'message',
//           'Bad Request: The server could not process the request.',
//         )),
//       );
//     });
//
//     // Add more tests for other scenarios (e.g., TimeoutException, SocketException)
//     test('fetchArcTime throws ApiException on TimeoutException', () async {
//       // Arrange
//       when(() => mockHttpClient.get(any())).thenAnswer((_) async {
//         await Future.delayed(const Duration(seconds: 11)); // Simulate delay > 10s
//         return http.Response('', 200);
//       });
//
//       // Act & Assert
//       expect(
//             () => service.fetchArcTime(),
//         throwsA(isA<ApiException>().having(
//               (e) => e.message,
//           'message',
//           'The request timed out. Please try again.',
//         )),
//       );
//     });
//
//   });
// }
//
