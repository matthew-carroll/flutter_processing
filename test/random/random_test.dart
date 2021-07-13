import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Random', () {
    testWidgets('random()', (tester) async {
      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) async {
              s
                ..noLoop()
                ..randomSeed(0);

              // with upper bound
              double randomValue = s.random(50);
              expect(randomValue, 41.27570359435851);

              // with lower and upper bound
              randomValue = s.random(-50, 50);
              expect(randomValue, 38.63148172405516);

              // with a lower bound that is larger than upper bound
              expectLater(() {
                s.random(10, 5);
              }, throwsA(isA<Exception>()));
            },
          ),
        ),
      );
    });

    testGoldens('randomGaussian() - vertical distribution', (tester) async {
      configureWindowForSpecTest(tester);

      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) async {
              s
                ..noLoop()
                ..randomSeed(0);

              for (int y = 0; y < 100; y++) {
                final x = s.randomGaussian() * 15;
                s.line(Offset(50, y.toDouble()), Offset(50.0 + x, y.toDouble()));
              }
            },
          ),
        ),
      );

      await screenMatchesGolden(tester, 'random_gaussian_example-1');
    });

    testGoldens('randomGaussian() - radial distribution', (tester) async {
      configureWindowForSpecTest(tester);

      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            setup: (s) async {},
            draw: (s) async {
              s
                ..noLoop()
                ..randomSeed(0)
                ..translate(x: s.width / 2, y: s.height / 2)
                ..stroke(color: Colors.black);

              final distribution = List<double>.generate(360, (index) {
                return s.randomGaussian() * 15;
              });

              for (int i = 0; i < distribution.length; i++) {
                s.rotate(2 * pi / distribution.length);
                final dist = distribution[i].abs();
                s.line(Offset(0, 0), Offset(dist, 0));
              }
            },
          ),
        ),
      );

      await screenMatchesGolden(tester, 'random_gaussian_example-2');
    });
  });
}
