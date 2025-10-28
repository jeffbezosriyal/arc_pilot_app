import 'package:machine_dashboard/blocs/arc_time_metric/arc_time_metric_bloc.dart'; // Import enum
import 'package:machine_dashboard/models/arc_time_metric.dart';

/// Abstract interface for the arc time metric data source.
abstract class ArcTimeService {
  /// Fetches arc time data based on a reference date and a time range.
  Future<ArcTimeMetric> fetchArcTime({
    required DateTime date,
    required ArcTimeRange range,
  });
}
