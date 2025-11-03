import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:machine_dashboard/blocs/arc_time_metric/arc_time_metric_bloc.dart';
import 'package:machine_dashboard/models/arc_time_metric.dart';
import 'package:machine_dashboard/screens/arc_on_metric/widgets/time_range_selector.dart';
import 'package:machine_dashboard/screens/arc_on_metric/widgets/weekly_bar_chart.dart';
import 'package:machine_dashboard/widgets/my_drawer.dart';

class ArcTimeMetricPage extends StatelessWidget {
  const ArcTimeMetricPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Arc Time Metric',
          // Use style from theme
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      drawer: const MyDrawer(),
      body: BlocConsumer<ArcTimeMetricBloc, ArcTimeMetricState>(
        // Use BlocConsumer to show snackbars for errors
        listener: (context, state) {
          if (state.status == ArcTimeStatus.failure && state.errorMessage != null) {
            // Consider using your snackbar_utils here
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        builder: (context, state) {
          // Show loading indicator centrally, even during background refresh
          if (state.status == ArcTimeStatus.loading && state.metric.totalArcTime == Duration.zero) {
            // Only show full screen loading on initial load
            return const Center(child: CircularProgressIndicator());
          }
          // Always build the content, potentially showing stale data during refresh
          // The BlocConsumer handles showing errors via SnackBar
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ArcTimeMetricBloc>().add(FetchArcTimeMetric(date: state.referenceDate));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll works for RefreshIndicator
              child: _buildContent(context, state),
            ),
          );
          // Note: Error state is handled by the listener showing a SnackBar.
          // You could add a specific UI here if needed, but SnackBar is often sufficient.
        },
      ),
    );
  }

  /// Builds the main content widget based on the current state.
  Widget _buildContent(BuildContext context, ArcTimeMetricState state) {
    final metric = state.metric;
    final selectedRange = state.selectedRange;
    final referenceDate = state.referenceDate; // Use reference date from state

    // --- 1. Calculate and Format Dynamic Total Time ---
    double totalValueForPeriod = 0.0;
    List<ArcTimeDataPoint> dataPointsForChart;

    switch (selectedRange) {
      case ArcTimeRange.week:
        dataPointsForChart = metric.weeklyData;
        break;
      case ArcTimeRange.month:
        dataPointsForChart = metric.monthlyData;
        break;
      case ArcTimeRange.year:
        dataPointsForChart = metric.yearlyData;
        break;
      case ArcTimeRange.custom:
        dataPointsForChart = metric.weeklyData; // Fallback
        break;
    }
    // Calculate sum from the *correct* data list
    totalValueForPeriod = dataPointsForChart.fold(0.0, (sum, data) => sum + data.value);

    // Format total time (e.g., "36h 30m" or "1756h")
    final int totalHours = totalValueForPeriod.floor();
    final int totalMinutes = ((totalValueForPeriod - totalHours) * 60).round();

    final String formattedArcTime = totalMinutes > 0
        ? '${totalHours}h ${totalMinutes}m'
        : '${totalHours}h';
    // --- End Dynamic Total Time ---


    // Format last updated date (from the metric data itself)
    final String formattedLastUpdate =
    DateFormat('dd/MM/yyyy - hh:mma').format(metric.lastUpdated.toLocal());

    // --- 2. FORMAT DYNAMIC CHART HEADER DATA ---
    String dynamicDateRangeLabel;
    String averageLabel;
    String averageValue;
    // Removed dataPointsForChart from here, defined above

    // Calculate average based on the dynamic total and number of points
    final int numberOfDataPoints = dataPointsForChart.isNotEmpty ? dataPointsForChart.length : 1;
    double average = totalValueForPeriod / numberOfDataPoints;


    switch (selectedRange) {
      case ArcTimeRange.week:
      // Format: "week 09/02 - 15/02/2025" using referenceDate
        final startOfWeek = referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        dynamicDateRangeLabel =
        'week ${DateFormat('dd/MM').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)}';
        averageLabel = 'This week Avg';
        break;
      case ArcTimeRange.month:
      // Format: "March 2024" using referenceDate
        dynamicDateRangeLabel = DateFormat('MMMM yyyy').format(referenceDate);
        averageLabel = 'Daily Avg';
        break;
      case ArcTimeRange.year:
      // Format: "2024" using referenceDate
        dynamicDateRangeLabel = DateFormat('yyyy').format(referenceDate);
        averageLabel = 'Monthly Avg';
        break;
      case ArcTimeRange.custom:
        dynamicDateRangeLabel = 'Custom Date Range'; // Needs specific logic if implemented
        averageLabel = 'Custom Avg';
        break;
    }

    // Format average value
    final int avgHours = average.floor();
    final int avgMinutes = ((average - avgHours) * 60).round();
    averageValue =
    avgMinutes > 0 ? '${avgHours}h ${avgMinutes}m' : '${avgHours}h';

    // --- 3. BUILD THE CHART WIDGET (With Conditional Scrolling) ---
    Widget chartDisplayWidget;
    if (dataPointsForChart.isEmpty) {
      chartDisplayWidget = const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text('No data available for this period.',
              style: TextStyle(color: Colors.white70)),
        ),
      );
    } else {
      // Create the core chart widget instance
      final barChartWidget = WeeklyBarChart(
        dataPoints: dataPointsForChart,
        timeRange: selectedRange,
      );

      // --- FIX: Group Month and Year to be scrollable ---
      if (selectedRange == ArcTimeRange.month ||
          selectedRange == ArcTimeRange.year) {
        // --- MONTH/YEAR VIEW: SCROLLABLE ---

        // Get bar width from chart widget's implementation
        double barWidth = (selectedRange == ArcTimeRange.month) ? 18 : 20;
        // Estimate total space needed per bar group
        double groupSpacing = barWidth + 12; // Bar width + padding
        double reservedPadding =
        60; // Extra space for Y-axis labels + end padding
        double calculatedWidth =
            (dataPointsForChart.length * groupSpacing) + reservedPadding;

        // Don't let it be narrower than the screen
        double screenWidth =
            MediaQuery.of(context).size.width - 48; // Account for page padding (24*2)

        chartDisplayWidget = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            // Set the width needed to display all bars
            width:
            calculatedWidth < screenWidth ? screenWidth : calculatedWidth,
            // Height is constrained by the parent Container below
            child: barChartWidget,
          ),
        );
      } else {
        // --- WEEK/CUSTOM VIEW: ASPECT RATIO ---
        chartDisplayWidget = AspectRatio(
          aspectRatio: 1.5, // Maintain aspect ratio
          child: barChartWidget,
        );
      }
      // --- END OF FIX ---
    }
    // --- END CHART WIDGET BUILDING ---

    // Padding is now inside SingleChildScrollView
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 4. TOP HEADER (Total Time) ---
          Text(
            'Total Arc Time Recorded',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white70,
              fontSize: 18,
            ),
          ), // <-- FIX: Added missing parenthesis and comma
          const SizedBox(height: 5), // <-- Restored this line

          // --- Restored Missing UI Elements ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Formatted Time (Now Dynamic)
              Text(
                formattedArcTime, // Use the dynamically calculated total
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Welder Icon
              Image.asset(
                'assets/weld_icon.png', // Assuming this is the welder icon path
                width: 70,
                height: 65,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.show_chart, // Fallback icon
                    color: Colors.blue,
                    size: 60,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 1),
          // Last Updated
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey[400], size: 16),
              const SizedBox(width: 8),
              Text(
                'Last Updated - $formattedLastUpdate',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // --- 5. TIME RANGE SELECTOR (TABS) ---
          Center(
            child: TimeRangeSelector(
              selectedRange: selectedRange,
              onRangeSelected: (newRange) {
                // Dispatch event to update range (BLoC handles refetch)
                context
                    .read<ArcTimeMetricBloc>()
                    .add(UpdateArcTimeRange(newRange));
              },
            ),
          ),
          const SizedBox(height: 15),

          // --- 6. DYNAMIC HEADER (Date Range + Average) ---
          Column(
            children: [
              // Date range with arrows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- PREVIOUS BUTTON ---
                  IconButton(
                    icon:
                    const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      // Dispatch navigation event
                      context.read<ArcTimeMetricBloc>().add(NavigatePreviousPeriod());
                    },
                  ),
                  // --- END PREVIOUS ---
                  // Dynamic Date Label
                  Text(
                    dynamicDateRangeLabel, // Use label calculated based on range/date
                    style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold // Make date bold
                    ),
                  ),
                  // --- NEXT BUTTON ---
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white),
                    onPressed: () {
                      // Dispatch navigation event
                      context.read<ArcTimeMetricBloc>().add(NavigateNextPeriod());
                    },
                  ),
                  // --- END NEXT ---
                ],
              ),
              const SizedBox(height: 5),
              // Average label
              Text(
                averageLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              // Average value
              Text(
                averageValue,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // --- End of Restored UI ---

          const SizedBox(height: 16),

          // --- 7. CHART TITLE (Removed as it's less necessary with dynamic header) ---
          // Text(
          //   chartTitle, // Title like 'Weekly Usage'
          //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
          //     fontSize: 18,
          //   ),
          // ),
          // const SizedBox(height: 16), // Spacing after title

          // --- 8. CHART WIDGET CONTAINER ---
          Container(
            height: 240, // Fixed height for the chart area
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            child: Stack( // Use Stack to overlay loading indicator
              children: [
                // AnimatedSwitcher handles the morph
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    final scaleTween = Tween<double>(begin: 0.95, end: 1.0);
                    final scaleAnimation = scaleTween.animate(animation);

                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<String>('$selectedRange-$dynamicDateRangeLabel'),
                    child: chartDisplayWidget,
                  ),
                ),
                // Loading overlay
                if (state.status == ArcTimeStatus.loading && state.metric.totalArcTime != Duration.zero)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // --- 9. DOWNLOAD BUTTON ---
          Center(
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download report feature coming soon!')),
                );
              },
              style: OutlinedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                side: const BorderSide(color: Colors.white, width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0)),
              ),
              child: const Text(
                'Download Report',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

// Removed _buildErrorState as errors are handled via SnackBar in BlocConsumer listener
}