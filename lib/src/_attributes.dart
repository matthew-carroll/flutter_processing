import 'package:flutter/material.dart';
import 'package:flutter_processing/src/_core.dart';

mixin SketchAttributes on Sketch {
  void ellipseMode() {
    // TODO:
  }

  void rectMode() {
    // TODO:
  }

  void strokeWeight(double weight) {
    paintingContext.strokePaint.strokeWidth = weight;
  }

  void strokeJoin(StrokeJoin join) {
    paintingContext.strokePaint.strokeJoin = join;
  }

  void strokeCap(StrokeCap cap) {
    paintingContext.strokePaint.strokeCap = cap;
  }
}
