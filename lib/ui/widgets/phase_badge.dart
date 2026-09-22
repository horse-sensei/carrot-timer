import 'package:flutter/material.dart';

import '../../domain/pomodoro_phase.dart';
import '../theme.dart';

class PhaseBadge extends StatelessWidget {
  const PhaseBadge({super.key, required this.phase});

  final PomodoroPhase phase;

  @override
  Widget build(BuildContext context) {
    final label = switch (phase) {
      PomodoroPhase.focus => '집중',
      PomodoroPhase.shortBreak => '짧은 휴식',
      PomodoroPhase.longBreak => '긴 휴식',
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🥕', style: TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: CarrotColors.forPhase(phase),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
