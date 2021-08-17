part of '../_core.dart';

mixin SketchShapeAttributes on BaseSketch {
  void strokeWeight(double newWeight) {
    if (newWeight < 0) {
      throw Exception('Stroke weight must be >= 0');
    }

    _paintingContext.strokePaint.strokeWidth = newWeight.toDouble();
  }
}
