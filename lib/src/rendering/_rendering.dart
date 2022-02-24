part of '../_core.dart';

mixin SketchRendering on BaseSketch {
  set blendMode(BlendMode blendMode) {
    _paintingContext.fillPaint.blendMode = blendMode;
  }
}
