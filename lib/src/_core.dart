import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class Processing extends StatefulWidget {
  const Processing({
    Key? key,
    required this.sketch,
  }) : super(key: key);

  final Sketch sketch;

  @override
  _ProcessingState createState() => _ProcessingState();
}

class _ProcessingState extends State<Processing> with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(Processing oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.sketch != oldWidget.sketch) {
      _ticker
        ..stop()
        ..start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(elapsedTime) {
    setState(() {
      widget.sketch._updateElapsedTime(elapsedTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement keyboard input, mouse input
    return CustomPaint(
      size: Size.infinite,
      painter: _SketchPainter(
        sketch: widget.sketch,
      ),
    );
  }
}

class Sketch {
  Sketch.simple({
    void Function(Sketch)? setup,
    void Function(Sketch)? draw,
  })  : _setup = setup,
        _draw = draw;

  Sketch();

  void Function(Sketch)? _setup;
  void Function(Sketch)? _draw;

  bool _hasDoneSetup = false;

  void _doSetup() {
    if (_hasDoneSetup) {
      return;
    }
    _hasDoneSetup = true;

    // By default fill the background with a light grey.
    background(color: _backgroundColor);

    // By default, the fill color is white and the stroke is 1px black.
    _fillPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    _strokePaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    setup();
  }

  void setup() {
    _setup?.call(this);
  }

  void _onDraw() {
    background(color: _backgroundColor);

    if (_lastDrawTime != null) {
      if (_elapsedTime - _lastDrawTime! < _desiredFrameTime) {
        return;
      }
    }

    draw();

    _frameCount += 1;
    _lastDrawTime = _elapsedTime;

    final secondsFraction = _elapsedTime.inMilliseconds / 1000.0;
    _actualFrameRate = secondsFraction > 0 ? (_frameCount / secondsFraction).round() : _actualFrameRate;
  }

  void draw() {
    _draw?.call(this);
  }

  late Canvas canvas;
  late Size size;
  late Paint _fillPaint;
  late Paint _strokePaint;
  Color _backgroundColor = const Color(0xFFC5C5C5);

  //------ Start Environment -----
  Duration _elapsedTime = Duration.zero;
  void _updateElapsedTime(Duration newElapsedTime) => _elapsedTime = newElapsedTime;

  Duration? _lastDrawTime;

  int _frameCount = 0;
  int get frameCount => _frameCount;

  int _actualFrameRate = 10;
  int get frameRate => _actualFrameRate;

  Duration _desiredFrameTime = Duration(milliseconds: (1000.0 / 60).floor());
  set frameRate(int frameRate) {
    print('WARNING: non-natural frame rates are very buggy at this time');

    _desiredFrameTime = Duration(milliseconds: (1000.0 / frameRate).floor());
  }

  //------ Start Random -----
  Random _random = Random();

  /// Sets the seed value for all [random()] invocations to the given
  /// [seed].
  ///
  /// To return to a natural seed value, pass [null] for [seed].
  void randomSeed(int? seed) {
    _random = Random(seed);
  }

  double random(num bound1, [num? bound2]) {
    final lowerBound = bound2 != null ? bound1 : 0;
    final upperBound = bound2 != null ? bound2 : bound1;

    if (upperBound < lowerBound) {
      throw Exception('random() lower bound must be less than upper bound');
    }

    return _random.nextDouble() * (upperBound - lowerBound) + lowerBound;
  }

  //------ Start Color/Setting -----
  void background({
    required Color color,
  }) {
    final paint = Paint()..color = color;
    canvas.drawRect(Offset.zero & size, paint);
  }

  void fill({
    required Color color,
  }) {
    _fillPaint.color = color;
  }

  void noFill() {
    _fillPaint.color = const Color(0x00000000);
  }

  void stroke({
    required Color color,
  }) {
    _strokePaint.color = color;
  }

  void noStroke() {
    _strokePaint.color = const Color(0x00000000);
  }
  //------- End Color/Setting -----

  //----- Start Shape/2D Primitives ----
  void point({
    required double x,
    required double y,
    double? z,
  }) {
    if (z != null) {
      throw UnimplementedError('3D point drawing is not yet supported.');
    }

    _strokePaint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(x, y, 1, 1),
      _strokePaint,
    );
    _strokePaint.style = PaintingStyle.stroke;
  }

  void line(Offset p1, Offset p2, [Offset? p3]) {
    if (p3 != null) {
      throw UnimplementedError('3D line drawing is not yet supported.');
    }

    canvas.drawLine(p1, p2, _strokePaint);
  }

  void circle({
    required Offset center,
    required double diameter,
  }) {
    canvas..drawCircle(center, diameter / 2, _fillPaint)..drawCircle(center, diameter / 2, _strokePaint);
  }

  void ellipse(Ellipse ellipse) {
    canvas //
      ..drawOval(ellipse.rect, _fillPaint) //
      ..drawOval(ellipse.rect, _strokePaint);
  }

  void arc({
    required Ellipse ellipse,
    required double startAngle,
    required double endAngle,
    ArcMode mode = ArcMode.openStrokePieFill,
  }) {
    switch (mode) {
      case ArcMode.openStrokePieFill:
        canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, _fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _strokePaint);
        break;
      case ArcMode.open:
        canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _strokePaint);
        break;
      case ArcMode.chord:
        final chordPath = Path()
          ..addArc(ellipse.rect, startAngle, endAngle - startAngle)
          ..close();

        canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _fillPaint)
          ..drawPath(chordPath, _strokePaint);
        break;
      case ArcMode.pie:
        canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, _fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, _strokePaint);
        break;
    }
  }

  void square(Square square) {
    canvas //
      ..drawRect(square.rect, _fillPaint) //
      ..drawRect(square.rect, _strokePaint);
  }

  void rect({
    required Rect rect,
    BorderRadius? borderRadius,
  }) {
    if (borderRadius == null) {
      canvas //
        ..drawRect(rect, _fillPaint) //
        ..drawRect(rect, _strokePaint);
    } else {
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      );
      canvas //
        ..drawRRect(rrect, _fillPaint) //
        ..drawRRect(rrect, _strokePaint);
    }
  }

  void triangle(Offset p1, Offset p2, Offset p3) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    canvas //
      ..drawPath(path, _fillPaint) //
      ..drawPath(path, _strokePaint);
  }

  void quad(Offset p1, Offset p2, Offset p3, Offset p4) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    canvas //
      ..drawPath(path, _fillPaint) //
      ..drawPath(path, _strokePaint);
  }
  //------- End Shape/2D Primitives -----

  // TODO: implement all other Processing APIs
}

class Square {
  Square.fromLTE(Offset topLeft, double extent)
      : _rect = Rect.fromLTWH(
          topLeft.dx,
          topLeft.dy,
          extent,
          extent,
        );

  Square.fromCenter(Offset center, double extent)
      : _rect = Rect.fromCenter(
          center: center,
          width: extent,
          height: extent,
        );

  final Rect _rect;
  Rect get rect => _rect;
}

class Ellipse {
  Ellipse.fromLTWH({
    required Offset topLeft,
    required double width,
    required double height,
  }) : _rect = Rect.fromLTWH(
          topLeft.dx,
          topLeft.dy,
          width,
          height,
        );

  Ellipse.fromLTRB({
    required Offset topLeft,
    required Offset bottomRight,
  }) : _rect = Rect.fromLTRB(
          topLeft.dx,
          topLeft.dy,
          bottomRight.dx,
          bottomRight.dy,
        );

  Ellipse.fromCenter({
    required Offset center,
    required double width,
    required double height,
  }) : _rect = Rect.fromCenter(
          center: center,
          width: width,
          height: height,
        );

  Ellipse.fromCenterWithRadius({
    required Offset center,
    required double radius1,
    required double radius2,
  }) : _rect = Rect.fromCenter(
          center: center,
          width: radius1 * 2,
          height: radius2 * 2,
        );

  final Rect _rect;
  Rect get rect => _rect;
}

enum ArcMode {
  openStrokePieFill,
  open,
  chord,
  pie,
}

class _SketchPainter extends CustomPainter {
  _SketchPainter({
    required this.sketch,
  });

  final Sketch sketch;

  @override
  void paint(Canvas canvas, Size size) {
    sketch
      ..canvas = canvas
      ..size = size
      .._doSetup()
      .._onDraw();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
