import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api/api_exceptions.dart';
import '../models/job.dart';
import 'job_service.dart';

/// An implementation of the JobService that communicates with a REST API.
class ApiJobService implements JobService {
  static const String baseUrl = 'https://job-management-api-hjx3.onrender.com/api/jobs';
  final http.Client _client;

  ApiJobService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<Job>> fetchJobs() async {
    final dynamic data = await _handleRequest(() => _client.get(Uri.parse(baseUrl)));
    return (data as List).map((jobJson) => Job.fromJson(jobJson)).toList();
  }

  @override
  Future<void> addJob(Job newJob) async {
    await _handleRequest(() => _client.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newJob.toJson()),
    ));
  }

  @override
  Future<void> updateJobStatus(String jobId, bool isActive) async {
    await _handleRequest(() => _client.put(
      Uri.parse('$baseUrl/$jobId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isActive': isActive}),
    ));
  }

  @override
  Future<void> deleteJob(String jobId) async {
    await _handleRequest(() => _client.delete(Uri.parse('$baseUrl/$jobId')));
  }

  // --- Helper Methods for API Communication ---

  Future<T> _handleRequest<T>(Future<http.Response> Function() requestFunc) async {
    try {
      final response = await requestFunc().timeout(const Duration(seconds: 30));
      return _processResponse(response);
    } on SocketException {
      throw ApiException('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  dynamic _processResponse(http.Response response) {
    debugPrint('API Response: ${response.statusCode} - ${response.body}');
    switch (response.statusCode) {
      case 200:
      case 201:
        return response.body.isNotEmpty ? json.decode(response.body) : null;
      case 400:
        throw ApiException('Bad Request: The server could not process the request.');
      case 404:
        throw ApiException('Not Found: The requested endpoint does not exist.');
      case 500:
        throw ApiException('Server Error: An internal server error occurred.');
      default:
        throw ApiException('Server Error: ${response.statusCode}. ${response.body}');
    }
  }

  @override
  Future<void> updateJob(Job updatedJob) async {
    // Ensure the job has an ID, otherwise we can't update it.
    if (updatedJob.id == null) {
      throw ApiException('Cannot update job without an ID.');
    }

    final jobId = updatedJob.id;

    await _handleRequest(() => _client.put(
      Uri.parse('$baseUrl/$jobId'),
      headers: {'Content-Type': 'application/json'},
      // The toJson() method correctly formats the body for the API
      body: json.encode(updatedJob.toJson()),
    ));
  }
}

