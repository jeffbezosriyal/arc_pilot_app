import 'package:flutter/material.dart';
import 'package:machine_dashboard/models/job.dart';

/// A bottom sheet for confirming a job deletion.
class DeleteJobSheet extends StatelessWidget {
  final Job job;
  final VoidCallback onConfirmDelete;

  const DeleteJobSheet({
    super.key,
    required this.job,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: const BoxDecoration(color: Colors.blue),
                    child: const Icon(Icons.delete_sweep, color: Colors.white, size: 24.0),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    'Delete Job',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          // Confirmation Message
          Text(
            'Are you sure you want to delete this job?\nThis action cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16.0),
          // Job Name Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(0.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.settings_input_component, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Job Name: ${job.title}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[700]!),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    onConfirmDelete();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
                  ),
                  child: const Text('Delete', style: TextStyle(fontSize: 16.0)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

