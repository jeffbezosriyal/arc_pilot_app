import 'package:flutter/material.dart';
import '../../../models/job.dart';

class EditJobSheet extends StatefulWidget {
  final Job job;
  final Function(Job updatedJob) onSave;

  const EditJobSheet({
    super.key,
    required this.job,
    required this.onSave,
  });

  @override
  State<EditJobSheet> createState() => _EditJobSheetState();
}

class _EditJobSheetState extends State<EditJobSheet> {
  late TextEditingController _titleController;
  late TextEditingController _modeController;
  late TextEditingController _currentController;
  late TextEditingController _wireController;
  late TextEditingController _gasController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing job's data
    _titleController = TextEditingController(text: widget.job.title);
    _modeController = TextEditingController(text: widget.job.mode);
    _currentController = TextEditingController(text: widget.job.current);
    _wireController = TextEditingController(text: widget.job.wire);
    _gasController = TextEditingController(text: widget.job.shieldingGas);
  }

  @override
  void dispose() {
    // Clean up all controllers
    _titleController.dispose();
    _modeController.dispose();
    _currentController.dispose();
    _wireController.dispose();
    _gasController.dispose();
    super.dispose();
  }

  /// Validates and saves the changes
  void _validateAndSave() {
    // Create a new Job object with the updated values,
    // making sure to preserve the ID and other unchanged fields.
    final updatedJob = Job(
      id: widget.job.id, // Preserve the original ID
      isActive: widget.job.isActive, // Preserve active status

      // Get updated values from controllers
      title: _titleController.text.trim(),
      mode: _modeController.text.trim(),
      current: _currentController.text.trim(),
      wire: _wireController.text.trim(),
      shieldingGas: _gasController.text.trim(),

      // Preserve all other fields that are not edited in this form
      hotStartTime: widget.job.hotStartTime,
      wave: widget.job.wave,
      base: widget.job.base,
      pulse: widget.job.pulse,
      duty: widget.job.duty,
      arcLength: widget.job.arcLength,
      diameter: widget.job.diameter,
      inductance: widget.job.inductance,
    );

    // Pass the updated job back via the callback
    widget.onSave(updatedJob);
    Navigator.pop(context); // Close the sheet
  }

  @override
  Widget build(BuildContext context) {
    // Adjust padding to account for the on-screen keyboard
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardPadding),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        decoration: const BoxDecoration(
          color: Color(0xFF000000),
        ),
        // Use SingleChildScrollView to prevent overflow when keyboard appears
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              const SizedBox(height: 16.0),
              _buildSheetHeader(context),
              const SizedBox(height: 24.0),

              // Form Fields
              _buildTextField(_titleController, 'Job Title'),
              _buildTextField(_modeController, 'Mode (e.g., MMA, LIFT TIG)'),
              _buildTextField(_currentController, 'Current (e.g., 85A)'),
              _buildTextField(_wireController, 'Wire (e.g., Alu)'),
              _buildTextField(_gasController, 'Shielding Gas (e.g., Argon)'),

              const SizedBox(height: 24.0),
              _buildActionButtons(
                context,
                confirmText: 'Save',
                onConfirm: _validateAndSave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a styled text field for the form
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: controller,
            autofocus: (label == 'Job Title'), // Autofocus the first field
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF252525),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A handle for the top of the bottom sheets.
  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40.0,
        height: 4.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
    );
  }

  /// A generic widget for building the header of a bottom sheet.
  Widget _buildSheetHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: const BoxDecoration(color: Colors.blue),
              child: const Icon(Icons.edit, color: Colors.white, size: 24.0),
            ),
            const SizedBox(width: 12.0),
            Text(
              'Edit Job',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  /// A generic widget for building the confirm/cancel action buttons.
  Widget _buildActionButtons(BuildContext context, {required String confirmText, required VoidCallback onConfirm}) {
    return Row(
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
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
            ),
            child: Text(confirmText, style: const TextStyle(fontSize: 16.0)),
          ),
        ),
      ],
    );
  }
}