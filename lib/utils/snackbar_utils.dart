import 'package:flutter/material.dart';

/// A utility class for showing consistent, aesthetically pleasing SnackBars.
///
/// The SnackBars are designed to match the app's dark theme, using a
/// floating behavior, rounded corners, and appropriate icons.

/// Shows a generic informational SnackBar.
void showInfoSnackBar(BuildContext context, String message) {
  _showStyledSnackBar(context, message, Icons.info_outline, Colors.blue);
}

/// Shows a success SnackBar with a green checkmark icon.
void showSuccessSnackBar(BuildContext context, String message) {
  _showStyledSnackBar(
      context, message, Icons.check_circle_outline, Colors.green);
}

/// Shows an error SnackBar with a red warning icon.
/// This is used for API errors, network failures, etc.
void showErrorSnackBar(BuildContext context, String message) {
  _showStyledSnackBar(context, message, Icons.error_outline, Colors.red);
}

/// Shows a loading SnackBar. It's typically shorter.
void showLoadingSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any previous snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
          ),
          const SizedBox(width: 16.0),
          Text(message),
        ],
      ),
      backgroundColor: const Color(0xFF2A2A2A).withOpacity(0.95),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: const EdgeInsets.all(16.0),
      duration: const Duration(seconds: 1),
    ),
  );
}

/// Private helper to build and show the styled SnackBar.
void _showStyledSnackBar(
    BuildContext context, String message, IconData icon, Color iconColor) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any previous snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12.0),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: const Color(0xFF2A2A2A).withOpacity(0.95),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: const EdgeInsets.all(16.0),
    ),
  );
}

/// Shows a custom delete confirmation SnackBar.
void showDeleteSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any previous snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.delete_outline, color: Colors.white), // Trash icon
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600, // Make text bold
              ),
            ),
          ),
        ],
      ),
      // Use the same red/orange color as the delete button
      backgroundColor: const Color(0xFFE04000),
      behavior: SnackBarBehavior.floating,
      // Use sharp corners instead of rounded
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      margin: const EdgeInsets.all(16.0),
    ),
  );
}