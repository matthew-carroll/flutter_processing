import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_processing/flutter_processing.dart';

mixin Sketch2DPrimitives on SketchContext {
  void arc({
    double x,
    double y,
    double width,
    double height,
    double startAngleInRadians,
    double endAngleInRadians,
    ArcMode arcMode,
  }) {
    final sweepAngle = endAngleInRadians - startAngleInRadians;

    switch (arcMode) {
      case ArcMode.open:
        // Fill the arc, connecting from end to end.
        final center = Offset(x, y);
        final path = Path()
          ..addArc(
            Rect.fromCenter(center: center, width: width, height: height),
            startAngleInRadians,
            sweepAngle,
          )
          ..close();
        paintingContext.canvas.drawPath(path, paintingContext.fillPaint);

        // Stroke the arc.
        paintingContext.canvas.drawArc(
          Rect.fromCenter(center: Offset(x, y), width: width, height: height),
          startAngleInRadians,
          sweepAngle,
          false,
          paintingContext.strokePaint,
        );

        break;
      case ArcMode.chord:
        // Fill the arc, connecting from end to end.
        final center = Offset(x, y);
        final path = Path()
          ..addArc(
            Rect.fromCenter(center: center, width: width, height: height),
            startAngleInRadians,
            sweepAngle,
          )
          ..close();
        paintingContext.canvas.drawPath(path, paintingContext.fillPaint);

        // Stroke the arc, connecting from end to end.
        paintingContext.canvas.drawPath(path, paintingContext.strokePaint);

        break;
      case ArcMode.pie:
        // Fill the arc and connect back to the center.
        paintingContext.canvas.drawArc(
          Rect.fromCenter(center: Offset(x, y), width: width, height: height),
          startAngleInRadians,
          sweepAngle,
          true,
          paintingContext.fillPaint,
        );

        // Stroke the arc and connect back to the center.
        paintingContext.canvas.drawArc(
          Rect.fromCenter(center: Offset(x, y), width: width, height: height),
          startAngleInRadians,
          sweepAngle,
          true,
          paintingContext.strokePaint,
        );
        break;
      default:
        // Fill the arc, connecting back to the center of the oval.
        paintingContext.canvas.drawArc(
          Rect.fromCenter(center: Offset(x, y), width: width, height: height),
          startAngleInRadians,
          sweepAngle,
          true,
          paintingContext.fillPaint,
        );

        // Stroke the arc, only.
        paintingContext.canvas.drawArc(
          Rect.fromCenter(center: Offset(x, y), width: width, height: height),
          startAngleInRadians,
          sweepAngle,
          false,
          paintingContext.strokePaint,
        );

        break;
    }
  }

  void circle({
    Offset center,
    double diameter,
  }) {
    ellipse(
      center: center,
      width: diameter,
      height: diameter,
    );
  }

  void ellipse({
    Offset center,
    double width,
    double height,
  }) {
    final rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    paintingContext.canvas
      ..drawOval(rect, paintingContext.fillPaint)
      ..drawOval(rect, paintingContext.strokePaint);
  }

  void line({
    double fromX,
    double fromY,
    double fromZ,
    double toX,
    double toY,
    double toZ,
  }) {
    paintingContext.canvas.drawLine(
      Offset(fromX, fromY),
      Offset(toX, toY),
      paintingContext.strokePaint,
    );
    // TODO: z-value
  }

  void point({
    double x,
    double y,
    double z,
  }) {
    circle(center: Offset(x, y), diameter: 0.5);
    // TODO: z-value
  }

  void quad({
    Offset p1,
    Offset p2,
    Offset p3,
    Offset p4,
  }) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    paintingContext.canvas
      ..drawPath(path, paintingContext.fillPaint)
      ..drawPath(path, paintingContext.strokePaint);
  }

  void rect({
    double left,
    double top,
    double width,
    double height,
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    paintingContext.canvas
      ..drawRRect(
        borderRadius.toRRect(Rect.fromLTWH(left, top, width, height)),
        paintingContext.fillPaint,
      )
      ..drawRRect(
        borderRadius.toRRect(Rect.fromLTWH(left, top, width, height)),
        paintingContext.strokePaint,
      );
  }

  void square({
    double left,
    double top,
    double size,
  }) {
    rect(left: left, top: top, width: size, height: size);
  }

  void triangle({
    Offset p1,
    Offset p2,
    Offset p3,
  }) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    paintingContext.canvas
      ..drawPath(path, paintingContext.fillPaint)
      ..drawPath(path, paintingContext.strokePaint);
  }
}

enum ArcMode {
  // Strokes the arc only.
  open,
  // Draws a line between the ends of the arc and fills the shape.
  chord,
  // Strokes the arc and then strokes lines back to the center, like a
  // piece of pie.
  pie,
}
