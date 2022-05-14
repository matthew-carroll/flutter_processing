import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';

class DotFieldSketch extends Sketch {
  DotFieldSketch({
    required this.width,
    required this.height,
    this.gridSize = 30,
    this.dotDiameter = 3,
  });

  @override
  final int width;
  @override
  final int height;
  final int gridSize;
  final double dotDiameter;

  @override
  void setup() {
    size(width: width, height: height);
  }

  @override
  Future<void> draw() async {
    background(color: const Color(0xFF111111));

    noStroke();

    double x = gridSize.toDouble();
    double y = gridSize.toDouble();

    while (x < width) {
      while (y < height) {
        final dotNoise = noise(
          x: map(x, 0, width, 0, 500).toDouble(),
          y: map(y, 0, height, 0, 500 * (height / width)).toDouble(),
          z: frameCount.toDouble() / 3,
        );

        if (dotNoise > 0.0) {
          // Adjust the alpha so that dots that are near the boundary,
          // appear translucent, so that movement through the z-coord
          // looks continuous.
          final alpha = (dotNoise * 5).clamp(0.0, 0.4);
          fill(
            color: HSVColor.fromAHSV(alpha, map(x, 0, width, 360, 0).toDouble(), 1.0, 1.0).toColor(),
          );

          // // Adjust the alpha so that dots that are near the boundary,
          // // appear translucent, so that movement through the z-coord
          // // looks continuous.
          // final alpha = (dotNoise * 5).clamp(0.0, 0.2);
          // fill(color: Colors.white.withOpacity(alpha));

          circle(center: Offset(x, y), diameter: dotDiameter);
        }

        y += gridSize;
      }

      x += gridSize;
      y = gridSize.toDouble();
    }
  }
}
