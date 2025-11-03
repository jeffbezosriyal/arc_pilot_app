import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:machine_dashboard/blocs/job_management/job_bloc.dart';
import 'package:machine_dashboard/blocs/job_management/job_event.dart';
import 'package:machine_dashboard/blocs/job_management/job_state.dart';
import 'package:machine_dashboard/models/job.dart';
import 'package:machine_dashboard/screens/job_management/widgets/filter_job_sheet.dart';
import 'package:machine_dashboard/screens/job_management/widgets/import_job_sheet.dart';
import 'package:machine_dashboard/screens/job_management/widgets/job_cards_list.dart';
import '../../widgets/my_drawer.dart';

// --- CONVERT TO STATEFUL WIDGET ---
class JobManagementPage extends StatefulWidget {
  const JobManagementPage({super.key});

  @override
  State<JobManagementPage> createState() => _JobManagementPageState();
}

class _JobManagementPageState extends State<JobManagementPage> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the query from the BLoC, if any
    final initialQuery = context.read<JobBloc>().state.searchQuery;
    _searchController = TextEditingController(text: initialQuery);

    // Add a debounced listener
    _searchController.addListener(() {
      // If a timer is already active, cancel it
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      // Start a new timer
      _debounce = Timer(const Duration(milliseconds: 500), () {
        final newQuery = _searchController.text;
        final currentQuery = context.read<JobBloc>().state.searchQuery;

        // Only dispatch if the text has actually changed
        if (newQuery != currentQuery) {
          context.read<JobBloc>().add(SearchJobsEvent(newQuery));
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
  // --- END OF STATEFUL WIDGET SETUP ---

  void _openFilterMenu(BuildContext context, Set<String> currentFilters) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterJobSheet(
        activeFilters: currentFilters,
        onApply: (selectedModes) {
          context.read<JobBloc>().add(ApplyJobFilterEvent(selectedModes));
        },
      ),
    );
  }

  void _openImportMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImportJobSheet(
        onSave: (Job newJob, bool replace) {
          context.read<JobBloc>().add(AddSpecificJobEvent(newJob));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Job Management',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(
            color: Colors.blue,
            width: 1,
          ),
        ),
      ),
      drawer: const MyDrawer(),
      body: BlocBuilder<JobBloc, JobState>(
        // Listen to state changes
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Pass the filter count from the state
                    _buildSearchBar(context, state.activeFilters),
                    const SizedBox(width: 16),
                    _buildImportButton(context),
                  ],
                ),
              ),
              _buildActiveFilters(context, state.activeFilters),
              const JobCardsList(),
            ],
          );
        },
      ),
    );
  }

  /// Builds the search bar with the filter button and badge
  Widget _buildSearchBar(BuildContext context, Set<String> activeFilters) {
    final filterCount = activeFilters.length;

    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1.0),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(Icons.search, color: Colors.white),
            ),
            Expanded(
              child: TextField(
                // --- USE THE CONTROLLER ---
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () => _openFilterMenu(context, activeFilters),
                    tooltip: 'Filter Jobs',
                  ),
                  if (filterCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$filterCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the "Import" button
  Widget _buildImportButton(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.0),
      ),
      child: TextButton(
        onPressed: () => _openImportMenu(context),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          children: [
            const Icon(Icons.file_download, size: 24),
            const SizedBox(width: 8),
            Text(
              'Import',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of active filter chips
  Widget _buildActiveFilters(BuildContext context, Set<String> activeFilters) {
    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: activeFilters.map((mode) {
          return Container(
            padding: const EdgeInsets.only(left: 12.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4.0),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 18.0,
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    final newFilters = Set<String>.from(activeFilters)
                      ..remove(mode);
                    context
                        .read<JobBloc>()
                        .add(ApplyJobFilterEvent(newFilters));
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}