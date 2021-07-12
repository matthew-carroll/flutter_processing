import 'dart:async';
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

    testGoldens('noise()', (tester) async {
      configureWindowForSpecTest(tester);

      final completer = Completer();

      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) async {
              s
                ..noLoop()
                ..noiseSeed(0);

              await s.loadPixels();

              for (int col = 0; col < s.width; ++col) {
                for (int row = 0; row < s.height; ++row) {
                  final widthPercent = col / s.width;
                  final heightPercent = row / s.height;

                  final perlinValue = s.noise(
                    x: widthPercent * 1000,
                    y: heightPercent * 1000,
                  );

                  final grayAmount = (perlinValue * 0xFF).round();

                  final pixelColor = Color.fromARGB(0xFF, grayAmount, grayAmount, grayAmount);

                  s.set(
                    x: col,
                    y: row,
                    color: pixelColor,
                  );
                }
              }

              await s.updatePixels();

              completer.complete();
            },
          ),
        ),
      );

      await completer.future;

      await screenMatchesGolden(tester, 'random_noise');
    });

    testGoldens('randomGaussian() - vertical distribution', (tester) async {
      configureWindowForSpecTest(tester);

      await tester.pumpWidget(
        Processing(
          sketch: Sketch.simple(
            draw: (s) async {
              s
                ..noLoop()
                ..noiseSeed(0);

              for (int y = 0; y < s.width; y++) {
                final x = s.randomGaussian() * 15;
                s.line(Offset(s.width / 2, y.toDouble()), Offset((s.width / 2) + x, y.toDouble()));
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
            draw: (s) async {
              s
                ..noLoop()
                ..noiseSeed(0);

              final distribution = List<double>.generate(360, (int index) {
                return s.randomGaussian() * 15;
              });

              s.translate(x: s.width / 2, y: s.height / 2);

              for (int i = 0; i < distribution.length; i++) {
                s.rotate(2 * pi / distribution.length);
                s.stroke(color: Colors.black);
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
