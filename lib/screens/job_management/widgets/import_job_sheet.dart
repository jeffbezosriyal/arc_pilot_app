import 'package:flutter/material.dart';
import '../../../models/job.dart'; // <-- IMPORT THE JOB MODEL

/// A bottom sheet for handling the job import process.
class ImportJobSheet extends StatefulWidget {
  // Callback to pass the new job and replace flag back to the page
  final Function(Job job, bool replace) onSave;

  const ImportJobSheet({
    super.key,
    required this.onSave, // <-- ADD THIS REQUIRED PARAMETER
  });

  @override
  State<ImportJobSheet> createState() => _ImportJobSheetState();
}

class _ImportJobSheetState extends State<ImportJobSheet> {
  String? _selectedFileName;
  bool _replaceJob = true;

  void _onCheckboxChanged(bool? value, bool isReplace) {
    if (value == true) {
      setState(() {
        _replaceJob = isReplace;
      });
    }
  }

  void _selectFile() {
    // This is a placeholder for actual file picking logic
    // In a real app, you'd use a file picker and parse the file.
    setState(() {
      _selectedFileName = 'Structural Steel Welding';
    });
  }

  void _onSavePressed() {
    if (_selectedFileName == null) {
      // Don't save if no file is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }

    // --- Placeholder Job Creation ---
    // In a real app, you would parse the selected file to get this data.
    // For now, we create a new job based on the placeholder file name.
    final newJob = Job(
      title: _selectedFileName!,
      mode: 'MIG SYN', // Example data
      current: '120A',  // Example data
      wire: 'Steel',   // Example data
      shieldingGas: 'Ar/CO2', // Example data
    );

    // Use the callback to send the new job back to the page
    widget.onSave(newJob, _replaceJob);

    Navigator.pop(context); // Close the sheet
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding:
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0.0),
              topRight: Radius.circular(0.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDragHandle(),
              const SizedBox(height: 16.0),
              _buildSheetHeader(context),
              const SizedBox(height: 24.0),
              _buildFileSelector(),
              const SizedBox(height: 24.0),
              _buildCheckboxOption(
                title: 'Already exists, wants to Replace the Job',
                value: _replaceJob,
                onChanged: (value) => _onCheckboxChanged(value, true),
              ),
              _buildCheckboxOption(
                title: 'Create as new one',
                value: !_replaceJob,
                onChanged: (value) => _onCheckboxChanged(value, false),
              ),
              const SizedBox(height: 24.0),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelector() {
    if (_selectedFileName == null) {
      return GestureDetector(
        onTap: _selectFile,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            border:
            Border.all(color: Colors.grey.shade700, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_drive_file_outlined, color: Colors.white70),
              SizedBox(width: 8.0),
              Text(
                'Select file',
                style: TextStyle(color: Colors.white70, fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12.0),
            Flexible(
              child: Text(
                _selectedFileName!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCheckboxOption(
      {required String title,
        required bool value,
        required ValueChanged<bool?> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            checkColor: Colors.black,
            side: const BorderSide(color: Colors.white),
          ),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40.0,
        height: 4.0,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.file_download, color: Colors.blue, size: 28.0),
            SizedBox(width: 12.0),
            Text(
              'Import Job',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[700]!),
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0)),
            ),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 16.0, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: ElevatedButton(
            onPressed: _onSavePressed, // <-- UPDATE THIS LINE
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0)),
            ),
            child: const Text('Save', style: TextStyle(fontSize: 16.0)),
          ),
        ),
      ],
    );
  }
}