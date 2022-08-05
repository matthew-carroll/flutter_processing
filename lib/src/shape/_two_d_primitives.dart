part of '../_core.dart';

mixin SketchShapeTwoDPrimitives on BaseSketch {
  void point({
    required double x,
    required double y,
    double? z,
  }) {
    if (z != null) {
      throw UnimplementedError('3D point drawing is not yet supported.');
    }

    _paintingContext.strokePaint.style = PaintingStyle.fill;
    _paintingContext.canvas.drawRect(
      Rect.fromLTWH(x, y, 1, 1),
      _paintingContext.strokePaint,
    );
    _paintingContext.strokePaint.style = PaintingStyle.stroke;
  }

  void line(Offset p1, Offset p2, [Offset? p3]) {
    if (p3 != null) {
      throw UnimplementedError('3D line drawing is not yet supported.');
    }

    _paintingContext.canvas.drawLine(p1, p2, _paintingContext.strokePaint);
  }

  void circle({
    required Offset center,
    required double diameter,
  }) {
    if (_paintingContext.strokePaint.color.alpha > 0) {
      _paintingContext.canvas.drawCircle(center, diameter / 2, _paintingContext.strokePaint);
    }
    _paintingContext.canvas.drawCircle(center, diameter / 2, _paintingContext.fillPaint);
  }

  void ellipse(Ellipse ellipse) {
    _paintingContext.canvas //
      ..drawOval(ellipse.rect, _paintingContext.fillPaint) //
      ..drawOval(ellipse.rect, _paintingContext.strokePaint);
  }

  void arc({
    required Ellipse ellipse,
    required double startAngle,
    required double endAngle,
    ArcMode mode = ArcMode.openStrokePieFill,
  }) {
    switch (mode) {
      case ArcMode.openStrokePieFill:
        _paintingContext.canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, _paintingContext.fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _paintingContext.strokePaint);
        break;
      case ArcMode.open:
        _paintingContext.canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _paintingContext.fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _paintingContext.strokePaint);
        break;
      case ArcMode.chord:
        final chordPath = Path()
          ..addArc(ellipse.rect, startAngle, endAngle - startAngle)
          ..close();

        _paintingContext.canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _paintingContext.fillPaint)
          ..drawPath(chordPath, _paintingContext.strokePaint);
        break;
      case ArcMode.pie:
        _paintingContext.canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, _paintingContext.fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, _paintingContext.strokePaint);
        break;
    }
  }

  void square(Square square) {
    _paintingContext.canvas //
      ..drawRect(square.rect, _paintingContext.fillPaint) //
      ..drawRect(square.rect, _paintingContext.strokePaint);
  }

  void rect({
    required Rect rect,
    BorderRadius? borderRadius,
  }) {
    if (borderRadius == null) {
      _paintingContext.canvas //
        ..drawRect(rect, _paintingContext.fillPaint) //
        ..drawRect(rect, _paintingContext.strokePaint);
    } else {
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      );
      _paintingContext.canvas //
        ..drawRRect(rrect, _paintingContext.fillPaint) //
        ..drawRRect(rrect, _paintingContext.strokePaint);
    }
  }

  void triangle(Offset p1, Offset p2, Offset p3) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    _paintingContext.canvas //
      ..drawPath(path, _paintingContext.fillPaint) //
      ..drawPath(path, _paintingContext.strokePaint);
  }

  void quad(Offset p1, Offset p2, Offset p3, Offset p4) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    _paintingContext.canvas //
      ..drawPath(path, _paintingContext.fillPaint) //
      ..drawPath(path, _paintingContext.strokePaint);
  }
}
