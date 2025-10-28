import '../models/job.dart';

/// Abstract interface for the job data source.
///
/// This contract ensures that the UI is completely decoupled from the data source.
/// Whether the data comes from an API, Bluetooth, or a local database,
/// the methods to interact with it remain the same.
abstract class JobService {
  Future<List<Job>> fetchJobs();
  Future<void> addJob(Job newJob);
  Future<void> updateJobStatus(String jobId, bool isActive);
  Future<void> deleteJob(String jobId);
  Future<void> updateJob(Job updatedJob); // <-- ADD THIS LINE
}

