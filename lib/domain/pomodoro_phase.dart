/// Which kind of countdown is on screen.
enum PomodoroPhase {
  focus,
  shortBreak,
  longBreak;

  bool get isBreak => this != PomodoroPhase.focus;
}

/// Whether the countdown is moving.
enum PomodoroStatus { idle, running, paused }
