import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Transform', () {
    testGoldens('translate(): example 1', (tester) async {
      configureWindowForSpecTest(tester);

      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) {
              s
                ..noLoop()
                ..translate(x: 30, y: 20)
                ..rect(rect: Rect.fromLTWH(0, 0, 55, 55));
            },
          ),
        ),
      );

      await screenMatchesGolden(
        tester,
        'transform_translate-example-1',
      );
    });

    testGoldens('translate(): example 2', (tester) async {
      configureWindowForSpecTest(tester);

      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) {
              s
                ..noLoop()
                ..rect(rect: Rect.fromLTWH(0, 0, 55, 55))
                ..translate(x: 30, y: 20)
                ..rect(rect: Rect.fromLTWH(0, 0, 55, 55))
                ..translate(x: 14, y: 14)
                ..rect(rect: Rect.fromLTWH(0, 0, 55, 55));
            },
          ),
        ),
      );

      await screenMatchesGolden(
        tester,
        'transform_translate-example-2',
      );
    });
  });
}
