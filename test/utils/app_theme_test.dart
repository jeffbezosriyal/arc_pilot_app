import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_dashboard/utils/app_theme.dart';

void main() {
  group('CustomSettingsTheme', () {
    test('copyWith returns new instance with updated values', () {
      const original = CustomSettingsTheme(
        iconBackgroundColor: Colors.red,
        switchActiveColor: Colors.green,
        switchInactiveThumbColor: Colors.blue,
        switchInactiveTrackColor: Colors.yellow,
        subtitleColor: Colors.purple,
      );

      final modified = original.copyWith(
        iconBackgroundColor: Colors.orange,
        switchActiveColor: Colors.cyan,
        switchInactiveThumbColor: Colors.lime,
        switchInactiveTrackColor: Colors.indigo,
        subtitleColor: Colors.teal,
      );

      expect(modified.iconBackgroundColor, Colors.orange);
      expect(modified.switchActiveColor, Colors.cyan);
      expect(modified.switchInactiveThumbColor, Colors.lime);
      expect(modified.switchInactiveTrackColor, Colors.indigo);
      expect(modified.subtitleColor, Colors.teal);
    });

    test('copyWith keeps original values when none provided', () {
      const theme = CustomSettingsTheme(
        iconBackgroundColor: Colors.red,
        switchActiveColor: Colors.green,
        switchInactiveThumbColor: Colors.blue,
        switchInactiveTrackColor: Colors.yellow,
        subtitleColor: Colors.purple,
      );

      final copied = theme.copyWith();
      expect(copied.iconBackgroundColor, theme.iconBackgroundColor);
      expect(copied.switchActiveColor, theme.switchActiveColor);
      expect(copied.switchInactiveThumbColor, theme.switchInactiveThumbColor);
      expect(copied.switchInactiveTrackColor, theme.switchInactiveTrackColor);
      expect(copied.subtitleColor, theme.subtitleColor);
    });

    test('lerp blends two themes correctly', () {
      const start = CustomSettingsTheme(
        iconBackgroundColor: Colors.red,
        switchActiveColor: Colors.green,
        switchInactiveThumbColor: Colors.blue,
        switchInactiveTrackColor: Colors.yellow,
        subtitleColor: Colors.purple,
      );

      const end = CustomSettingsTheme(
        iconBackgroundColor: Colors.black,
        switchActiveColor: Colors.white,
        switchInactiveThumbColor: Colors.orange,
        switchInactiveTrackColor: Colors.brown,
        subtitleColor: Colors.grey,
      );

      final result = start.lerp(end, 0.5);
      expect(result.iconBackgroundColor, isNotNull);
      expect(result.switchActiveColor, isNotNull);
      expect(result.switchInactiveThumbColor, isNotNull);
      expect(result.switchInactiveTrackColor, isNotNull);
      expect(result.subtitleColor, isNotNull);
    });

    test('lerp returns same instance if other is not CustomSettingsTheme', () {
      const theme = CustomSettingsTheme(iconBackgroundColor: Colors.red);
      final result = theme.lerp(null, 0.5);
      expect(result, theme);
    });
  });

  group('appThemeData', () {
    test('has correct basic configuration', () {
      expect(appThemeData.scaffoldBackgroundColor, Colors.black);
      expect(appThemeData.colorScheme.brightness, Brightness.dark);
      expect(appThemeData.appBarTheme.backgroundColor, Colors.black);
      expect(appThemeData.textTheme.bodyMedium?.color, Colors.white70);
    });

    test('contains CustomSettingsTheme extension with expected values', () {
      final custom = appThemeData.extension<CustomSettingsTheme>()!;
      expect(custom.iconBackgroundColor, const Color(0x332196F3));
      expect(custom.switchActiveColor, Colors.blue);
      expect(custom.switchInactiveThumbColor, Colors.white);
      expect(custom.switchInactiveTrackColor, const Color(0xFF333333));
      expect(custom.subtitleColor, Colors.blueGrey);
    });

    test('bottomSheetTheme modalBarrierColor is semi-transparent black', () {
      final color = appThemeData.bottomSheetTheme.modalBarrierColor;
      expect(color, isNotNull);
      expect(color!.opacity, 0.6);
    });
  });
}
