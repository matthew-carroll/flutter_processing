import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_infra.dart';

void main() {
  group('Shape', () {
    group('2D primitives', () {
      processingLegacySpecTest('circle(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..circle(
                    center: const Offset(56, 46),
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

      processingLegacySpecTest('square(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..square(
                    Square.fromLTE(const Offset(30, 20), 55),
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_square-example-1', customPump: (tester) async {
          await tester.pump(const Duration(milliseconds: 17));
        });
      });

      processingLegacySpecTest('rect(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..rect(
                    rect: const Rect.fromLTWH(30, 20, 55, 55),
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_rect-example-1');
      });

      processingLegacySpecTest('rect(): example 2', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..rect(
                    rect: const Rect.fromLTWH(30, 20, 55, 55),
                    borderRadius: BorderRadius.circular(7),
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_rect-example-2');
      });

      processingLegacySpecTest('rect(): example 3', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..rect(
                    rect: const Rect.fromLTWH(30, 20, 55, 55),
                    borderRadius: const BorderRadius.only(
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

        await screenMatchesGolden(tester, 'shape_2d-primitives_rect-example-3');
      });

      processingLegacySpecTest('triangle(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..triangle(
                    const Offset(30, 75),
                    const Offset(58, 20),
                    const Offset(86, 75),
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_triangle-example-1');
      });

      processingLegacySpecTest('quad(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..quad(
                    const Offset(38, 31),
                    const Offset(86, 20),
                    const Offset(69, 63),
                    const Offset(30, 76),
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_quad-example-1');
      });

      processingLegacySpecTest('line(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..line(
                    const Offset(30, 20),
                    const Offset(85, 75),
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_line-example-1');
      });

      processingLegacySpecTest('line(): example 2', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..line(
                    const Offset(30, 20),
                    const Offset(85, 20),
                  )
                  ..stroke(color: const Color.fromARGB(255, 126, 126, 126))
                  ..line(
                    const Offset(85, 20),
                    const Offset(85, 75),
                  )
                  ..stroke(color: const Color.fromARGB(255, 255, 255, 255))
                  ..line(
                    const Offset(85, 75),
                    const Offset(30, 75),
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_line-example-2');
      });

      processingLegacySpecTest('point(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s //
                  ..noLoop()
                  ..point(x: 30, y: 20) //
                  ..point(x: 85, y: 20) //
                  ..point(x: 85, y: 75) //
                  ..point(x: 30, y: 75);
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_point-example-1');
      });

      processingLegacySpecTest('ellipse(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..ellipse(
                    Ellipse.fromCenter(
                      center: const Offset(56, 46),
                      width: 55,
                      height: 55,
                    ),
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_ellipse-example-1');
      });

      processingLegacySpecTest('ellipse(): example 2', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..fill(color: const Color.fromARGB(255, 255, 255, 255))
                  ..ellipse(
                    Ellipse.fromCenterWithRadius(
                      center: const Offset(50, 50),
                      radius1: 30,
                      radius2: 30,
                    ),
                  )
                  ..fill(color: const Color.fromARGB(255, 100, 100, 100))
                  ..ellipse(
                    Ellipse.fromCenter(
                      center: const Offset(50, 50),
                      width: 30,
                      height: 30,
                    ),
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_ellipse-example-2');
      });

      processingLegacySpecTest('ellipse(): example 3', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..fill(color: const Color.fromARGB(255, 255, 255, 255))
                  ..ellipse(
                    Ellipse.fromLTWH(
                      topLeft: const Offset(25, 25),
                      width: 50,
                      height: 50,
                    ),
                  )
                  ..fill(color: const Color.fromARGB(255, 100, 100, 100))
                  ..ellipse(
                    Ellipse.fromLTRB(
                      topLeft: const Offset(25, 25),
                      bottomRight: const Offset(50, 50),
                    ),
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_ellipse-example-3');
      });

      processingLegacySpecTest('arc(): example 1', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s //
                  ..noLoop()
                  ..arc(
                    ellipse: Ellipse.fromCenter(center: const Offset(50, 55), width: 50, height: 50),
                    startAngle: 0,
                    endAngle: pi / 2,
                  )
                  ..noFill()
                  ..arc(
                    ellipse: Ellipse.fromCenter(center: const Offset(50, 55), width: 60, height: 60),
                    startAngle: pi / 2,
                    endAngle: pi,
                  )
                  ..arc(
                    ellipse: Ellipse.fromCenter(center: const Offset(50, 55), width: 70, height: 70),
                    startAngle: pi,
                    endAngle: pi + (pi / 4),
                  )
                  ..arc(
                    ellipse: Ellipse.fromCenter(center: const Offset(50, 55), width: 80, height: 80),
                    startAngle: pi + (pi / 4),
                    endAngle: 2 * pi,
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_arc-example-1');
      });

      processingLegacySpecTest('arc(): example 2', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..arc(
                    ellipse: Ellipse.fromCenter(center: const Offset(50, 50), width: 80, height: 80),
                    startAngle: 0,
                    endAngle: pi + (pi / 4),
                    mode: ArcMode.open,
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_arc-example-2');
      });

      processingLegacySpecTest('arc(): example 3', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..arc(
                    ellipse: Ellipse.fromCenter(center: const Offset(50, 50), width: 80, height: 80),
                    startAngle: 0,
                    endAngle: pi + (pi / 4),
                    mode: ArcMode.chord,
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_arc-example-3');
      });

      processingLegacySpecTest('arc(): example 4', (tester) async {
        await tester.pumpWidget(
          Processing(
            sketch: Sketch.simple(
              draw: (s) {
                s
                  ..noLoop()
                  ..arc(
                    ellipse: Ellipse.fromCenter(center: const Offset(50, 50), width: 80, height: 80),
                    startAngle: 0,
                    endAngle: pi + (pi / 4),
                    mode: ArcMode.pie,
                  );
              },
            ),
          ),
        );

        await screenMatchesGolden(tester, 'shape_2d-primitives_arc-example-4');
      });
    });
  });
}
