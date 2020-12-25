import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing/src/_two_d_primitives.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('2D primitives goldens', () {
    testGoldens('arc()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.arc(
                x: 50,
                y: 55,
                width: 50,
                height: 50,
                startAngleInRadians: 0,
                endAngleInRadians: sketch.HALF_PI,
              );
              sketch.noFill();
              sketch.arc(
                x: 50,
                y: 55,
                width: 60,
                height: 60,
                startAngleInRadians: sketch.HALF_PI,
                endAngleInRadians: sketch.PI,
              );
              sketch.arc(
                x: 50,
                y: 55,
                width: 70,
                height: 70,
                startAngleInRadians: sketch.PI,
                endAngleInRadians: sketch.PI + sketch.QUARTER_PI,
              );
              sketch.arc(
                x: 50,
                y: 55,
                width: 80,
                height: 80,
                startAngleInRadians: sketch.PI + sketch.QUARTER_PI,
                endAngleInRadians: sketch.TWO_PI,
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_arc_1');

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.arc(
                x: 50,
                y: 50,
                width: 80,
                height: 80,
                startAngleInRadians: 0,
                endAngleInRadians: sketch.PI + sketch.QUARTER_PI,
                arcMode: ArcMode.open,
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_arc_2');

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.arc(
                x: 50,
                y: 50,
                width: 80,
                height: 80,
                startAngleInRadians: 0,
                endAngleInRadians: sketch.PI + sketch.QUARTER_PI,
                arcMode: ArcMode.chord,
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_arc_3');

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.arc(
                x: 50,
                y: 50,
                width: 80,
                height: 80,
                startAngleInRadians: 0,
                endAngleInRadians: sketch.PI + sketch.QUARTER_PI,
                arcMode: ArcMode.pie,
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_arc_4');
    });

    testGoldens('circle()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.circle(
                center: Offset(56, 46),
                diameter: 55,
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_circle');
    });

    testGoldens('ellipse()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.ellipse(
                center: Offset(56, 46),
                width: 55,
                height: 55,
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_ellipse_1');

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.ellipse(
                center: Offset(56, 46),
                width: 80,
                height: 55,
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_ellipse_2');
    });

    testGoldens('line()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.line(
                fromX: 30,
                fromY: 20,
                toX: 85,
                toY: 75,
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_line_1');

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.line(fromX: 30, fromY: 20, toX: 85, toY: 20);

              sketch.stroke(const Color(0xFF7E7E7E));

              sketch.line(fromX: 85, fromY: 20, toX: 85, toY: 75);

              sketch.stroke(Colors.white);

              sketch.line(fromX: 85, fromY: 75, toX: 30, toY: 75);
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_line_2');

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              // TODO: implement 3D points
              sketch.line(
                  fromX: 30, fromY: 20, fromZ: 0, toX: 85, toY: 75, toZ: 15);

              sketch.stroke(const Color(0xFF7E7E7E));

              sketch.line(
                  fromX: 85, fromY: 20, fromZ: 15, toX: 85, toY: 75, toZ: 0);

              sketch.stroke(Colors.white);

              sketch.line(
                  fromX: 85, fromY: 75, fromZ: 0, toX: 30, toY: 75, toZ: -50);
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_line_3');
    });

    testGoldens('quad()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.quad(
                p1: Offset(38, 31),
                p2: Offset(86, 20),
                p3: Offset(69, 63),
                p4: Offset(30, 76),
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_quad');
    });

    testGoldens('rect()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.rect(left: 30, top: 20, width: 55, height: 55);
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_rect_1');

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.rect(
                left: 30,
                top: 20,
                width: 55,
                height: 55,
                borderRadius: BorderRadius.circular(7),
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_rect_2');

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.rect(
                left: 30,
                top: 20,
                width: 55,
                height: 55,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(18),
                ),
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_rect_3');
    });

    testGoldens('square()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.square(
                left: 30,
                top: 20,
                size: 55,
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_square');
    });

    testGoldens('triangle()', (tester) async {
      tester.binding.window
        ..physicalSizeTestValue = const Size(100, 100)
        ..devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: SketchBuilder(
            draw: (Sketch sketch) {
              sketch.triangle(
                p1: Offset(30, 75),
                p2: Offset(58, 20),
                p3: Offset(86, 75),
              );
            },
          ),
        ),
      );
      await screenMatchesGolden(tester, 'two_d_primitives_triangle');
    });
  });
}
