import 'package:flutter/material.dart';
import 'package:machine_dashboard/blocs/arc_time_metric/arc_time_metric_bloc.dart'; // Import enum

class TimeRangeSelector extends StatelessWidget {
  final ArcTimeRange selectedRange;
  final ValueChanged<ArcTimeRange> onRangeSelected;

  const TimeRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Define the button labels
    final ranges = {
      ArcTimeRange.week: 'Week',
      ArcTimeRange.month: 'Month',
      ArcTimeRange.year: 'Year',
      ArcTimeRange.custom: 'Custom',
    };

    return Container(
      // Keep the outer container styling the same
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ranges.entries.map((entry) {
          final range = entry.key;
          final label = entry.value;
          final bool isSelected = (selectedRange == range);

          return Expanded(
            child: GestureDetector(
              onTap: () => onRangeSelected(range),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.symmetric(vertical: 8.0), // Keep padding for text
                // --- THIS IS THE CHANGE ---
                decoration: BoxDecoration(
                  border: isSelected
                      ? const Border(
                    bottom: BorderSide(
                      color: Colors.blue, // Underline color
                      width: 3.0,       // Underline thickness
                    ),
                  )
                      : null, // No border if not selected
                  // Keep the button rounding if you want, or remove for sharper corners
                  // borderRadius: BorderRadius.circular(6.0),
                ),
                // --- END OF CHANGE ---
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      // Keep the text color change
                      color: isSelected ? Colors.blue : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}