import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Color', () {
    group('setting', () {
      testGoldens('background(): example 1', (tester) async {
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

        await screenMatchesGolden(tester, 'color_setting_background-example-1');
      });

      testGoldens('background(): example 2', (tester) async {
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

        await screenMatchesGolden(tester, 'color_setting_background-example-2');
      });

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

        await screenMatchesGolden(tester, 'color_setting_background-in-setup');
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

        await screenMatchesGolden(
            tester,
            'color_setting_background-setup-and'
            '-draw');
      });
    });
  });
}
