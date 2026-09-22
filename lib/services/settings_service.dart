import 'package:shared_preferences/shared_preferences.dart';

/// The only persisted setting: whether the window floats above others.
class SettingsService {
  const SettingsService();

  static const _alwaysOnTopKey = 'alwaysOnTop';

  Future<bool> loadAlwaysOnTop() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_alwaysOnTopKey) ?? false;
  }

  Future<void> saveAlwaysOnTop(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alwaysOnTopKey, value);
  }
}
