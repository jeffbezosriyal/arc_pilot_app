import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

/// Event to initialize the settings and start the clock timer.
class InitializeSettingsEvent extends SettingsEvent {}

/// Event to update the real-time clock.
class TickEvent extends SettingsEvent {
  final DateTime currentTime;

  const TickEvent(this.currentTime);

  @override
  List<Object> get props => [currentTime];
}

/// Event to toggle the beeper on or off.
class ToggleBeeperEvent extends SettingsEvent {
  final bool isEnabled;

  const ToggleBeeperEvent(this.isEnabled);

  @override
  List<Object> get props => [isEnabled];
}

/// Event to toggle the measurement unit (mm/inch).
class ToggleUnitEvent extends SettingsEvent {
  final bool isMM;

  const ToggleUnitEvent(this.isMM);

  @override
  List<Object> get props => [isMM];
}

/// Event to update the machine's name.
class UpdateMachineNameEvent extends SettingsEvent {
  final String newName;

  const UpdateMachineNameEvent(this.newName);

  @override
  List<Object> get props => [newName];
}
