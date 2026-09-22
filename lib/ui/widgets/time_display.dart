import 'package:flutter/material.dart';

import '../../domain/pomodoro_phase.dart';
import '../theme.dart';

class TimeDisplay extends StatelessWidget {
  const TimeDisplay({
    super.key,
    required this.remaining,
    required this.progress,
    required this.phase,
    this.size = 100,
  });

  final Duration remaining;

  /// 0.0 at the start of the phase, 1.0 when it is finished.
  final double progress;
  final PomodoroPhase phase;
  final double size;

  static String format(Duration d) {
    // Ceil so 24:59.7 reads 25:00 rather than flashing 24:59 immediately.
    final totalSeconds = (d.inMilliseconds / 1000).ceil();
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = CarrotColors.forPhase(phase);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1 - progress,
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
            color: color,
            backgroundColor: CarrotColors.soilLight,
          ),
          Center(
            child: Text(
              format(remaining),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: CarrotColors.cream,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
