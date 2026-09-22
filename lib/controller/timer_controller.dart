import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../domain/pomodoro_config.dart';
import '../domain/pomodoro_engine.dart';
import '../domain/pomodoro_phase.dart';
import '../services/notification_service.dart';

/// Drives a [PomodoroEngine] with wall-clock time and notifies listeners.
///
/// Remaining time is derived from the elapsed wall clock ([clock.now]) rather
/// than by subtracting a fixed step per tick, so the countdown does not drift
/// if the UI tick runs late. `package:clock` is used so tests can fake time.
class TimerController extends ChangeNotifier {
  TimerController({
    required this.notifications,
    PomodoroConfig config = PomodoroConfig.standard,
    this.tickInterval = const Duration(milliseconds: 250),
  }) : _engine = PomodoroEngine(config: config);

  final NotificationService notifications;
  final PomodoroEngine _engine;
  final Duration tickInterval;

  DateTime? _lastTickAt;
  Timer? _timer;

  PomodoroState get state => _engine.state;
  double get progress => _engine.progress;
  Duration get currentPhaseDuration => _engine.currentPhaseDuration;
  int get sessionsPerCycle => _engine.config.sessionsPerCycle;

  /// Completed sessions within the current cycle, 1..sessionsPerCycle.
  /// Shows a full row right after the 4th session (during the long break),
  /// then rolls back to 0 once the next focus session begins.
  int get sessionsInCycle {
    final n = state.completedSessions;
    if (n == 0) return 0;
    final mod = n % sessionsPerCycle;
    if (mod == 0 && state.phase == PomodoroPhase.longBreak) {
      return sessionsPerCycle;
    }
    return mod;
  }

  void start() {
    if (state.isRunning) return;
    _engine.start();
    _lastTickAt = clock.now();
    _timer = Timer.periodic(tickInterval, (_) => _onTick());
    notifyListeners();
  }

  void pause() {
    if (!state.isRunning) return;
    _onTick(); // fold in time since the last tick
    _engine.pause();
    _stopTicking();
    notifyListeners();
  }

  void stop() {
    _engine.stop();
    _stopTicking();
    notifyListeners();
  }

  /// Play/pause as a single toggle for the main button.
  void toggle() => state.isRunning ? pause() : start();

  void _onTick() {
    if (!state.isRunning) return;
    final now = clock.now();
    final elapsed = now.difference(_lastTickAt ?? now);
    _lastTickAt = now;
    final completed = _engine.tick(elapsed);
    if (completed != null) {
      _stopTicking();
      unawaited(
        notifications.notifyPhaseComplete(
          finished: completed.finished,
          next: completed.next,
          nextDuration: _engine.durationOf(completed.next),
        ),
      );
    }
    notifyListeners();
  }

  void _stopTicking() {
    _timer?.cancel();
    _timer = null;
    _lastTickAt = null;
  }

  @override
  void dispose() {
    _stopTicking();
    super.dispose();
  }
}
