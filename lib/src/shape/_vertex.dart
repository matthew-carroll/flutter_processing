part of '../_core.dart';

mixin SketchShapeVertex on BaseSketch {
  _Shape? _shape;

  /// Begins recording a custom shape, defined by various types of vertices.
  ///
  /// Using the `beginShape()` and `endShape()` functions allow creating more
  /// complex forms. `beginShape()` begins recording vertices for a shape and
  /// `endShape()` stops recording. The value of the kind parameter tells it
  /// which types of shapes to create from the provided vertices. With no mode
  /// specified, the shape can be any irregular polygon. The parameters available
  /// for `beginShape()` are `ShapeMode.points`, `ShapeMode.lines`,
  /// `ShapeMode.triangles`, `ShapeMode.triangleFan`, `ShapeMode.triangleStrip`,
  /// `ShapeMode.quads`, and `ShapeMode.quadStrip`. After calling the `beginShape()`
  /// function, a series of `vertex()` commands must follow. To stop drawing the
  /// shape, call `endShape()`. The `vertex()` function with two parameters
  /// specifies a position in 2D and the `vertex()` function with three
  /// parameters specifies a position in 3D. Each shape will be outlined with
  /// the current stroke color and filled with the fill color.
  ///
  /// Transformations such as `translate()`, `rotate()`, and `scale()` do not
  /// work within `beginShape()`. It is also not possible to use other shapes,
  /// such as `ellipse()` or `rect()` within `beginShape()`.
  void beginShape([ShapeMode? mode]) {
    if (_shape != null) {
      throw Exception("A shape is already started. Can't start another one.");
    }

    _shape = _Shape(mode);
  }

  /// Ends the definition of a custom shape and then paints it.
  ///
  /// The `endShape()` function is the companion to `beginShape()` and may
  /// only be called after `beginShape()`. When `endShape()` is called, all
  /// of image data defined since the previous call to `beginShape()` is
  /// written into the image buffer. Pass `true` for [close] to close the
  /// shape (to connect the beginning and the end).
  void endShape({bool close = false}) {
    if (_shape == null) {
      throw Exception("Can't end a shape because a shape was not started.");
    }

    if (_shape!.mode == null) {
      _drawDefault(closeShape: close);
    } else {
      switch (_shape!.mode!) {
        case ShapeMode.points:
          _drawPoints();
          break;
        case ShapeMode.lines:
          _drawLines(closeShape: close);
          break;
        case ShapeMode.triangles:
          _drawTriangles();
          break;
        case ShapeMode.triangleFan:
          _drawTriangleFan();
          break;
        case ShapeMode.triangleStrip:
          _drawTriangleStrip();
          break;
        case ShapeMode.quads:
          _drawQuads();
          break;
        case ShapeMode.quadStrip:
          _drawQuadStrip();
          break;
      }
    }

    _shape = null;
  }

  /// Adds a vertex to the active shape.
  ///
  /// All shapes are constructed by connecting a series of vertices. `vertex()`
  /// is used to specify the vertex coordinates for points, lines, triangles,
  /// quads, and polygons. It is used exclusively within the `beginShape()`
  /// and `endShape()` functions.
  void vertex(num x, num y) {
    if (_shape == null) {
      throw Exception("You need to call beginShape() before calling vertex().");
    }

    _shape!.vertices.add(_PointVertex(x, y));
  }

  void curveVertex(num x, num y) {
    if (_shape == null) {
      throw Exception("You need to call beginShape() before calling curveVertex().");
    }
    if (_shape!.mode != null) {
      throw Exception("You can't add a curve vertex for a custom shape when using a non-default mode: ${_shape!.mode}");
    }

    _shape!.vertices.add(_CurveVertex(x, y));

    throw UnimplementedError("Flutter Processing doesn't know how to draw curve vertices, do you?");
  }

  void bezierVertex(c1x, c1y, c2x, c2y, x2, y2) {
    if (_shape == null) {
      throw Exception("You need to call beginShape() before calling bezierVertex().");
    }
    if (_shape!.mode != null) {
      throw Exception(
          "You can't add a bezier vertex for a custom shape when using a non-default mode: ${_shape!.mode}");
    }

    _shape!.vertices.add(_BezierVertex(c1x, c1y, c2x, c2y, x2, y2));
  }

  void quadraticVertex(cx, cy, x2, y2) {
    if (_shape == null) {
      throw Exception("You need to call beginShape() before calling quadraticVertex().");
    }
    if (_shape!.mode != null) {
      throw Exception(
          "You can't add a quadratic vertex for a custom shape when using a non-default mode: ${_shape!.mode}");
    }

    _shape!.vertices.add(_QuadraticVertex(cx, cy, x2, y2));
  }

  void _drawDefault({required bool closeShape}) {
    final shape = _shape!;
    if (shape.vertices.isEmpty) {
      // Nothing to draw. Return.
      return;
    }

    assert(shape.mode == null);

    if (shape.vertices.first is! _PointVertex) {
      throw Exception("The first vertex in a shape needs to be a point vertex");
    }
    final firstVertex = shape.vertices.first as _PointVertex;

    final path = Path()..moveTo(firstVertex.x.toDouble(), firstVertex.y.toDouble());
    for (int i = 1; i < shape.vertices.length; i += 1) {
      final nextVertex = shape.vertices[i];

      if (nextVertex is _PointVertex) {
        path.lineTo(nextVertex.x.toDouble(), nextVertex.y.toDouble());
      } else if (nextVertex is _BezierVertex) {
        path.cubicTo(
          nextVertex.control1x.toDouble(),
          nextVertex.control1y.toDouble(),
          nextVertex.control2x.toDouble(),
          nextVertex.control2y.toDouble(),
          nextVertex.x2.toDouble(),
          nextVertex.y2.toDouble(),
        );
      } else if (nextVertex is _QuadraticVertex) {
        path.quadraticBezierTo(
          nextVertex.control1x.toDouble(),
          nextVertex.control1y.toDouble(),
          nextVertex.x2.toDouble(),
          nextVertex.y2.toDouble(),
        );
      }
    }

    if (closeShape) {
      path.close();
    }

    _paintingContext.canvas.drawPath(
      path,
      _paintingContext.fillPaint,
    );
    _paintingContext.canvas.drawPath(
      path,
      _paintingContext.strokePaint,
    );
  }

  void _drawPoints() {
    assert(_shape!.mode == ShapeMode.points);
    // It's not clear what it means to draw a shape with POINTS mode.
    // The Processing reference shows a blank canvas when that happens.
    // For now, we'll do nothing.
  }

  void _drawLines({required bool closeShape}) {
    final shape = _shape!;
    if (shape.vertices.isEmpty) {
      // Nothing to draw. Return.
      return;
    }

    assert(shape.mode == ShapeMode.lines);

    if (shape.vertices.length.isOdd) {
      throw Exception(
          "Expected even number of vertices for shape in LINES mode. Found ${shape.vertices.length} vertices.");
    }

    final path = Path();
    for (int i = 0; i < shape.vertices.length; i += 2) {
      final startVertex = shape.vertices[i];
      final endVertex = shape.vertices[i + 1];

      if (startVertex is! _PointVertex) {
        throw Exception("Shapes in LINES mode can only process point vertices");
      }
      if (endVertex is! _PointVertex) {
        throw Exception("Shapes in LINES mode can only process point vertices");
      }

      path
        ..moveTo(startVertex.x.toDouble(), startVertex.y.toDouble())
        ..lineTo(endVertex.x.toDouble(), endVertex.y.toDouble());
    }

    if (closeShape) {
      path.close();
    }

    _paintingContext.canvas.drawPath(
      path,
      _paintingContext.strokePaint,
    );
  }

  void _drawTriangles() {
    final shape = _shape!;
    if (shape.vertices.isEmpty) {
      // Nothing to draw. Return.
      return;
    }

    assert(shape.mode == ShapeMode.triangles);

    if (shape.vertices.length % 3 != 0) {
      throw Exception(
          "Expected vertex count to be a multiple of 3 for shape in TRIANGLES mode. Found ${shape.vertices.length} vertices.");
    }

    for (int i = 0; i < shape.vertices.length; i += 3) {
      final vertex1 = shape.vertices[i];
      if (vertex1 is! _PointVertex) {
        throw Exception("Shapes in TRIANGLES mode can only process point vertices");
      }
      final vertex2 = shape.vertices[i + 1];
      if (vertex2 is! _PointVertex) {
        throw Exception("Shapes in TRIANGLES mode can only process point vertices");
      }
      final vertex3 = shape.vertices[i + 2];
      if (vertex3 is! _PointVertex) {
        throw Exception("Shapes in TRIANGLES mode can only process point vertices");
      }

      final triangle = Path()
        ..moveTo(vertex1.x.toDouble(), vertex1.y.toDouble())
        ..lineTo(vertex2.x.toDouble(), vertex2.y.toDouble())
        ..lineTo(vertex3.x.toDouble(), vertex3.y.toDouble())
        ..close();

      _paintingContext.canvas.drawPath(
        triangle,
        _paintingContext.fillPaint,
      );
      _paintingContext.canvas.drawPath(
        triangle,
        _paintingContext.strokePaint,
      );
    }
  }

  void _drawTriangleStrip() {
    final shape = _shape!;
    if (shape.vertices.isEmpty) {
      // Nothing to draw. Return.
      return;
    }

    assert(shape.mode == ShapeMode.triangleStrip);

    if (shape.vertices.length < 3) {
      throw Exception(
          "Expected 3 or more vertices for shape in TRIANGLE_STRIP mode but found ${shape.vertices.length} vertices.");
    }

    for (final vertex in shape.vertices) {
      if (vertex is! _PointVertex) {
        throw Exception("TRIANGLE_STRIP mode can only work with point vertices");
      }
    }

    final path = Path();
    _PointVertex vertex1 = shape.vertices[0] as _PointVertex;
    _PointVertex vertex2 = shape.vertices[1] as _PointVertex;
    for (int i = 2; i < shape.vertices.length; i += 1) {
      final vertex3 = shape.vertices[i] as _PointVertex;

      path
        ..moveTo(vertex1.x.toDouble(), vertex1.y.toDouble())
        ..lineTo(vertex2.x.toDouble(), vertex2.y.toDouble())
        ..lineTo(vertex3.x.toDouble(), vertex3.y.toDouble())
        ..close();

      vertex1 = vertex2;
      vertex2 = vertex3;
    }

    _paintingContext.canvas.drawPath(
      path,
      _paintingContext.fillPaint,
    );
    _paintingContext.canvas.drawPath(
      path,
      _paintingContext.strokePaint,
    );
  }

  void _drawTriangleFan() {
    final shape = _shape!;
    if (shape.vertices.isEmpty) {
      // Nothing to draw. Return.
      return;
    }

    assert(shape.mode == ShapeMode.triangleFan);

    if (shape.vertices.length < 3) {
      throw Exception(
          "Expected 3 or more vertices for shape in TRIANGLE_FAN mode but found ${shape.vertices.length} vertices.");
    }

    for (final vertex in shape.vertices) {
      if (vertex is! _PointVertex) {
        throw Exception("TRIANGLE_FAN mode can only work with point vertices");
      }
    }

    final path = Path();
    final centerVertex = shape.vertices[0] as _PointVertex;
    _PointVertex vertex1 = shape.vertices[1] as _PointVertex;
    for (int i = 2; i < shape.vertices.length; i += 1) {
      final vertex2 = shape.vertices[i] as _PointVertex;

      path
        ..moveTo(centerVertex.x.toDouble(), centerVertex.y.toDouble())
        ..lineTo(vertex1.x.toDouble(), vertex1.y.toDouble())
        ..lineTo(vertex2.x.toDouble(), vertex2.y.toDouble())
        ..close();

      vertex1 = vertex2;
    }

    _paintingContext.canvas.drawPath(
      path,
      _paintingContext.fillPaint,
    );
    _paintingContext.canvas.drawPath(
      path,
      _paintingContext.strokePaint,
    );
  }

  void _drawQuads() {
    final shape = _shape!;
    if (shape.vertices.isEmpty) {
      // Nothing to draw. Return.
      return;
    }

    assert(shape.mode == ShapeMode.quads);

    if (shape.vertices.length % 4 != 0) {
      throw Exception(
          "Expected vertex count to be a multiple of 4 for shape in QUADS mode. Found ${shape.vertices.length} vertices.");
    }

    for (final vertex in shape.vertices) {
      if (vertex is! _PointVertex) {
        throw Exception("QUADS mode can only work with point vertices");
      }
    }

    for (int i = 0; i < shape.vertices.length; i += 4) {
      final vertex1 = shape.vertices[i] as _PointVertex;
      final vertex2 = shape.vertices[i + 1] as _PointVertex;
      final vertex3 = shape.vertices[i + 2] as _PointVertex;
      final vertex4 = shape.vertices[i + 3] as _PointVertex;

      final quad = Path()
        ..moveTo(vertex1.x.toDouble(), vertex1.y.toDouble())
        ..lineTo(vertex2.x.toDouble(), vertex2.y.toDouble())
        ..lineTo(vertex3.x.toDouble(), vertex3.y.toDouble())
        ..lineTo(vertex4.x.toDouble(), vertex4.y.toDouble())
        ..close();

      _paintingContext.canvas.drawPath(
        quad,
        _paintingContext.fillPaint,
      );
      _paintingContext.canvas.drawPath(
        quad,
        _paintingContext.strokePaint,
      );
    }
  }

  void _drawQuadStrip() {
    final shape = _shape!;
    if (shape.vertices.isEmpty) {
      // Nothing to draw. Return.
      return;
    }

    assert(shape.mode == ShapeMode.quadStrip);

    if (shape.vertices.length < 4) {
      throw Exception(
          "Expected 4 or more vertices for shape in QUAD_STRIP mode but found ${shape.vertices.length} vertices.");
    }

    for (final vertex in shape.vertices) {
      if (vertex is! _PointVertex) {
        throw Exception("QUAD_STRIP mode can only work with point vertices");
      }
    }

    final path = Path();
    _PointVertex vertex1 = shape.vertices[0] as _PointVertex;
    _PointVertex vertex2 = shape.vertices[1] as _PointVertex;
    for (int i = 2; i < shape.vertices.length; i += 2) {
      final vertex3 = shape.vertices[i] as _PointVertex;
      final vertex4 = shape.vertices[i + 1] as _PointVertex;

      path
        ..moveTo(vertex1.x.toDouble(), vertex1.y.toDouble())
        ..lineTo(vertex2.x.toDouble(), vertex2.y.toDouble())
        // Notice the change in vertex order to give us a
        // a rectangle, rather than a weird criss-cross double triangle
        ..lineTo(vertex4.x.toDouble(), vertex4.y.toDouble())
        ..lineTo(vertex3.x.toDouble(), vertex3.y.toDouble())
        ..close();

      vertex1 = vertex3;
      vertex2 = vertex4;
    }

    _paintingContext.canvas.drawPath(
      path,
      _paintingContext.fillPaint,
    );
    _paintingContext.canvas.drawPath(
      path,
      _paintingContext.strokePaint,
    );
  }
}

/// The way to interpret the vertices in a shape that's
/// defined between `beginShape()` and `endShape()`.
///
/// The default mode (when no mode is specified) paints
/// lines/curves with a fill.
enum ShapeMode {
  /// Paints each vertex as a point, without any lines
  /// or curves between them.
  points,

  /// Paints lines between each vertex without any fill.
  lines,

  /// Paints each series of 3 vertices as independent triangles
  /// with lines and fills.
  triangles,

  // TODO: document this
  triangleFan,

  /// Paints a connected strip of triangles.
  ///
  /// The first 3 vertices define the first triangle. Every 2 vertices
  /// after that define additional triangles in the strip.
  triangleStrip,

  /// Paints each series of 4 vertices as independent quads
  /// with lines and fills.
  quads,

  /// Paints a connected strip of quads.
  ///
  /// The first 4 vertices define the first quad. Every 2 vertices
  /// after that define additional quads in the strip.
  quadStrip,
}

class _Shape {
  _Shape(this.mode);

  final ShapeMode? mode;

  final vertices = <_Vertex>[];
}

/// Marker interface for all types of vertices.
abstract class _Vertex {
  const _Vertex();
}

/// Vertex for a point or end of a line.
class _PointVertex extends _Vertex {
  const _PointVertex(this.x, this.y);

  final num x;
  final num y;
}

/// Specifies vertex coordinates for curves.
///
/// The first and last points in a series of curveVertex() lines
/// will be used to guide the beginning and end of a the curve.
/// A minimum of four points is required to draw a tiny curve
/// between the second and third points. Adding a fifth point
/// with curveVertex() will draw the curve between the second,
/// third, and fourth points. The curveVertex() function is an
/// implementation of Catmull-Rom splines.
class _CurveVertex extends _PointVertex {
  const _CurveVertex(num x, num y) : super(x, y);
}

/// Specifies vertex coordinates for Bezier curves.
///
/// Each call to bezierVertex() defines the position of two
/// control points and one anchor point of a Bezier curve,
/// adding a new segment to a line or shape.
class _BezierVertex extends _Vertex {
  const _BezierVertex(
    this.control1x,
    this.control1y,
    this.control2x,
    this.control2y,
    this.x2,
    this.y2,
  );

  final num control1x;
  final num control1y;

  final num control2x;
  final num control2y;

  final num x2;
  final num y2;
}

/// Specifies vertex coordinates for quadratic Bezier curves.
class _QuadraticVertex extends _Vertex {
  const _QuadraticVertex(
    this.control1x,
    this.control1y,
    this.x2,
    this.y2,
  );

  final num control1x;
  final num control1y;

  final num x2;
  final num y2;
}
