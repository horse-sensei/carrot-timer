import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'controller/timer_controller.dart';
import 'domain/pomodoro_config.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/window_service.dart';

const _windowSize = Size(200, 200);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await MacNotificationService.setup();

  const settings = SettingsService();
  const window = WindowService();
  final alwaysOnTop = await settings.loadAlwaysOnTop();

  const options = WindowOptions(
    size: _windowSize,
    minimumSize: _windowSize,
    maximumSize: _windowSize,
    center: true,
    title: MacNotificationService.appName,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    skipTaskbar: false,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setResizable(false);
    await window.setPinned(alwaysOnTop);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    CarrotTimerApp(
      controller: TimerController(
        notifications: const MacNotificationService(),
        config: PomodoroConfig.fromEnvironment,
      ),
      settings: settings,
      window: window,
      initialAlwaysOnTop: alwaysOnTop,
    ),
  );
}
