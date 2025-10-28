import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  Timer? _timer;

  SettingsBloc() : super(SettingsState.initial()) {
    on<InitializeSettingsEvent>(_onInitializeSettings);
    on<TickEvent>(_onTick);
    on<ToggleBeeperEvent>(_onToggleBeeper);
    on<ToggleUnitEvent>(_onToggleUnit);
    on<UpdateMachineNameEvent>(_onUpdateMachineName);
  }

  void _onInitializeSettings(
      InitializeSettingsEvent event, Emitter<SettingsState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TickEvent(state.currentTime.add(const Duration(seconds: 1))));
    });
  }

  void _onTick(TickEvent event, Emitter<SettingsState> emit) {
    emit(state.copyWith(currentTime: event.currentTime));
  }

  void _onToggleBeeper(ToggleBeeperEvent event, Emitter<SettingsState> emit) {
    emit(state.copyWith(beeperEnabled: event.isEnabled));
  }

  void _onToggleUnit(ToggleUnitEvent event, Emitter<SettingsState> emit) {
    emit(state.copyWith(unitIsMM: event.isMM));
  }

  void _onUpdateMachineName(
      UpdateMachineNameEvent event, Emitter<SettingsState> emit) {
    emit(state.copyWith(machineName: event.newName));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
