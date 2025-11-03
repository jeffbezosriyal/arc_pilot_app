import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:machine_dashboard/blocs/machine_settings/settings_bloc.dart';
import 'package:machine_dashboard/blocs/machine_settings/settings_event.dart';
import 'package:machine_dashboard/blocs/machine_settings/settings_state.dart';

void main() {
  group('SettingsBloc', () {
    late DateTime testStartTime;

    // We get the time from the initial state
    setUp(() {
      testStartTime = SettingsState.initial().currentTime;
    });

    test('initial state is correct', () {
      // We can't compare time, so we check the other props
      final initialState = SettingsState.initial();
      expect(initialState.machineName, 'Transmax XP6');
      expect(initialState.beeperEnabled, true);
      expect(initialState.unitIsMM, true);
    });

    // Test simple state changes
    blocTest<SettingsBloc, SettingsState>(
      'ToggleBeeperEvent updates beeperEnabled',
      build: () => SettingsBloc(),
      seed: () => SettingsState.initial().copyWith(currentTime: testStartTime),
      act: (bloc) => bloc.add(const ToggleBeeperEvent(false)),
      expect: () => [
        SettingsState.initial().copyWith(
          beeperEnabled: false,
          currentTime: testStartTime,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'ToggleUnitEvent updates unitIsMM',
      build: () => SettingsBloc(),
      seed: () => SettingsState.initial().copyWith(currentTime: testStartTime),
      act: (bloc) => bloc.add(const ToggleUnitEvent(false)),
      expect: () => [
        SettingsState.initial().copyWith(
          unitIsMM: false,
          currentTime: testStartTime,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'UpdateMachineNameEvent updates machineName',
      build: () => SettingsBloc(),
      seed: () => SettingsState.initial().copyWith(currentTime: testStartTime),
      act: (bloc) => bloc.add(const UpdateMachineNameEvent('New Name')),
      expect: () => [
        SettingsState.initial().copyWith(
          machineName: 'New Name',
          currentTime: testStartTime,
        ),
      ],
    );

    // --- This is the new test for the timer ---
    blocTest<SettingsBloc, SettingsState>(
      'InitializeSettingsEvent starts timer and emits 3 ticks',
      build: () => SettingsBloc(),
      // Seed the state with a fixed time
      seed: () => SettingsState.initial().copyWith(currentTime: testStartTime),
      // Dispatch the event that starts the timer
      act: (bloc) => bloc.add(InitializeSettingsEvent()),
      // Wait for 3.1 seconds to allow 3 ticks to occur
      wait: const Duration(seconds: 3, milliseconds: 100),
      // Expect 3 state changes, one for each tick
      expect: () => [
        SettingsState.initial().copyWith(
          currentTime: testStartTime.add(const Duration(seconds: 1)),
        ),
        SettingsState.initial().copyWith(
          currentTime: testStartTime.add(const Duration(seconds: 2)),
        ),
        SettingsState.initial().copyWith(
          currentTime: testStartTime.add(const Duration(seconds: 3)),
        ),
      ],
    );
    // --- End of new timer test ---

    // We still need to test that close() cancels the timer
    test('close() cancels the timer', () async {
      final bloc = SettingsBloc();
      // Start the timer
      bloc.add(InitializeSettingsEvent());

      // Wait 1.1 seconds (for 1 tick)
      await Future.delayed(const Duration(seconds: 1, milliseconds: 100));
      final timeAfter1Tick = bloc.state.currentTime;

      // Close the bloc
      await bloc.close();

      // Wait another 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Verify the time has NOT changed
      expect(bloc.state.currentTime, timeAfter1Tick);
    });
  });
}