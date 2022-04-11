import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Color', () {
    group('Creating and Reading', () {
      processingLegacySpecTest('alpha()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s.noLoop();

                s.noStroke();
                final color = s.color(alpha: 102, comp1: 0, comp2: 126, comp3: 255);
                s.fill(color: color);
                s.rect(rect: const Rect.fromLTWH(15, 15, 35, 70));
                final value = s.alpha(color);
                s.fill(color: s.color(grey: value));
                s.rect(rect: const Rect.fromLTWH(50, 15, 35, 70));
              },
            ),
          ),
        );

        await screenMatchesGolden(
          tester,
          'color_creating-and-reading_alpha',
        );
      });

      processingLegacySpecTest('red()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s.noLoop();

                final c = s.color(comp1: 255, comp2: 204, comp3: 0);
                s.fill(color: c);
                s.rect(rect: const Rect.fromLTWH(15, 20, 35, 60));

                final redValue = s.red(c);
                s.fill(color: s.color(comp1: redValue, comp2: 0, comp3: 0));
                s.rect(rect: const Rect.fromLTWH(50, 20, 35, 60));
              },
            ),
          ),
        );

        await screenMatchesGolden(
          tester,
          'color_creating-and-reading_red',
        );
      });

      processingLegacySpecTest('green()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s.noLoop();

                final color = s.color(comp1: 20, comp2: 75, comp3: 200);
                s.fill(color: color);
                s.rect(rect: const Rect.fromLTWH(15, 20, 35, 60));

                final greenValue = s.green(color);
                s.fill(color: s.color(comp1: 0, comp2: greenValue, comp3: 0));
                s.rect(rect: const Rect.fromLTWH(50, 20, 35, 60));
              },
            ),
          ),
        );

        await screenMatchesGolden(
          tester,
          'color_creating-and-reading_green',
        );
      });

      processingLegacySpecTest('blue()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s.noLoop();

                final color = s.color(comp1: 175, comp2: 110, comp3: 220);
                s.fill(color: color);
                s.rect(rect: const Rect.fromLTWH(15, 20, 35, 60));

                final blueValue = s.blue(color);
                s.fill(color: s.color(comp1: 0, comp2: 0, comp3: blueValue));
                s.rect(rect: const Rect.fromLTWH(50, 20, 35, 60));
              },
            ),
          ),
        );

        await screenMatchesGolden(
          tester,
          'color_creating-and-reading_blue',
        );
      });

      processingLegacySpecTest('hue()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s.noLoop();

                s.noStroke();
                s.colorMode(ColorMode.hsb);
                final c = s.color(comp1: 0, comp2: 126, comp3: 255);
                s.fill(color: c);
                s.rect(rect: const Rect.fromLTWH(15, 20, 35, 60));
                final value = s.hue(c);
                s.fill(color: s.color(grey: value));
                s.rect(rect: const Rect.fromLTWH(50, 20, 35, 60));
              },
            ),
          ),
        );

        await screenMatchesGolden(
          tester,
          'color_creating-and-reading_hue',
        );
      });

      processingLegacySpecTest('saturation()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s.noLoop();

                s.noStroke();
                s.colorMode(ColorMode.hsb);
                final c = s.color(comp1: 0, comp2: 126, comp3: 255);
                s.fill(color: c);
                s.rect(rect: const Rect.fromLTWH(15, 20, 35, 60));
                final value = s.saturation(c);
                s.fill(color: s.color(grey: value));
                s.rect(rect: const Rect.fromLTWH(50, 20, 35, 60));
              },
            ),
          ),
        );

        await screenMatchesGolden(
          tester,
          'color_creating-and-reading_saturation',
        );
      });

      processingLegacySpecTest('brightness()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s.noLoop();

                s.noStroke();
                s.colorMode(ColorMode.hsb);
                final c = s.color(comp1: 0, comp2: 126, comp3: 255);
                s.fill(color: c);
                s.rect(rect: const Rect.fromLTWH(15, 20, 35, 60));
                final value = s.brightness(c);
                s.fill(color: s.color(grey: value));
                s.rect(rect: const Rect.fromLTWH(50, 20, 35, 60));
              },
            ),
          ),
        );

        await screenMatchesGolden(
          tester,
          'color_creating-and-reading_brightness',
        );
      });

      processingLegacySpecTest('lerpColor()', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s.noLoop();

                s.stroke(color: s.color(grey: 255));
                s.background(color: s.color(grey: 51));
                final from = s.color(comp1: 204, comp2: 102, comp3: 0);
                final to = s.color(comp1: 0, comp2: 102, comp3: 153);
                final interA = s.lerpColor(from, to, .33);
                final interB = s.lerpColor(from, to, .66);
                s
                  ..fill(color: from)
                  ..rect(rect: const Rect.fromLTWH(10, 20, 20, 60))
                  ..fill(color: interA)
                  ..rect(rect: const Rect.fromLTWH(30, 20, 20, 60))
                  ..fill(color: interB)
                  ..rect(rect: const Rect.fromLTWH(50, 20, 20, 60))
                  ..fill(color: to)
                  ..rect(rect: const Rect.fromLTWH(70, 20, 20, 60));
              },
            ),
          ),
        );

        await screenMatchesGolden(
          tester,
          'color_creating-and-reading_lerpColor',
        );
      });
    });
  });
}
