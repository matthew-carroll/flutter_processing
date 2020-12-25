import 'package:flutter/material.dart';
import 'package:flutter_processing/src/_core.dart';

mixin SketchColor on SketchContext {
  /// Fills the available space with the given 'color' or 'image'.
  ///
  /// Invoking this method after painting other content results in that
  /// content being covered by the given background 'color' or 'image'.
  // TODO: add other background options, like an image
  void background({Color color}) {
    paintingContext.canvas.drawRect(
      Offset.zero & paintingContext.size,
      Paint()..color = color,
    );
  }

  /// Configures future painting operations to use the given fill 'color'.
  void fill(color) {
    paintingContext.fillPaint.color = color;
  }

  /// Prevents later painting calls from painting a fill.
  void noFill() {
    paintingContext.fillPaint.color = Colors.transparent;
  }

  void stroke(Color color) {
    paintingContext.strokePaint.color = color;
  }

  void noStroke() {
    paintingContext.strokePaint.color = Colors.transparent;
  }
}
