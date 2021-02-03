import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'test_infra.dart';

void main() {
  group('core', () {
    testGoldens('user can paint background in setup()', (tester) async {
      configureWindowForSpecTest(tester);

      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            setup: (s) {
              s.background(color: const Color(0xFF404040));
            },
          ),
        ),
      );

      await screenMatchesGolden(tester, 'core_setup_background');
    });

    testGoldens('user can paint background in draw()', (tester) async {
      configureWindowForSpecTest(tester);

      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) {
              s.background(color: const Color(0xFF404040));
            },
          ),
        ),
      );

      await screenMatchesGolden(tester, 'core_draw_background');
    });

    testGoldens('user can paint orange background', (tester) async {
      configureWindowForSpecTest(tester);

      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) {
              s.background(color: const Color(0xFFFFCC00));
            },
          ),
        ),
      );

      await screenMatchesGolden(tester, 'core_draw_background_orange');
    });

    testGoldens('background in draw() replaces background in setup()',
        (tester) async {
      configureWindowForSpecTest(tester);

      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            setup: (s) {
              s.background(color: const Color(0xFFFF0000));
            },
            draw: (s) {
              s.background(color: const Color(0xFF404040));
            },
          ),
        ),
      );

      await screenMatchesGolden(tester, 'core_background_setup_draw');
    });
  });
}
