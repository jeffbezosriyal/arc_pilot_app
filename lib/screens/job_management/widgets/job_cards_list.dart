import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:machine_dashboard/blocs/job_management/job_bloc.dart';
import 'package:machine_dashboard/blocs/job_management/job_event.dart';
import 'package:machine_dashboard/blocs/job_management/job_state.dart';
import 'package:machine_dashboard/screens/job_management/widgets/delete_job_sheet.dart';
import 'package:machine_dashboard/screens/job_management/widgets/edit_job_sheet.dart'; // <-- IMPORT NEW SHEET

import '../../../models/job.dart';
import '../../../utils/snackbar_utils.dart';
import 'job_card.dart';
import 'share_job_sheet.dart';

class JobCardsList extends StatelessWidget {
  const JobCardsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state.actionMessage != null) {
          if (state.actionMessageType == ActionMessageType.error) {
            showErrorSnackBar(context, state.actionMessage!);
          } else {
            // Check for the specific delete message
            if (state.actionMessage == 'Job deleted successfully.') {
              showDeleteSnackBar(context, state.actionMessage!);
            } else {
              // Show green snackbar for all other success messages
              showSuccessSnackBar(context, state.actionMessage!);
            }
          }
          // Clear the message after showing it to prevent it from reappearing.
          context.read<JobBloc>().add(ClearJobActionEvent());
        }
      },
      child: Expanded(
        child: Stack(
          children: [
            // The main content area that changes based on state
            _buildContent(),

            // The "Add Job" button is part of the permanent Stack layout
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                // This Container adds the glow effect.
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), // Match button shape
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.35), // Glow color
                        blurRadius: 50.0, // Softness of the glow
                        spreadRadius: 1.0, // How far the glow extends
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 110,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.read<JobBloc>().add(AddNewJobEvent()),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add Job',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build the main content based on the current state.
  Widget _buildContent() {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        switch (state.status) {
          case JobStatus.initial:
          case JobStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case JobStatus.failure:
            return _ApiErrorDisplay(
              onRetry: () => context.read<JobBloc>().add(FetchJobsEvent()),
            );

          case JobStatus.success:
            if (state.filteredJobs.isEmpty) {
              if (state.activeFilters.isNotEmpty) {
                return const Center(
                  child: Text(
                    'No jobs match the selected filters.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                );
              }
              return const Center(
                child: Text(
                  'No jobs found. Add a new job to get started!',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<JobBloc>().add(FetchJobsEvent());
              },
              child: ListView.builder(
                padding:
                const EdgeInsets.fromLTRB(16.0, 0, 16.0, 100.0), // Padding to avoid overlap
                itemCount: state.filteredJobs.length,
                itemBuilder: (context, index) {
                  final job = state.filteredJobs[index];
                  return JobCard(
                    job: job,
                    onToggleActive: () => context
                        .read<JobBloc>()
                        .add(ToggleJobActiveEvent(job)),
                    onDelete: () => _showDeleteConfirmationSheet(context, job),
                    // --- UPDATE THIS LINE ---
                    onEdit: () => _showEditSheet(context, job),
                    // --- END OF UPDATE ---
                    onShare: () => _showShareSheet(context, job),
                  );
                },
              ),
            );
        }
      },
    );
  }

  /// Shows the share job bottom sheet.
  void _showShareSheet(BuildContext context, Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareJobSheet(job: job),
    );
  }

  // --- ADD THIS NEW METHOD ---
  /// Shows the edit job bottom sheet.
  void _showEditSheet(BuildContext context, Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard handling
      backgroundColor: Colors.transparent,
      builder: (_) => EditJobSheet(
        job: job,
        onSave: (updatedJob) {
          // Dispatch the event to the BLoC to update the job
          context.read<JobBloc>().add(UpdateJobEvent(updatedJob));
        },
      ),
    );
  }
  // --- END OF NEW METHOD ---

  /// Shows the delete confirmation bottom sheet.
  void _showDeleteConfirmationSheet(BuildContext context, Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeleteJobSheet(
        job: job,
        onConfirmDelete: () {
          context.read<JobBloc>().add(DeleteJobEvent(job.id!));
        },
      ),
    );
  }
}

/// A private helper widget to display API/network errors.
class _ApiErrorDisplay extends StatelessWidget {
  final VoidCallback onRetry;

  const _ApiErrorDisplay({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.grey[600], size: 80),
            const SizedBox(height: 24),
            Text(
              'Connection Error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Could not connect to the server. Please try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}