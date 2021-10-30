part of '../_core.dart';

mixin SketchTransform on BaseSketch {
  void pushMatrix() {
    _paintingContext.canvas.save();
  }

  void popMatrix() {
    _paintingContext.canvas.restore();
  }

  void translate({
    num? x,
    num? y,
    num? z,
  }) {
    if (z != null) {
      throw UnimplementedError('3D translations are not yet supported.');
    }

    _paintingContext.canvas.translate(x?.toDouble() ?? 0, y?.toDouble() ?? 0);

    _paintingContext.markHasUnappliedCanvasCommands();
  }

  void rotate(double angleInRadians) {
    _paintingContext.canvas.rotate(angleInRadians);
    _paintingContext.markHasUnappliedCanvasCommands();
  }
}
