import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/blocs/machine_settings/settings_bloc.dart';
import 'package:machine_dashboard/blocs/machine_settings/settings_event.dart';
import 'package:machine_dashboard/blocs/machine_settings/settings_state.dart';

void main() {
  group('SettingsBloc', () {
    test('initial state is correct', () {
      expect(SettingsBloc().state, SettingsState.initial());
    });

    blocTest<SettingsBloc, SettingsState>(
      'ToggleBeeperEvent updates beeperEnabled',
      build: () => SettingsBloc(),
      act: (bloc) => bloc.add(const ToggleBeeperEvent(false)),
      expect: () => <SettingsState>[
        SettingsState.initial().copyWith(beeperEnabled: false),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'ToggleUnitEvent updates unitIsMM',
      build: () => SettingsBloc(),
      act: (bloc) => bloc.add(const ToggleUnitEvent(false)),
      expect: () => <SettingsState>[
        SettingsState.initial().copyWith(unitIsMM: false),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateMachineNameEvent updates machineName',
      build: () => SettingsBloc(),
      act: (bloc) => bloc.add(const UpdateMachineNameEvent('New Name')),
      expect: () => <SettingsState>[
        SettingsState.initial().copyWith(machineName: 'New Name'),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'TickEvent updates currentTime',
      build: () => SettingsBloc(),
      act: (bloc) {
        // We don't need to test InitializeSettingsEvent as it just starts
        // a timer. We can test the TickEvent directly.
        final newTime = DateTime(2025, 1, 1);
        bloc.add(TickEvent(newTime));
      },
      expect: () => <SettingsState>[
        SettingsState.initial().copyWith(currentTime: DateTime(2025, 1, 1)),
      ],
    );
  });
}

