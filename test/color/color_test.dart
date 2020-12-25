import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('color goldens', () {
    testGoldens('background()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.background(color: Colors.blue);
            },
          ),
        ),
      );

      await screenMatchesGolden(tester, 'color_fills_background');
    });

    testGoldens('fill()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.fill(const Color(0xFF999999));
              sketch.rect(left: 30, top: 20, width: 55, height: 55);
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'color_fill_1');

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.fill(const Color(0xFFCC6600));
              sketch.rect(left: 30, top: 20, width: 55, height: 55);
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'color_fill_2');
    });

    testGoldens('noFill()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.rect(left: 15, top: 10, width: 55, height: 55);
              sketch.noFill();
              sketch.rect(left: 30, top: 20, width: 55, height: 55);
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'color_noFill');
    });

    testGoldens('stroke()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.stroke(const Color(0xFF999999));
              sketch.rect(left: 30, top: 20, width: 55, height: 55);
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'color_stroke_1');

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.stroke(const Color(0xFFCC6600));
              sketch.rect(left: 30, top: 20, width: 55, height: 55);
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'color_stroke_2');
    });

    testGoldens('noStroke()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.noStroke();
              sketch.rect(left: 30, top: 20, width: 55, height: 55);
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'color_noStroke');
    });
  });
}
