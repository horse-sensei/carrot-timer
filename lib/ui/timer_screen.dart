import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../controller/timer_controller.dart';
import '../services/settings_service.dart';
import '../services/window_service.dart';
import 'widgets/always_on_top_toggle.dart';
import 'widgets/control_bar.dart';
import 'widgets/phase_badge.dart';
import 'widgets/session_dots.dart';
import 'widgets/time_display.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({
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
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late bool _alwaysOnTop = widget.initialAlwaysOnTop;

  Future<void> _setAlwaysOnTop(bool value) async {
    setState(() => _alwaysOnTop = value);
    await widget.window.setPinned(value);
    await widget.settings.saveAlwaysOnTop(value);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      // No title bar: the whole surface drags the window. Buttons sit on top
      // and win the gesture arena for taps.
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) => windowManager.startDragging(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: ListenableBuilder(
            listenable: c,
            builder: (context, _) {
              final state = c.state;
              return Column(
                children: [
                  SizedBox(
                    height: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PhaseBadge(phase: state.phase),
                        AlwaysOnTopToggle(
                          enabled: _alwaysOnTop,
                          onChanged: _setAlwaysOnTop,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: TimeDisplay(
                        remaining: state.remaining,
                        progress: c.progress,
                        phase: state.phase,
                      ),
                    ),
                  ),
                  SessionDots(
                    completed: c.sessionsInCycle,
                    total: c.sessionsPerCycle,
                  ),
                  const SizedBox(height: 6),
                  ControlBar(
                    isRunning: state.isRunning,
                    canStop: !state.isIdle,
                    phase: state.phase,
                    onToggle: c.toggle,
                    onStop: c.stop,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
