import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Math', () {
    group('trigonometry', () {
      processingSpecTest('sin()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s.noLoop();

                double angleInRadians = 0.0;
                double increment = s.TWO_PI / 25.0;

                for (double i = 0; i < 100; i = i + 4) {
                  s.line(Offset(i, 50), Offset(i, 50 + sin(angleInRadians) * 40.0));
                  angleInRadians = angleInRadians + increment;
                }
              },
            ),
          ),
        );

        await screenMatchesGolden(
          tester,
          'math_trigonometry_sin',
        );
      });

      processingSpecTest('cos()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s.noLoop();

                double angle = 0.0;
                double increment = s.TWO_PI / 25.0;

                for (double i = 0; i < 25; i++) {
                  s.line(Offset(i * 4, 50), Offset(i * 4, 50 + cos(angle) * 40.0));
                  angle = angle + increment;
                }
              },
            ),
          ),
        );

        await screenMatchesGolden(
          tester,
          'math_trigonometry_cos',
        );
      });

      processingSpecTest('tan()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) async {
                s.noLoop();

                double angleInRadians = 0.0;
                double increment = s.TWO_PI / 50.0;

                for (double i = 0; i < 100; i = i + 2) {
                  s.line(Offset(i, 50), Offset(i, 50 + tan(angleInRadians) * 2.0));
                  angleInRadians = angleInRadians + increment;
                }
              },
            ),
          ),
        );

        await screenMatchesGolden(
          tester,
          'math_trigonometry_tan',
        );
      });
    });
  });
}
