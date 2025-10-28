import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/job.dart';
import 'job_action_button.dart';

/// Widget to display a single, detailed job card.
///
/// This widget is now responsive and uses a `Wrap` widget to display job
/// parameters, preventing layout overflows on smaller screens.
class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  const JobCard({
    super.key,
    required this.job,
    required this.onToggleActive,
    required this.onDelete,
    required this.onEdit,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    // Determine border color and width based on active status
    final Color borderColor =
    job.isActive ? Colors.green.shade400 : Colors.white70;
    final double borderWidth = job.isActive ? 2.0 : 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(0.0),
      ),
      clipBehavior: Clip.antiAlias, // Ensures children conform to rounded corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This Padding now only contains the top content (header and parameters)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title and Active button
                _buildHeader(),
                const SizedBox(height: 16),
                // Parameters
                Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _buildParametersWithSeparators(),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),

          // NEW: This Container is specifically for the action buttons row
          Container(
            color: Colors.grey[850], // The requested grey background for the row
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                JobActionButton(
                    icon: Icons.edit, label: 'Edit', onPressed: onEdit),
                JobActionButton(
                    icon: Icons.delete,
                    label: 'Delete',
                    iconColor: Colors.red.shade400,
                    onPressed: onDelete),
                JobActionButton(
                    icon: Icons.share, label: 'Share', onPressed: onShare),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Helper for building the Header section
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            job.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onToggleActive();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: job.isActive ? Colors.green : Colors.grey[800],
              borderRadius: BorderRadius.circular(0),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                color: job.isActive ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper method to build the list of parameter widgets and insert separators.
  List<Widget> _buildParametersWithSeparators() {
    final List<Widget> parameterWidgets = [];

    // Collect all available parameter widgets into a list
    if (job.current.isNotEmpty) {
      parameterWidgets.add(_buildParameterText('Current : ${job.current}'));
    }
    if (job.hotStartTime.isNotEmpty) {
      parameterWidgets
          .add(_buildParameterText('Hot Start : ${job.hotStartTime}'));
    }
    if (job.wave.isNotEmpty) {
      parameterWidgets.add(_buildParameterText('Wave : ${job.wave}'));
    }
    if (job.base.isNotEmpty) {
      parameterWidgets.add(_buildParameterText('Base : ${job.base}'));
    }
    if (job.pulse.isNotEmpty) {
      parameterWidgets.add(_buildParameterText('Pulse : ${job.pulse}'));
    }
    if (job.duty.isNotEmpty) {
      parameterWidgets.add(_buildParameterText('Duty : ${job.duty}'));
    }
    if (job.wire.isNotEmpty) {
      parameterWidgets.add(_buildParameterText('Wire : ${job.wire}'));
    }
    if (job.shieldingGas.isNotEmpty) {
      parameterWidgets
          .add(_buildParameterText('Shielding gas: ${job.shieldingGas}'));
    }
    if (job.arcLength.isNotEmpty) {
      parameterWidgets.add(_buildParameterText('Arc length : ${job.arcLength}'));
    }
    if (job.diameter.isNotEmpty) {
      parameterWidgets.add(_buildParameterText('Diameter : ${job.diameter}'));
    }
    if (job.inductance.isNotEmpty) {
      parameterWidgets.add(_buildParameterText('Inductance : ${job.inductance}'));
    }

    final List<Widget> finalChildren = [];

    // Add the styled "Mode" chip first
    finalChildren.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Mode : ${job.mode}',
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );

    // If there are other parameters, add them with "|" separators
    if (parameterWidgets.isNotEmpty) {
      const separator = Text(
        '|',
        style: TextStyle(color: Colors.white30, fontSize: 14),
      );
      final separatedWidgets =
      parameterWidgets.expand((widget) => [widget, separator]).toList();
      separatedWidgets.removeLast();
      finalChildren.addAll(separatedWidgets);
    }

    return finalChildren;
  }

  /// Helper method to create consistently styled text widgets for job parameters.
  Widget _buildParameterText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 14),
    );
  }
}

