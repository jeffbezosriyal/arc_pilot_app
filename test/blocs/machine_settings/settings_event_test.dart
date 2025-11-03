import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/blocs/machine_settings/settings_event.dart';

void main() {
  group('SettingsEvent', () {

    group('InitializeSettingsEvent', () {
      test('supports value equality', () {
        expect(InitializeSettingsEvent(), equals(InitializeSettingsEvent()));
      });
      test('props are empty', () {
        expect(InitializeSettingsEvent().props, isEmpty);
      });
    });

    group('TickEvent', () {
      final time1 = DateTime(2023, 1, 1);
      final time2 = DateTime(2023, 1, 2);

      test('supports value equality', () {
        expect(TickEvent(time1), equals(TickEvent(time1)));
        expect(TickEvent(time1), isNot(TickEvent(time2)));
      });
      test('props are correct', () {
        expect(TickEvent(time1).props, [time1]);
      });
    });

    group('ToggleBeeperEvent', () {
      test('supports value equality', () {
        expect(const ToggleBeeperEvent(true), equals(const ToggleBeeperEvent(true)));
        expect(const ToggleBeeperEvent(true), isNot(const ToggleBeeperEvent(false)));
      });
      test('props are correct', () {
        expect(const ToggleBeeperEvent(true).props, [true]);
      });
    });

    group('ToggleUnitEvent', () {
      test('supports value equality', () {
        expect(const ToggleUnitEvent(true), equals(const ToggleUnitEvent(true)));
        expect(const ToggleUnitEvent(true), isNot(const ToggleUnitEvent(false)));
      });
      test('props are correct', () {
        expect(const ToggleUnitEvent(true).props, [true]);
      });
    });

    group('UpdateMachineNameEvent', () {
      test('supports value equality', () {
        expect(
          const UpdateMachineNameEvent('Name1'),
          equals(const UpdateMachineNameEvent('Name1')),
        );
        expect(
          const UpdateMachineNameEvent('Name1'),
          isNot(const UpdateMachineNameEvent('Name2')),
        );
      });
      test('props are correct', () {
        expect(const UpdateMachineNameEvent('Name1').props, ['Name1']);
      });
    });
  });
}