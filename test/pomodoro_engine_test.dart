import 'package:carrot_timer/domain/pomodoro_config.dart';
import 'package:carrot_timer/domain/pomodoro_engine.dart';
import 'package:carrot_timer/domain/pomodoro_phase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = PomodoroConfig(
    focus: Duration(seconds: 25),
    shortBreak: Duration(seconds: 5),
    longBreak: Duration(seconds: 20),
  );

  PomodoroEngine engine() => PomodoroEngine(config: config);

  /// Runs the current phase to completion in one tick.
  PhaseCompleted? finishPhase(PomodoroEngine e) {
    e.start();
    return e.tick(e.currentPhaseDuration);
  }

  group('initial state', () {
    test('starts idle on focus with the full focus duration', () {
      final e = engine();
      expect(e.state.phase, PomodoroPhase.focus);
      expect(e.state.status, PomodoroStatus.idle);
      expect(e.state.remaining, config.focus);
      expect(e.state.completedSessions, 0);
      expect(e.progress, 0);
    });
  });

  group('transitions', () {
    test('start → running, pause → paused, start again → running', () {
      final e = engine();
      e.start();
      expect(e.state.status, PomodoroStatus.running);
      e.pause();
      expect(e.state.status, PomodoroStatus.paused);
      e.start();
      expect(e.state.status, PomodoroStatus.running);
    });

    test('pause while idle is a no-op', () {
      final e = engine();
      e.pause();
      expect(e.state.status, PomodoroStatus.idle);
    });

    test('tick only counts down while running', () {
      final e = engine();
      e.tick(const Duration(seconds: 3));
      expect(e.state.remaining, config.focus);

      e.start();
      e.tick(const Duration(seconds: 3));
      expect(e.state.remaining, const Duration(seconds: 22));

      e.pause();
      e.tick(const Duration(seconds: 3));
      expect(e.state.remaining, const Duration(seconds: 22));
    });

    test('stop resets remaining to the full phase and keeps sessions', () {
      final e = engine();
      finishPhase(e); // focus #1 done → shortBreak queued
      e.start();
      e.tick(const Duration(seconds: 2));
      e.stop();
      expect(e.state.status, PomodoroStatus.idle);
      expect(e.state.phase, PomodoroPhase.shortBreak);
      expect(e.state.remaining, config.shortBreak);
      expect(e.state.completedSessions, 1);
    });

    test('stopping a focus session early does not count it', () {
      final e = engine();
      e.start();
      e.tick(const Duration(seconds: 24));
      e.stop();
      expect(e.state.completedSessions, 0);
    });

    test('progress goes from 0 to 1 over the phase', () {
      final e = engine();
      e.start();
      e.tick(const Duration(seconds: 5));
      expect(e.progress, closeTo(0.2, 1e-9));
    });
  });

  group('completion', () {
    test(
      'focus completion queues a short break, idle, and counts a session',
      () {
        final e = engine();
        final event = finishPhase(e);
        expect(event, isNotNull);
        expect(event!.finished, PomodoroPhase.focus);
        expect(event.next, PomodoroPhase.shortBreak);
        expect(e.state.phase, PomodoroPhase.shortBreak);
        expect(e.state.status, PomodoroStatus.idle);
        expect(e.state.remaining, config.shortBreak);
        expect(e.state.completedSessions, 1);
      },
    );

    test('overshooting the end still completes exactly once', () {
      final e = engine();
      e.start();
      final event = e.tick(config.focus + const Duration(seconds: 10));
      expect(event, isNotNull);
      expect(e.tick(const Duration(seconds: 1)), isNull); // idle now
      expect(e.state.completedSessions, 1);
    });

    test('break completion returns to focus, idle, no session change', () {
      final e = engine();
      finishPhase(e);
      final event = finishPhase(e);
      expect(event!.finished, PomodoroPhase.shortBreak);
      expect(event.next, PomodoroPhase.focus);
      expect(e.state.phase, PomodoroPhase.focus);
      expect(e.state.status, PomodoroStatus.idle);
      expect(e.state.remaining, config.focus);
      expect(e.state.completedSessions, 1);
    });

    test('every 4th focus session is followed by a long break', () {
      final e = engine();
      final breaks = <PomodoroPhase>[];
      for (var i = 0; i < 12; i++) {
        breaks.add(finishPhase(e)!.next); // focus → break
        finishPhase(e); // break → focus
      }
      for (var i = 0; i < 12; i++) {
        final expected = (i + 1) % 4 == 0
            ? PomodoroPhase.longBreak
            : PomodoroPhase.shortBreak;
        expect(breaks[i], expected, reason: 'after session ${i + 1}');
      }
      expect(e.state.completedSessions, 12);
    });

    test('long break has the long duration', () {
      final e = engine();
      for (var i = 0; i < 3; i++) {
        finishPhase(e);
        finishPhase(e);
      }
      finishPhase(e); // 4th focus
      expect(e.state.phase, PomodoroPhase.longBreak);
      expect(e.state.remaining, config.longBreak);
    });
  });
}
