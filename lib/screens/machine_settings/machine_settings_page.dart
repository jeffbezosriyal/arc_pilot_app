import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/machine_settings/settings_bloc.dart';
import '../../blocs/machine_settings/settings_event.dart';
import '../../blocs/machine_settings/settings_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/my_drawer.dart';
import 'widgets/bottom_sheets.dart';
import 'widgets/settings_widgets.dart';

/// The main screen for displaying and managing machine-specific settings.
/// This widget is now a StatelessWidget and gets its state from the SettingsBloc.
class MachineSettingsPage extends StatelessWidget {
  const MachineSettingsPage({super.key});

  /// Updates the machine name by dispatching an event to the BLoC.
  void _updateMachineName(BuildContext context, String newName) {
    context.read<SettingsBloc>().add(UpdateMachineNameEvent(newName));
  }

  @override
  Widget build(BuildContext context) {
    const String seriesId = '489131GBBW8';
    final settingsTheme = Theme.of(context).extension<CustomSettingsTheme>()!;

    // BlocBuilder rebuilds the UI in response to state changes from the SettingsBloc.
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final String fullFormattedDateTime =
        DateFormat('hh:mm:ss a, MMM dd, yyyy').format(state.currentTime);

        return Scaffold(
          appBar: AppBar(
            title: Text( // 'const' must be removed
              'Machine Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          drawer: const MyDrawer(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Top Card with machine information
                Container(
                  color: const Color(0xFF141414),
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 12.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40.0,
                        backgroundColor: const Color(0xFF007BFF),
                        backgroundImage:
                        const AssetImage('assets/machine_icon.png'),
                        onBackgroundImageError: (exception, stackTrace) {
                          debugPrint(
                              "Error loading machine_icon.png: $exception");
                        },
                      ),
                      const SizedBox(height: 8.0),
                      Text(state.machineName,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 15.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16.0, color: Colors.white38),
                                const SizedBox(width: 8.0),
                                Text(
                                  fullFormattedDateTime,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: Colors.white38),
                                ),
                              ],
                            ),
                            const Row(
                              children: [
                                Icon(Icons.check_circle,
                                    size: 18.0, color: Colors.lightGreen),
                                SizedBox(width: 8.0),
                                Text('Connected',
                                    style:
                                    TextStyle(color: Colors.lightGreen)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      // Series ID with copy functionality
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Series ID: $seriesId',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8.0),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  const ClipboardData(text: seriesId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                    Text('Series ID copied to clipboard')),
                              );
                            },
                            child: const Icon(Icons.copy,
                                size: 18.0, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      // Rename button
                      SizedBox(
                        width: 150.0,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (_) => RenameMachineSheet(
                                currentName: state.machineName,
                                onSave: (newName) =>
                                    _updateMachineName(context, newName),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000000),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            padding:
                            const EdgeInsets.symmetric(vertical: 12.0),
                            elevation: 0.0,
                          ),
                          label: const Text('Rename'),
                          icon: const Icon(Icons.edit, size: 18.0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // "Settings" Section
                const _SectionHeader('Settings'),
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: Icons.volume_up,
                        title: 'Beeper',
                        subtitle: state.beeperEnabled
                            ? 'Beeper is on'
                            : 'Beeper is off',
                        trailing: Switch(
                          value: state.beeperEnabled,
                          onChanged: (bool value) => context
                              .read<SettingsBloc>()
                              .add(ToggleBeeperEvent(value)),
                          activeThumbColor: settingsTheme.switchActiveColor,
                          inactiveThumbColor:
                          settingsTheme.switchInactiveThumbColor,
                          inactiveTrackColor:
                          settingsTheme.switchInactiveTrackColor,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.square_foot,
                        title: 'Unit',
                        subtitle:
                        state.unitIsMM ? 'Unit is mm' : 'Unit is inch',
                        trailing: Switch(
                          value: state.unitIsMM,
                          onChanged: (bool value) => context
                              .read<SettingsBloc>()
                              .add(ToggleUnitEvent(value)),
                          activeThumbColor: settingsTheme.switchActiveColor,
                          inactiveThumbColor:
                          settingsTheme.switchInactiveThumbColor,
                          inactiveTrackColor:
                          settingsTheme.switchInactiveTrackColor,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.access_time,
                        title: 'Clock',
                        subtitle:
                        'Time is ${DateFormat('hh:mm:ss a').format(state.currentTime)}',
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16.0, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // All other sections
                const _SectionHeader('Robot Connection'),
                const RobotConnectionWidget(),
                const SizedBox(height: 24.0),

                const _SectionHeader('Information'),
                const InformationWidget(),
                const SizedBox(height: 24.0),

                const _SectionHeader('Factory Reset'),
                const FactoryResetWidget(),
                const SizedBox(height: 24.0),

                const _SectionHeader('Program Update'),
                const ProgramUpdateWidget(),
                const SizedBox(height: 24.0),

                // "Delete the machine" Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                        const RemoveMachineConfirmationSheet(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE04000),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0)),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Delete the machine'),
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A private helper widget to create consistent section headers.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
