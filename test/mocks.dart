import 'package:http/http.dart' as http;
import 'package:machine_dashboard/services/arc_time_service.dart';
import 'package:machine_dashboard/services/job_service.dart';
import 'package:mocktail/mocktail.dart';

// Mocks for Services (to be used in BLoC tests)
class MockJobService extends Mock implements JobService {}

class MockArcTimeService extends Mock implements ArcTimeService {}

// Mocks for HTTP (to be used in Service tests)
class MockHttpClient extends Mock implements http.Client {}

// A helper class to mock http.Response
class MockResponse extends Mock implements http.Response {}

// A helper class to match any Uri
class AnyUri extends Fake implements Uri {}

