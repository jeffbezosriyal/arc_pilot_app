import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'bottom_sheets.dart';

/// A reusable tile for displaying a single setting item.
/// It consists of an icon, a title, an optional subtitle, and a trailing widget (e.g., a switch or an arrow).
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final settingsTheme = Theme.of(context).extension<CustomSettingsTheme>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: settingsTheme?.iconBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, color: Colors.white, size: 24.0),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: settingsTheme?.subtitleColor,
                      fontSize: 14.0,
                    ),
                  ),
                ]
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A widget that displays the robot connection status.
class RobotConnectionWidget extends StatelessWidget {
  const RobotConnectionWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Column(
        children: [
          SettingsTile(
            icon: Icons.wifi,
            title: 'Status',
            subtitle: 'Robot is connected',
            trailing: Text('Connected', style: TextStyle(color: Colors.lightGreen, fontSize: 16.0, fontWeight: FontWeight.w500)),
          ),
          SettingsTile(
            icon: Icons.refresh,
            title: 'Reset',
            trailing: Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays device and firmware information.
class InformationWidget extends StatelessWidget {
  const InformationWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Column(
        children: [
          SettingsTile(icon: Icons.precision_manufacturing_outlined, title: 'Device Model', subtitle: 'Model X100'),
          SettingsTile(icon: Icons.qr_code_scanner, title: 'Serial Number', subtitle: 'SN: 1234567890'),
          SettingsTile(icon: Icons.code, title: 'Firmware', subtitle: 'v1.0.0'),
        ],
      ),
    );
  }
}

/// A widget for the factory reset section, including the reset button.
class FactoryResetWidget extends StatelessWidget {
  const FactoryResetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsTheme = Theme.of(context).extension<CustomSettingsTheme>();
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: settingsTheme?.iconBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24.0),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Factory Reset', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4.0),
                Text('Warning: This will erase all settings and data.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: settingsTheme?.subtitleColor, fontSize: 14.0)),
                const SizedBox(height: 2.0),
                Text('Reset to factory settings', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: settingsTheme?.subtitleColor, fontSize: 14.0)),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          ElevatedButton(
            onPressed: () {
              // Shows the confirmation bottom sheet defined in another file
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => const ResetConfirmationSheet(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A3A4D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// A widget for the program update section.
class ProgramUpdateWidget extends StatelessWidget {
  const ProgramUpdateWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final settingsTheme = Theme.of(context).extension<CustomSettingsTheme>();
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.usb,
            title: 'USB Detection',
            subtitle: 'No USB detected',
            trailing: Text('Not Detected', style: TextStyle(color: settingsTheme?.subtitleColor, fontSize: 16.0, fontWeight: FontWeight.w500)),
          ),
          SettingsTile(
            icon: Icons.download,
            title: 'Software Update',
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Software update not implemented')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A3A4D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              child: const Text('Install'),
            ),
          ),
        ],
      ),
    );
  }
}
