import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Shape', () {
    group('2D primitives', () {
      testGoldens('circle(): example 1', (tester) async {
        configureWindowForSpecTest(tester);

        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s.circle(
                  center: Offset(56, 46),
                  diameter: 55,
                );
              },
            ),
          ),
        );

        await screenMatchesGolden(
            tester,
            'shape_2d-primitives_circle-example'
            '-1');
      });
    });
  });
}
