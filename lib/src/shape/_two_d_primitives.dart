import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter_processing/flutter_processing.dart';

import 'shapes.dart';

mixin SketchShapeTwoDPrimitives on BaseSketch {
  void point({
    required double x,
    required double y,
    double? z,
  }) {
    if (z != null) {
      throw UnimplementedError('3D point drawing is not yet supported.');
    }

    paintingContext.strokePaint.style = PaintingStyle.fill;
    paintingContext.canvas.drawRect(
      Rect.fromLTWH(x, y, 1, 1),
      paintingContext.strokePaint,
    );
    paintingContext.strokePaint.style = PaintingStyle.stroke;

    paintingContext.markHasUnappliedCanvasCommands();
  }

  void line(Offset p1, Offset p2, [Offset? p3]) {
    if (p3 != null) {
      throw UnimplementedError('3D line drawing is not yet supported.');
    }

    paintingContext.canvas.drawLine(p1, p2, paintingContext.strokePaint);

    paintingContext.markHasUnappliedCanvasCommands();
  }

  void circle({
    required Offset center,
    required double diameter,
  }) {
    paintingContext.canvas
      ..drawCircle(center, diameter / 2, paintingContext.fillPaint)
      ..drawCircle(center, diameter / 2, paintingContext.strokePaint);

    paintingContext.markHasUnappliedCanvasCommands();
  }

  void ellipse(Ellipse ellipse) {
    paintingContext.canvas //
      ..drawOval(ellipse.rect, paintingContext.fillPaint) //
      ..drawOval(ellipse.rect, paintingContext.strokePaint);

    paintingContext.markHasUnappliedCanvasCommands();
  }

  void arc({
    required Ellipse ellipse,
    required double startAngle,
    required double endAngle,
    ArcMode mode = ArcMode.openStrokePieFill,
  }) {
    switch (mode) {
      case ArcMode.openStrokePieFill:
        paintingContext.canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, paintingContext.fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, paintingContext.strokePaint);
        break;
      case ArcMode.open:
        paintingContext.canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, paintingContext.fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, paintingContext.strokePaint);
        break;
      case ArcMode.chord:
        final chordPath = Path()
          ..addArc(ellipse.rect, startAngle, endAngle - startAngle)
          ..close();

        paintingContext.canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, paintingContext.fillPaint)
          ..drawPath(chordPath, paintingContext.strokePaint);
        break;
      case ArcMode.pie:
        paintingContext.canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, paintingContext.fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, paintingContext.strokePaint);
        break;
    }

    paintingContext.markHasUnappliedCanvasCommands();
  }

  void square(Square square) {
    paintingContext.canvas //
      ..drawRect(square.rect, paintingContext.fillPaint) //
      ..drawRect(square.rect, paintingContext.strokePaint);

    paintingContext.markHasUnappliedCanvasCommands();
  }

  void rect({
    required Rect rect,
    BorderRadius? borderRadius,
  }) {
    if (borderRadius == null) {
      paintingContext.canvas //
        ..drawRect(rect, paintingContext.fillPaint) //
        ..drawRect(rect, paintingContext.strokePaint);
    } else {
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      );
      paintingContext.canvas //
        ..drawRRect(rrect, paintingContext.fillPaint) //
        ..drawRRect(rrect, paintingContext.strokePaint);
    }

    paintingContext.markHasUnappliedCanvasCommands();
  }

  void triangle(Offset p1, Offset p2, Offset p3) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    paintingContext.canvas //
      ..drawPath(path, paintingContext.fillPaint) //
      ..drawPath(path, paintingContext.strokePaint);

    paintingContext.markHasUnappliedCanvasCommands();
  }

  void quad(Offset p1, Offset p2, Offset p3, Offset p4) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    paintingContext.canvas //
      ..drawPath(path, paintingContext.fillPaint) //
      ..drawPath(path, paintingContext.strokePaint);

    paintingContext.markHasUnappliedCanvasCommands();
  }
}
