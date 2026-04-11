//
// To run specific test group:
//   flutter test test/unit/app_state_test.dart
//   flutter test test/widget/main_screen_test.dart
//   flutter test test/widget/responsive_layout_test.dart
//   flutter test test/integration/edge_case_test.dart

import 'package:flutter_test/flutter_test.dart';

// Unit tests
import 'unit/app_state_test.dart' as app_state;
import 'unit/meds_module_test.dart' as meds_module;

// Widget tests  
import 'widget/main_screen_test.dart' as main_screen;
import 'widget/responsive_layout_test.dart' as responsive_layout;

// Integration tests
import 'integration/edge_case_test.dart' as edge_case;

void main() {
  // Run all test suites
  group('Baseline Test Suite', () {
    app_state.main();
    meds_module.main();
    main_screen.main();
    responsive_layout.main();
    edge_case.main();
  });
}
