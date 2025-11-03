import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/blocs/machine_settings/settings_state.dart';

void main() {
  group('SettingsState', () {
    // 1. Test the initial factory constructor
    test('initial() creates correct default state', () {
      final initialState = SettingsState.initial();

      expect(initialState.machineName, 'Transmax XP6');
      expect(initialState.beeperEnabled, true);
      expect(initialState.unitIsMM, true);
      // Check that currentTime is recent but don't compare exactly
      expect(
        DateTime.now().difference(initialState.currentTime),
        lessThan(const Duration(seconds: 2)),
      );
    });

    // 2. Test the copyWith method
    test('copyWith creates a new state with updated values', () {
      final initialState = SettingsState.initial();
      final newTime = DateTime(2023, 1, 1);

      final updatedState = initialState.copyWith(
        machineName: 'New Name',
        beeperEnabled: false,
        unitIsMM: false,
        currentTime: newTime,
      );

      // Verify updated values
      expect(updatedState.machineName, 'New Name');
      expect(updatedState.beeperEnabled, false);
      expect(updatedState.unitIsMM, false);
      expect(updatedState.currentTime, newTime);

      // Verify original state is unchanged
      expect(initialState.machineName, 'Transmax XP6');
      expect(initialState.beeperEnabled, true);
    });

    test('copyWith uses current values if no new ones are provided', () {
      final initialState = SettingsState.initial();
      final updatedState = initialState.copyWith(); // No arguments

      // Test equality using Equatable
      expect(updatedState, initialState);

      // Also check individual props for good measure
      expect(updatedState.machineName, initialState.machineName);
      expect(updatedState.beeperEnabled, initialState.beeperEnabled);
      expect(updatedState.unitIsMM, initialState.unitIsMM);
      expect(updatedState.currentTime, initialState.currentTime);
    });

    // 3. Test Equatable props
    // --- THIS TEST IS UPDATED ---
    test('Equatable props include currentTime', () {
      final time1 = DateTime(2023, 1, 1, 10, 0, 0);
      final time2 = DateTime(2023, 1, 1, 10, 0, 1); // Different time
      final time1Again = DateTime(2023, 1, 1, 10, 0, 0); // Same as time1

      final state1 = SettingsState(
        machineName: 'Test',
        beeperEnabled: true,
        unitIsMM: true,
        currentTime: time1,
      );

      final state2 = SettingsState(
        machineName: 'Test',
        beeperEnabled: true,
        unitIsMM: true,
        currentTime: time2, // Different time
      );

      final state1Again = SettingsState(
        machineName: 'Test',
        beeperEnabled: true,
        unitIsMM: true,
        currentTime: time1Again, // Same time as state1
      );

      // Assert that states with different times are NOT equal
      expect(state1, isNot(state2));

      // Assert that states with the same props (including time) ARE equal
      expect(state1, state1Again);

      // Verify the props list content includes currentTime
      expect(state1.props, ['Test', true, true, time1]);
      expect(state2.props, ['Test', true, true, time2]);
    });
    // --- END OF UPDATED TEST ---

    test('states are not equal if another prop changes', () {
      final time = DateTime(2023, 1, 1);
      final state1 = SettingsState(
        machineName: 'Test1', // Different name
        beeperEnabled: true,
        unitIsMM: true,
        currentTime: time,
      );

      final state2 = SettingsState(
        machineName: 'Test2', // Different name
        beeperEnabled: true,
        unitIsMM: true,
        currentTime: time,
      );

      expect(state1, isNot(state2));
    });
  });
}