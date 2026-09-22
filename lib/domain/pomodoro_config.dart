/// Durations and cycle rules for a pomodoro run.
class PomodoroConfig {
  const PomodoroConfig({
    this.focus = const Duration(minutes: 25),
    this.shortBreak = const Duration(minutes: 5),
    this.longBreak = const Duration(minutes: 20),
    this.sessionsPerCycle = 4,
  }) : assert(sessionsPerCycle > 0);

  /// Length of one focus session.
  final Duration focus;

  /// Break after a focus session that does not close a cycle.
  final Duration shortBreak;

  /// Break after every [sessionsPerCycle]-th focus session.
  final Duration longBreak;

  /// How many focus sessions make up one cycle (4 → long break at 4, 8, 12…).
  final int sessionsPerCycle;

  static const PomodoroConfig standard = PomodoroConfig();

  /// Seconds instead of minutes. Lets you watch a whole cycle in under a
  /// minute: `flutter run -d macos --dart-define=CARROT_FAST=true`.
  static const PomodoroConfig fast = PomodoroConfig(
    focus: Duration(seconds: 6),
    shortBreak: Duration(seconds: 3),
    longBreak: Duration(seconds: 5),
  );

  /// [fast] when built with `--dart-define=CARROT_FAST=true`, else [standard].
  static const PomodoroConfig fromEnvironment =
      bool.fromEnvironment('CARROT_FAST') ? fast : standard;
}
