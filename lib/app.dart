import 'package:flutter/material.dart';

import 'controller/timer_controller.dart';
import 'services/settings_service.dart';
import 'services/window_service.dart';
import 'ui/theme.dart';
import 'ui/timer_screen.dart';

class CarrotTimerApp extends StatelessWidget {
  const CarrotTimerApp({
    super.key,
    required this.controller,
    required this.settings,
    required this.window,
    required this.initialAlwaysOnTop,
  });

  final TimerController controller;
  final SettingsService settings;
  final WindowService window;
  final bool initialAlwaysOnTop;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrot Timer',
      debugShowCheckedModeBanner: false,
      theme: buildCarrotTheme(),
      home: TimerScreen(
        controller: controller,
        settings: settings,
        window: window,
        initialAlwaysOnTop: initialAlwaysOnTop,
      ),
    );
  }
}
