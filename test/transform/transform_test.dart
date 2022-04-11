import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Transform', () {
    processingSpecTest('pushMatrix(): example 1', (tester) async {
      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) {
              s
                ..size(width: 400, height: 400)
                ..noLoop()
                ..fill(color: Colors.white)
                ..rect(rect: const Rect.fromLTWH(0, 0, 200, 200))
                ..pushMatrix()
                ..translate(x: 120, y: 80)
                ..fill(color: Colors.black)
                ..rect(rect: const Rect.fromLTWH(0, 0, 200, 200))
                ..popMatrix()
                ..fill(color: const Color.fromARGB(255, 100, 100, 100))
                ..rect(rect: const Rect.fromLTWH(60, 40, 200, 200));
            },
          ),
        ),
      );

      await screenMatchesGolden(
        tester,
        'transform_pushMatrix_1',
      );
    });

    processingLegacySpecTest('translate(): example 1', (tester) async {
      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) {
              s
                ..noLoop()
                ..translate(x: 30, y: 20)
                ..rect(rect: const Rect.fromLTWH(0, 0, 55, 55));
            },
          ),
        ),
      );

      await screenMatchesGolden(
        tester,
        'transform_translate-example-1',
      );
    });

    processingLegacySpecTest('translate(): example 2', (tester) async {
      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) {
              s
                ..noLoop()
                ..rect(rect: const Rect.fromLTWH(0, 0, 55, 55))
                ..translate(x: 30, y: 20)
                ..rect(rect: const Rect.fromLTWH(0, 0, 55, 55))
                ..translate(x: 14, y: 14)
                ..rect(rect: const Rect.fromLTWH(0, 0, 55, 55));
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
