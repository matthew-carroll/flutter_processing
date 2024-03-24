import 'dart:ui';

import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('Complex shapes', () {
    testGoldens('stars', (tester) async {
      tester.view
        ..physicalSize = Size(640, 360)
        ..devicePixelRatio = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: StarsSketch(),
        ),
      );

      await screenMatchesGolden(tester, 'complex-shapes_stars');

      tester.platformDispatcher.clearAllTestValues();
    });

    testGoldens('triangle strip circle', (tester) async {
      tester.view
        ..physicalSize = Size(640, 360)
        ..devicePixelRatio = 1.0;

      await tester.pumpWidget(
        Processing(
          sketch: TriangleStripCircleSketch(),
        ),
      );

      await screenMatchesGolden(tester, 'complex-shapes_triangle-strip-circle');

      tester.platformDispatcher.clearAllTestValues();
    });
  });
}

/// Adapted from: https://processing.org/examples/star.html
class StarsSketch extends Sketch {
  @override
  void setup() {
    size(width: 640, height: 360);
  }

  @override
  void draw() {
    noLoop();

    pushMatrix();
    translate(x: width * 0.2, y: height * 0.5);
    star(0, 0, 5, 70, 3);
    popMatrix();

    pushMatrix();
    translate(x: width * 0.5, y: height * 0.5);
    star(0, 0, 80, 100, 40);
    popMatrix();

    pushMatrix();
    translate(x: width * 0.8, y: height * 0.5);
    star(0, 0, 30, 70, 5);
    popMatrix();
  }

  void star(double x, double y, double radius1, double radius2, int npoints) {
    final angle = TWO_PI / npoints;
    final halfAngle = angle / 2.0;
    beginShape();
    for (double a = 0; a < TWO_PI; a += angle) {
      double sx = x + cos(a) * radius2;
      double sy = y + sin(a) * radius2;
      vertex(sx, sy);

      sx = x + cos(a + halfAngle) * radius1;
      sy = y + sin(a + halfAngle) * radius1;
      vertex(sx, sy);
    }
    endShape(close: true);
  }
}

/// Adapted from: https://processing.org/examples/trianglestrip.html
class TriangleStripCircleSketch extends Sketch {
  @override
  void setup() {
    size(width: 640, height: 360);
  }

  @override
  void draw() {
    noLoop();

    final x = width / 2;
    final y = height / 2;
    final outsideRadius = 150;
    final insideRadius = 100;

    int numPoints = 30;
    double angle = 0;
    final angleStep = 180.0 / numPoints;

    beginShape(ShapeMode.triangleStrip);
    for (int i = 0; i <= numPoints; i++) {
      double px = x + cos(radians(angle)) * outsideRadius;
      double py = y + sin(radians(angle)) * outsideRadius;
      angle += angleStep;
      vertex(px, py);
      px = x + cos(radians(angle)) * insideRadius;
      py = y + sin(radians(angle)) * insideRadius;
      vertex(px, py);
      angle += angleStep;
    }
    endShape();
  }
}
