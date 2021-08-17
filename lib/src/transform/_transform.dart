part of '../_core.dart';

mixin SketchTransform on BaseSketch {
  void translate({
    double? x,
    double? y,
    double? z,
  }) {
    if (z != null) {
      throw UnimplementedError('3D translations are not yet supported.');
    }

    _paintingContext.canvas.translate(x ?? 0, y ?? 0);

    _paintingContext.markHasUnappliedCanvasCommands();
  }

  void rotate(double angleInRadians) {
    _paintingContext.canvas.rotate(angleInRadians);
    _paintingContext.markHasUnappliedCanvasCommands();
  }
}
