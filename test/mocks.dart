import 'package:http/http.dart' as http;
import 'package:machine_dashboard/services/api_arc_time_service.dart';
import 'package:machine_dashboard/services/api_job_service.dart';
import 'package:machine_dashboard/services/arc_time_service.dart';
import 'package:machine_dashboard/services/job_service.dart';
import 'package:mockito/annotations.dart';

// This annotation tells build_runner to generate mocks for these classes
@GenerateMocks([
  JobService,
  ArcTimeService,
  ApiJobService,
  ApiArcTimeService,
  http.Client,
])
void main() {} // This file needs a main function to be valid for build_runner

// After creating this file, run the following command in your terminal
// to generate the 'test/mocks.mocks.dart' file:
//
// flutter pub run build_runner build --delete-conflicting-outputs
//