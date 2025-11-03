import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting
import 'package:machine_dashboard/blocs/arc_time_metric/arc_time_metric_bloc.dart'; // Import enum
import 'package:machine_dashboard/models/arc_time_metric.dart';
import '../api/api_exceptions.dart';
import 'arc_time_service.dart';

/// An implementation of the ArcTimeService that communicates with a REST API.
class ApiArcTimeService implements ArcTimeService {
  // Use the same base URL as the job service
  static const String baseUrl = 'https://job-management-api-hjx3.onrender.com/api';
  final http.Client _client;

  ApiArcTimeService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<ArcTimeMetric> fetchArcTime({
    required DateTime date,
    // --- MODIFICATION: RE-ADDED 'range' ---
    required ArcTimeRange range,
    // --- END MODIFICATION ---
  }) async {
    // --- MODIFICATION: RESTORED 'rangeString' LOGIC ---
    // Convert range enum to string for API query parameter
    final String rangeString = describeEnum(range); // e.g., 'week', 'month', 'year'
    // --- END MODIFICATION ---

    // Format date as YYYY-MM-DD
    final String dateString = DateFormat('yyyy-MM-dd').format(date);

    // --- MODIFICATION: Updated URL to include 'range' query param ---
    // Build the URL with query parameters
    final uri = Uri.parse('$baseUrl/arctime?date=$dateString&range=$rangeString');
    // --- END MODIFICATION ---

    debugPrint('Fetching ArcTime from: $uri'); // Log the URL

    final dynamic data = await _handleRequest(() => _client.get(uri));

    // Handle potential null response if API returns empty body on 200/201
    if (data == null) {
      // Return an initial/empty state or throw a specific error
      // Depending on how you want the UI to behave for no data
      return ArcTimeMetric.initial(); // Example: return empty state
      // Or: throw ApiException('No data received from the server.');
    }

    // The API returns a single JSON object, not a list
    return ArcTimeMetric.fromJson(data);
  }


  // --- Helper Methods for API Communication ---
  // (These are copied from ApiJobService for robustness)

  Future<dynamic> _handleRequest(Future<http.Response> Function() requestFunc) async {
    try {
      final response = await requestFunc().timeout(const Duration(seconds: 15)); // Increased timeout
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      // Provide more context for unexpected errors
      debugPrint('Unexpected API Error: $e');
      throw ApiException('An unexpected error occurred. Please check logs.');
    }
  }

  dynamic _processResponse(http.Response response) {
    debugPrint('API Response: ${response.statusCode} - ${response.body}');
    switch (response.statusCode) {
      case 200: // OK
      case 201: // Created
      // Important: Handle empty body explicitly
        return response.body.isNotEmpty ? json.decode(response.body) : null;
      case 400:
      // Try to parse error message from body if available
        String message = 'Bad Request: The server could not process the request.';
        if(response.body.isNotEmpty) {
          try { message += ' Details: ${json.decode(response.body)['message'] ?? response.body}'; } catch (_) {}
        }
        throw ApiException(message);
      case 404:
        throw ApiException('Not Found: The requested endpoint ($baseUrl/arctime) does not exist or data is unavailable for the selected period.');
      case 500:
      case 502: // Bad Gateway
      case 503: // Service Unavailable
        throw ApiException('Server Error (${response.statusCode}): Could not connect to the server or an internal error occurred.');
      default:
        throw ApiException('API Error: ${response.statusCode}. ${response.body}');
    }
  }
}

// Helper to convert enum to string (or use describeEnum from foundation)
// String _rangeToString(ArcTimeRange range) {
//   return range.toString().split('.').last;
// }