import 'dart:math';
import 'package:flutter/material.dart';

/// A set of reusable bottom sheet widgets used in the Machine Settings screen.
///
/// This file centralizes the UI and logic for various modal dialogs like
/// renaming, reset confirmations, and success/failure notifications, keeping
/// the main page widget clean and focused on layout.

// --- 1. Rename Machine Bottom Sheet ---

class RenameMachineSheet extends StatefulWidget {
  final String currentName;
  final Function(String) onSave;

  const RenameMachineSheet({
    super.key,
    required this.currentName,
    required this.onSave,
  });

  @override
  State<RenameMachineSheet> createState() => _RenameMachineSheetState();
}

class _RenameMachineSheetState extends State<RenameMachineSheet> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Validates the new name and calls the onSave callback if valid.
  void _validateAndSave() {
    final newName = _controller.text.trim();
    if (mounted) {
      setState(() {
        if (newName.isEmpty) {
          _errorText = 'Machine name cannot be empty';
        } else {
          _errorText = null;
          widget.onSave(newName);
          Navigator.pop(context); // Close the sheet on success
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adjust padding to account for the on-screen keyboard
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardPadding),
      child: Container(
        height: 268.0,
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        decoration: const BoxDecoration(
          color: Color(0xFF000000),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSheetHeader(
              context,
              icon: Icons.drive_file_rename_outline,
              title: 'Rename the machine',
            ),
            const SizedBox(height: 24.0),
            Text(
              'Enter new machine name',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _controller,
              autofocus: true,
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
                errorText: _errorText,
                errorStyle: const TextStyle(color: Colors.redAccent),
              ),
            ),
            const Spacer(),
            _buildActionButtons(
              context,
              confirmText: 'Save',
              onConfirm: _validateAndSave,
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. Remove Machine Confirmation Bottom Sheet ---

class RemoveMachineConfirmationSheet extends StatelessWidget {
  const RemoveMachineConfirmationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 268.0,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 16.0),
          _buildSheetHeader(
            context,
            icon: Icons.delete,
            title: 'Remove Machine',
          ),
          const SizedBox(height: 16.0),
          Text(
            'Are you sure you want to remove this machine\nfrom your dashboard?\nThis action cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, height: 1.5),
          ),
          const Spacer(),
          _buildActionButtons(
            context,
            confirmText: 'Remove',
            onConfirm: () {
              // TODO: Implement actual machine removal logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Machine removal initiated')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// --- 3. Reset Confirmation Bottom Sheet ---

class ResetConfirmationSheet extends StatelessWidget {
  const ResetConfirmationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 258.0,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      decoration: const BoxDecoration(color: Colors.black),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 16.0),
          _buildSheetHeader(
            context,
            icon: Icons.refresh,
            title: 'Reset Machine Settings',
          ),
          const SizedBox(height: 16.0),
          Text(
            'This will restore all machine settings to their factory defaults. Any customized settings will be lost. Are you sure you want to continue?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const Spacer(),
          _buildActionButtons(
            context,
            confirmText: 'Confirm Reset',
            onConfirm: () {
              final bool isSuccess = Random().nextBool(); // Simulate success/failure
              Navigator.pop(context); // Close this sheet first
              // Then show the result sheet
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return isSuccess ? const ResetSuccessSheet() : const ResetFailedSheet();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- 4. Reset Result Bottom Sheets (Success & Failed) ---

class ResetSuccessSheet extends StatelessWidget {
  const ResetSuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildResultSheet(
      context,
      title: 'Reset Machine Settings',
      icon: Icons.refresh,
      resultText: 'Reset successful!',
      message: 'The machine has been restored to factory defaults.',
      isSuccess: true,
    );
  }
}

class ResetFailedSheet extends StatelessWidget {
  const ResetFailedSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildResultSheet(
      context,
      title: 'Reset Machine Settings',
      icon: Icons.refresh,
      resultText: 'Reset failed!',
      message: 'Please try again or contact support.',
      isSuccess: false,
    );
  }
}

// --- Helper Widgets for Bottom Sheets ---

/// A generic widget for building the header of a bottom sheet.
Widget _buildSheetHeader(BuildContext context, {required IconData icon, required String title}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: const BoxDecoration(color: Colors.blue),
            child: Icon(icon, color: Colors.white, size: 24.0),
          ),
          const SizedBox(width: 12.0),
          Text(
            title,
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

/// A generic layout for displaying the result of an action (e.g., success or failure).
Widget _buildResultSheet(
    BuildContext context, {
      required String title,
      required IconData icon,
      required String resultText,
      required String message,
      required bool isSuccess,
    }) {
  final Color resultColor = isSuccess ? Colors.green : Colors.red;
  final IconData resultIcon = isSuccess ? Icons.check_circle : Icons.cancel;

  return Container(
    height: 268.0,
    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
    decoration: const BoxDecoration(color: Colors.black),
    child: Column(
      children: [
        _buildSheetHeader(context, icon: icon, title: title),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.blue, size: 64.0),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(resultIcon, color: resultColor, size: 24.0),
                  const SizedBox(width: 8.0),
                  Text(
                    resultText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: resultColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
