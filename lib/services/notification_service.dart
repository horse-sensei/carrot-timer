import 'package:flutter/services.dart';
import 'package:local_notifier/local_notifier.dart';

import '../domain/pomodoro_phase.dart';

/// Tells the user a phase ended. Abstract so tests can swap in a fake.
abstract class NotificationService {
  Future<void> notifyPhaseComplete({
    required PomodoroPhase finished,
    required PomodoroPhase next,
    required Duration nextDuration,
  });
}

/// Beeps through the OS and posts a banner to macOS Notification Center.
class MacNotificationService implements NotificationService {
  const MacNotificationService();

  static const appName = 'Carrot Timer';

  static Future<void> setup() => localNotifier.setup(appName: appName);

  @override
  Future<void> notifyPhaseComplete({
    required PomodoroPhase finished,
    required PomodoroPhase next,
    required Duration nextDuration,
  }) async {
    await SystemSound.play(SystemSoundType.alert);
    final minutes = nextDuration.inMinutes;
    final body = switch (finished) {
      PomodoroPhase.focus when next == PomodoroPhase.longBreak =>
        '집중 끝! 한 사이클 완료 🥕 $minutes분 푹 쉬세요',
      PomodoroPhase.focus => '집중 끝! $minutes분 쉬세요 🥕',
      PomodoroPhase.shortBreak ||
      PomodoroPhase.longBreak => '휴식 끝! 다음 $minutes분 집중 준비 🥕',
    };
    await LocalNotification(title: appName, body: body).show();
  }
}
