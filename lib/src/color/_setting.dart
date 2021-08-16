part of '../_core.dart';

mixin SketchColorSetting on BaseSketch {
  Color _backgroundColor = const Color(0xFFC5C5C5);

  void background({
    required Color color,
  }) {
    _backgroundColor = color;

    final paint = Paint()..color = color;
    _paintingContext.canvas.drawRect(Offset.zero & _paintingContext.size, paint);

    _paintingContext.markHasUnappliedCanvasCommands();
  }

  void fill({
    required Color color,
  }) {
    _paintingContext.fillPaint.color = color;
  }

  void noFill() {
    _paintingContext.fillPaint.color = const Color(0x00000000);
  }

  void stroke({
    required Color color,
  }) {
    _paintingContext.strokePaint.color = color;
  }

  void noStroke() {
    _paintingContext.strokePaint.color = const Color(0x00000000);
  }
}
