import 'package:flutter/material.dart';

class FilterJobSheet extends StatefulWidget {
  // The set of filters that are currently active
  final Set<String> activeFilters;
  // Callback to send the new set of filters back when 'Apply' is pressed
  final Function(Set<String>) onApply;

  const FilterJobSheet({
    super.key,
    required this.activeFilters,
    required this.onApply,
  });

  @override
  State<FilterJobSheet> createState() => _FilterJobSheetState();
}

class _FilterJobSheetState extends State<FilterJobSheet> {
  late Set<String> _selectedModes;

  // List of all available modes based on the screenshot
  final List<String> _allModes = const [
    'MMA',
    'LIFT TIG',
    'HF TIG',
    'SMART TIG',
    'MIG MAN',
    'MIG SYN',
    'MIG PULSE',
    'MIG DP',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the local state with the filters passed from the page
    _selectedModes = Set<String>.from(widget.activeFilters);
  }

  /// Toggles the selection state of a filter mode.
  void _onCheckboxChanged(bool? value, String mode) {
    setState(() {
      if (value == true) {
        _selectedModes.add(mode);
      } else {
        _selectedModes.remove(mode);
      }
    });
  }

  /// Resets all filters to be unselected.
  void _onReset() {
    setState(() {
      _selectedModes.clear();
    });
  }

  /// Applies the selected filters and closes the sheet.
  void _onApply() {
    widget.onApply(_selectedModes);
    Navigator.pop(context);
  }

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
          _buildDragHandle(),
          const SizedBox(height: 16.0),
          _buildSheetHeader(context),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Mode',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8.0),
          // Use Flexible and ListView for scrolling if content overflows
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _allModes.length,
              itemBuilder: (context, index) {
                final mode = _allModes[index];
                final isSelected = _selectedModes.contains(mode);
                return _buildCheckboxOption(
                  title: mode,
                  value: isSelected,
                  onChanged: (value) => _onCheckboxChanged(value, mode),
                );
              },
            ),
          ),
          const SizedBox(height: 24.0),
          _buildActionButtons(context),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
    );
  }

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
              child: const Icon(Icons.filter_list, color: Colors.white, size: 24.0),
            ),
            const SizedBox(width: 12.0),
            Text(
              'Filter',
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

  Widget _buildCheckboxOption({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    // Wrap in a GestureDetector to make the whole row tappable
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        color: Colors.transparent, // Makes sure gesture detector hits
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue, // Active color from screenshot
              checkColor: Colors.white, // Checkmark color
              side: const BorderSide(color: Colors.white, width: 2),
              visualDensity: VisualDensity.compact,
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _onReset,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[700]!),
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: ElevatedButton(
            onPressed: _onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
            ),
            child: const Text(
              'Apply',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}