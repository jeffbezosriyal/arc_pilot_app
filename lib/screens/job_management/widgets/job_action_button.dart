import 'package:flutter/material.dart';

/// A reusable helper widget for the action buttons (e.g., Edit, Delete, Share) on a [JobCard].
///
/// This widget provides a consistent look and feel for actions, combining an
/// icon and a label within an [InkWell] for tap feedback.
class JobActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final VoidCallback onPressed;

  const JobActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor ?? Colors.white70, size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
