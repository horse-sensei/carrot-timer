import 'pomodoro_config.dart';
import 'pomodoro_phase.dart';

/// Immutable snapshot of the timer.
class PomodoroState {
  const PomodoroState({
    required this.phase,
    required this.status,
    required this.remaining,
    required this.completedSessions,
  });

  final PomodoroPhase phase;
  final PomodoroStatus status;
  final Duration remaining;

  /// Focus sessions that ran to completion (stopping early does not count).
  final int completedSessions;

  bool get isRunning => status == PomodoroStatus.running;
  bool get isIdle => status == PomodoroStatus.idle;

  PomodoroState copyWith({
    PomodoroPhase? phase,
    PomodoroStatus? status,
    Duration? remaining,
    int? completedSessions,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      status: status ?? this.status,
      remaining: remaining ?? this.remaining,
      completedSessions: completedSessions ?? this.completedSessions,
    );
  }

  @override
  String toString() =>
      'PomodoroState($phase, $status, $remaining, sessions=$completedSessions)';
}

/// Emitted by [PomodoroEngine.tick] when a countdown reaches zero.
class PhaseCompleted {
  const PhaseCompleted({required this.finished, required this.next});

  /// The phase that just ended.
  final PomodoroPhase finished;

  /// The phase now queued (idle) and waiting for the user to press play.
  final PomodoroPhase next;
}

/// Pure pomodoro state machine. Holds no timers; callers feed elapsed time
/// through [tick] and react to the returned [PhaseCompleted] event.
class PomodoroEngine {
  PomodoroEngine({this.config = PomodoroConfig.standard})
    : _state = PomodoroState(
        phase: PomodoroPhase.focus,
        status: PomodoroStatus.idle,
        remaining: config.focus,
        completedSessions: 0,
      );

  final PomodoroConfig config;
  PomodoroState _state;

  PomodoroState get state => _state;

  Duration durationOf(PomodoroPhase phase) => switch (phase) {
    PomodoroPhase.focus => config.focus,
    PomodoroPhase.shortBreak => config.shortBreak,
    PomodoroPhase.longBreak => config.longBreak,
  };

  /// Full length of the phase currently on screen.
  Duration get currentPhaseDuration => durationOf(_state.phase);

  /// 0.0 at the start of a phase, 1.0 when it is done.
  double get progress {
    final total = currentPhaseDuration.inMilliseconds;
    if (total == 0) return 1;
    final done = total - _state.remaining.inMilliseconds;
    return (done / total).clamp(0, 1);
  }

  void start() {
    if (_state.isRunning) return;
    _state = _state.copyWith(status: PomodoroStatus.running);
  }

  void pause() {
    if (!_state.isRunning) return;
    _state = _state.copyWith(status: PomodoroStatus.paused);
  }

  /// Back to the top of the current phase. Session count is kept.
  void stop() {
    _state = _state.copyWith(
      status: PomodoroStatus.idle,
      remaining: currentPhaseDuration,
    );
  }

  /// Advance the countdown by [elapsed]. Returns a [PhaseCompleted] when the
  /// phase ends; the engine then sits idle on the next phase.
  PhaseCompleted? tick(Duration elapsed) {
    if (!_state.isRunning) return null;
    final remaining = _state.remaining - elapsed;
    if (remaining > Duration.zero) {
      _state = _state.copyWith(remaining: remaining);
      return null;
    }
    return _complete();
  }

  PhaseCompleted _complete() {
    final finished = _state.phase;
    var sessions = _state.completedSessions;
    final PomodoroPhase next;
    if (finished == PomodoroPhase.focus) {
      sessions += 1;
      next = sessions % config.sessionsPerCycle == 0
          ? PomodoroPhase.longBreak
          : PomodoroPhase.shortBreak;
    } else {
      next = PomodoroPhase.focus;
    }
    _state = PomodoroState(
      phase: next,
      status: PomodoroStatus.idle,
      remaining: durationOf(next),
      completedSessions: sessions,
    );
    return PhaseCompleted(finished: finished, next: next);
  }
}
