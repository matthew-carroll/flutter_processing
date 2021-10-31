import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

class PhyllotaxisSketch extends Sketch {
  final _dotRadius = 3;
  final _dotDistanceMultiplier = 6;
  int _n = 0;

  @override
  void setup() {
    size(width: 400, height: 400);
  }

  @override
  void draw() {
    background(color: Colors.black);

    translate(x: width / 2, y: height / 2);

    final baseAngle = _n * 0.3;
    for (int i = 0; i < _n; i += 1) {
      final angle = i * (137.5 / 360) * (2 * pi) + baseAngle;
      final radius = _dotDistanceMultiplier * sqrt(i);
      final x = radius * cos(angle);
      final y = radius * sin(angle);
      final hue = (i / 3) % 360;

      fill(color: HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor());
      noStroke();
      circle(center: Offset(x, y), diameter: _dotRadius * 2);
    }

    _n += 5;
    _n.clamp(0, 2000);
  }
}
