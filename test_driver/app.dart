// Dev-only entrypoint: `flutter run -d macos -t test_driver/app.dart`.
// Enables the flutter_driver extension so the running app can be driven
// (tap buttons, read text) from tooling. Not used by the shipped app.
import 'package:flutter_driver/driver_extension.dart';

import 'package:carrot_timer/main.dart' as app;

void main() {
  enableFlutterDriverExtension();
  app.main();
}
