import 'package:carrot_timer/controller/timer_controller.dart';
import 'package:carrot_timer/domain/pomodoro_config.dart';
import 'package:carrot_timer/domain/pomodoro_phase.dart';
import 'package:carrot_timer/services/notification_service.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNotifications implements NotificationService {
  final calls = <(PomodoroPhase, PomodoroPhase, Duration)>[];

  @override
  Future<void> notifyPhaseComplete({
    required PomodoroPhase finished,
    required PomodoroPhase next,
    required Duration nextDuration,
  }) async {
    calls.add((finished, next, nextDuration));
  }
}

void main() {
  const config = PomodoroConfig(
    focus: Duration(seconds: 25),
    shortBreak: Duration(seconds: 5),
    longBreak: Duration(seconds: 20),
  );

  test('counts down in wall-clock time and notifies once on completion', () {
    fakeAsync((async) {
      final fake = FakeNotifications();
      final c = TimerController(notifications: fake, config: config);
      var notified = 0;
      c.addListener(() => notified++);

      c.start();
      async.elapse(const Duration(seconds: 10));
      expect(c.state.remaining, const Duration(seconds: 15));
      expect(c.state.isRunning, isTrue);

      async.elapse(const Duration(seconds: 15));
      expect(c.state.phase, PomodoroPhase.shortBreak);
      expect(c.state.status, PomodoroStatus.idle);
      expect(c.state.completedSessions, 1);
      expect(fake.calls, [
        (PomodoroPhase.focus, PomodoroPhase.shortBreak, config.shortBreak),
      ]);

      // Idle: nothing else should happen even as time passes.
      async.elapse(const Duration(minutes: 1));
      expect(fake.calls.length, 1);
      expect(c.state.remaining, config.shortBreak);
      expect(notified, greaterThan(0));
      c.dispose();
    });
  });

  test('pause freezes the clock, resume continues from the same point', () {
    fakeAsync((async) {
      final c = TimerController(
        notifications: FakeNotifications(),
        config: config,
      );
      c.start();
      async.elapse(const Duration(seconds: 7));
      c.pause();
      expect(c.state.remaining, const Duration(seconds: 18));
      async.elapse(const Duration(seconds: 30));
      expect(c.state.remaining, const Duration(seconds: 18));
      c.start();
      async.elapse(const Duration(seconds: 3));
      expect(c.state.remaining, const Duration(seconds: 15));
      c.dispose();
    });
  });

  test('stop resets to the full phase and stops the clock', () {
    fakeAsync((async) {
      final c = TimerController(
        notifications: FakeNotifications(),
        config: config,
      );
      c.start();
      async.elapse(const Duration(seconds: 4));
      c.stop();
      expect(c.state.remaining, config.focus);
      expect(c.state.status, PomodoroStatus.idle);
      async.elapse(const Duration(seconds: 4));
      expect(c.state.remaining, config.focus);
      c.dispose();
    });
  });

  test('toggle flips between running and paused', () {
    fakeAsync((async) {
      final c = TimerController(
        notifications: FakeNotifications(),
        config: config,
      );
      c.toggle();
      expect(c.state.status, PomodoroStatus.running);
      c.toggle();
      expect(c.state.status, PomodoroStatus.paused);
      c.dispose();
    });
  });

  test('sessionsInCycle fills to 4 during the long break, then rolls over', () {
    fakeAsync((async) {
      final c = TimerController(
        notifications: FakeNotifications(),
        config: config,
      );
      void run(Duration d) {
        c.start();
        async.elapse(d);
      }

      expect(c.sessionsInCycle, 0);
      for (var i = 1; i <= 3; i++) {
        run(config.focus);
        expect(c.sessionsInCycle, i);
        run(config.shortBreak);
        expect(c.sessionsInCycle, i);
      }
      run(config.focus); // 4th
      expect(c.state.phase, PomodoroPhase.longBreak);
      expect(c.sessionsInCycle, 4);
      run(config.longBreak);
      expect(c.state.phase, PomodoroPhase.focus);
      expect(c.sessionsInCycle, 0);
      c.dispose();
    });
  });
}
