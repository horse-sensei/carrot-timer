import 'package:window_manager/window_manager.dart';

/// Window behaviour behind the 📌 toggle.
///
/// "Pinned" means the timer floats above other windows *and* follows the user
/// across Spaces (mission-control workspaces), including full-screen apps, so
/// it stays visible while streaming.
class WindowService {
  const WindowService();

  Future<void> setPinned(bool pinned) async {
    await windowManager.setAlwaysOnTop(pinned);
    await windowManager.setVisibleOnAllWorkspaces(
      pinned,
      visibleOnFullScreen: pinned,
    );
  }
}
