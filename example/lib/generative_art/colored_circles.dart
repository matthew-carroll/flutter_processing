import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';

class ColoredCirclesSketch extends Sketch {
  ColoredCirclesSketch({
    required this.width,
    required this.height,
    this.maxCircleRadius = 30.0,
    this.circleMargin = 5.0,
    this.innerCircleProbability = 0.50,
  });

  @override
  final int width;
  @override
  final int height;
  final double maxCircleRadius;
  final double circleMargin;
  final double innerCircleProbability;

  @override
  void setup() {
    size(width: width, height: height);
  }

  @override
  Future<void> draw() async {
    background(color: const Color(0xFF111111));

    noStroke();

    final circleDiameter = maxCircleRadius * 2;
    final spaceBetweenCircles = circleDiameter + (2 * circleMargin);
    final circlesPerRow = (width / spaceBetweenCircles).ceil() + 1; // +1 for partial circle at end of row
    final circlesPerColumn = (height / spaceBetweenCircles).ceil() + 1; // +1 for partial circle at end of col
    for (int colIndex = 0; colIndex < circlesPerRow; colIndex += 1) {
      for (int rowIndex = 0; rowIndex < circlesPerColumn; rowIndex += 1) {
        fill(
          color: HSVColor.fromAHSV(1.0, random(360), 0.7, 0.8).toColor(),
        );

        final outerCircleDiameter = random(10, circleDiameter);
        circle(
          center: Offset(colIndex * spaceBetweenCircles, rowIndex * spaceBetweenCircles),
          diameter: outerCircleDiameter,
        );

        if (random(1.0) < innerCircleProbability) {
          fill(
            color: HSVColor.fromAHSV(1.0, random(360), 0.7, 0.8).toColor(),
          );

          final innerCircleDiameter = random(10, outerCircleDiameter);
          circle(
            center: Offset(colIndex * spaceBetweenCircles, rowIndex * spaceBetweenCircles),
            diameter: innerCircleDiameter,
          );
        }
      }
    }

    noLoop();
  }
}
