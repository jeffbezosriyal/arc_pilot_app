import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:machine_dashboard/blocs/arc_time_metric/arc_time_metric_bloc.dart';
import 'package:machine_dashboard/blocs/job_management/job_bloc.dart';
import 'package:machine_dashboard/blocs/job_management/job_event.dart';
import 'package:machine_dashboard/blocs/machine_settings/settings_bloc.dart';
import 'package:machine_dashboard/blocs/machine_settings/settings_event.dart';
import 'package:machine_dashboard/screens/arc_on_metric/arc_time_metric_page.dart';
import 'package:machine_dashboard/services/api_arc_time_service.dart';
import 'package:machine_dashboard/services/api_job_service.dart';
import 'package:machine_dashboard/services/arc_time_service.dart';
import 'package:machine_dashboard/services/job_service.dart';
import 'screens/job_management/job_management_page.dart';
import 'screens/machine_settings/machine_settings_page.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiRepositoryProvider provides service dependencies to the BLoCs.
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<JobService>(
          create: (context) => ApiJobService(),
        ),
        RepositoryProvider<ArcTimeService>(
          create: (context) => ApiArcTimeService(),
        ),
      ],
      // MultiBlocProvider provides all BLoCs to the widget tree.
      child: MultiBlocProvider(
        providers: [
          BlocProvider<JobBloc>(
            create: (context) {
              // Create the BLoC instance
              final jobBloc = JobBloc(
                jobService: context.read<JobService>(),
              );
              // Add the initial event to fetch data
              jobBloc.add(FetchJobsEvent());
              return jobBloc;
            },
          ),
          BlocProvider<SettingsBloc>(
            create: (context) {
              // Create the BLoC instance
              final settingsBloc = SettingsBloc();
              // Add the initial event to start the timer
              settingsBloc.add(InitializeSettingsEvent());
              return settingsBloc;
            },
          ),
          BlocProvider<ArcTimeMetricBloc>(
            create: (context) {
              final bloc = ArcTimeMetricBloc(
                arcTimeService: context.read<ArcTimeService>(),
              );
              // Add the initial event to fetch data
              bloc.add(const FetchArcTimeMetric());
              return bloc;
            },
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appThemeData,
          initialRoute: '/',
          routes: {
            '/': (context) => const MachineSettingsPage(),
            '/job-management': (context) => const JobManagementPage(),
            '/arc-time-metric': (context) => const ArcTimeMetricPage(),
          },
        ),
      ),
    );
  }
}