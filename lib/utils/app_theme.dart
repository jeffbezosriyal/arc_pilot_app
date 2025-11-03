import 'package:flutter/material.dart';

// 1. CUSTOM THEME EXTENSION
class CustomSettingsTheme extends ThemeExtension<CustomSettingsTheme> {
  final Color? iconBackgroundColor;
  final Color? switchActiveColor;
  final Color? switchInactiveThumbColor;
  final Color? switchInactiveTrackColor;
  final Color? subtitleColor;

  const CustomSettingsTheme({
    this.iconBackgroundColor,
    this.switchActiveColor,
    this.switchInactiveThumbColor,
    this.switchInactiveTrackColor,
    this.subtitleColor,
  });

  @override
  CustomSettingsTheme copyWith({
    Color? iconBackgroundColor,
    Color? switchActiveColor,
    Color? switchInactiveThumbColor,
    Color? switchInactiveTrackColor,
    Color? subtitleColor,
  }) {
    return CustomSettingsTheme(
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      switchActiveColor: switchActiveColor ?? this.switchActiveColor,
      switchInactiveThumbColor:
      switchInactiveThumbColor ?? this.switchInactiveThumbColor,
      switchInactiveTrackColor:
      switchInactiveTrackColor ?? this.switchInactiveTrackColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
    );
  }

  @override
  CustomSettingsTheme lerp(
      ThemeExtension<CustomSettingsTheme>? other, double t) {
    if (other is! CustomSettingsTheme) return this;

    return CustomSettingsTheme(
      iconBackgroundColor:
      Color.lerp(iconBackgroundColor, other.iconBackgroundColor, t),
      switchActiveColor:
      Color.lerp(switchActiveColor, other.switchActiveColor, t),
      switchInactiveThumbColor: Color.lerp(
          switchInactiveThumbColor, other.switchInactiveThumbColor, t),
      switchInactiveTrackColor: Color.lerp(
          switchInactiveTrackColor, other.switchInactiveTrackColor, t),
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t),
    );
  }
}

// 2. MAIN APP THEME DATA
final ThemeData appThemeData = ThemeData(
  fontFamily: 'Kallisto',
  scaffoldBackgroundColor: Colors.black,
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF1E1E1E),
    onSecondaryContainer: Color(0xFF252525),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 16.0),
    headlineMedium: TextStyle(
        color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: Colors.white70, fontSize: 14.0),
    titleLarge:
    TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
    labelLarge:
    TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    modalBarrierColor: Colors.black.withOpacity(0.6),
  ),
  extensions: [
    const CustomSettingsTheme(
      iconBackgroundColor: Color(0x332196F3),
      switchActiveColor: Colors.blue,
      switchInactiveThumbColor: Colors.white,
      switchInactiveTrackColor: Color(0xFF333333),
      subtitleColor: Colors.blueGrey,
    ),
  ],
);
