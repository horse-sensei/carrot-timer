import 'package:flutter/material.dart';

import '../domain/pomodoro_phase.dart';

/// Carrot palette. Orange for focus, leaf green for breaks.
abstract final class CarrotColors {
  static const carrot = Color(0xFFF28C28);
  static const leaf = Color(0xFF5DB55A);
  static const soil = Color(0xFF1E1B18);
  static const soilLight = Color(0xFF2C2824);
  static const cream = Color(0xFFF5EBDD);

  static Color forPhase(PomodoroPhase phase) => phase.isBreak ? leaf : carrot;
}

ThemeData buildCarrotTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CarrotColors.carrot,
      brightness: Brightness.dark,
      surface: CarrotColors.soil,
      primary: CarrotColors.carrot,
      secondary: CarrotColors.leaf,
    ),
    scaffoldBackgroundColor: CarrotColors.soil,
    useMaterial3: true,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: CarrotColors.cream),
    iconTheme: const IconThemeData(color: CarrotColors.cream, size: 20),
  );
}
