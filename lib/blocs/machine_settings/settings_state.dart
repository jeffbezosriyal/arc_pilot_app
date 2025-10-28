import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String machineName;
  final bool beeperEnabled;
  final bool unitIsMM;
  final DateTime currentTime;

  const SettingsState({
    required this.machineName,
    required this.beeperEnabled,
    required this.unitIsMM,
    required this.currentTime,
  });

  factory SettingsState.initial() {
    return SettingsState(
      machineName: 'Transmax XP6', // Default initial name
      beeperEnabled: true,
      unitIsMM: true,
      currentTime: DateTime.now(),
    );
  }

  SettingsState copyWith({
    String? machineName,
    bool? beeperEnabled,
    bool? unitIsMM,
    DateTime? currentTime,
  }) {
    return SettingsState(
      machineName: machineName ?? this.machineName,
      beeperEnabled: beeperEnabled ?? this.beeperEnabled,
      unitIsMM: unitIsMM ?? this.unitIsMM,
      currentTime: currentTime ?? this.currentTime,
    );
  }

  @override
  List<Object> get props => [
    machineName,
    beeperEnabled,
    unitIsMM,
    // currentTime, // <-- EXCLUDED
  ];
}
