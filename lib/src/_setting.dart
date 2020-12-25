import 'package:flutter/material.dart';
import 'package:flutter_processing/src/_core.dart';

mixin SketchSetting on Sketch {
  void stroke(Color color) {
    paintingContext.strokePaint.color = color;
  }
}
