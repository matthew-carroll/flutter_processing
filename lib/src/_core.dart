import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_processing/src/_color.dart';
import 'package:flutter_processing/src/_constants.dart';
import 'package:flutter_processing/src/_two_d_primitives.dart';

class Processing extends LeafRenderObjectWidget {
  Processing({
    this.sketch,
  });

  final Sketch sketch;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderProcessing(sketch: sketch);
  }

  @override
  void updateRenderObject(BuildContext context, RenderProcessing renderObject) {
    renderObject.sketch = sketch;
  }
}

class RenderProcessing extends RenderBox {
  RenderProcessing({
    Sketch sketch,
  }) : _sketch = sketch;

  Sketch _sketch;
  set sketch(Sketch newSketch) {
    if (_sketch != newSketch) {
      _sketch = newSketch;
      markNeedsPaint();
    }
  }

  Paint _defaultBackgroundPaint = Paint()..color = const Color(0xFFCCCCCC);

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    if (_sketch != null) {
      final sketchPaintingContext = SketchPaintingContext(
        size: size,
        canvas: context.canvas,
      );
      _sketch.paintingContext = sketchPaintingContext;

      // Paint the default background color.
      context.canvas.drawRect(Offset.zero & size, _defaultBackgroundPaint);

      _sketch.draw();

      _sketch.paintingContext = null;
    }

    canvas.restore();
  }
}

/// Functional version of a `Sketch` for easy construction of simple sketches.
///
/// Simple sketches, such as those used for most tests and examples, do not
/// require local variables. In such situations, a sketch can be reduced to
/// a "setup" function + a "draw" function. This builder facilitates this
/// use-case, allowing clients to avoid the verbosity of a subclass.
class SketchBuilder extends Sketch {
  SketchBuilder({
    Future<void> Function(Sketch) setup,
    void Function(Sketch) draw,
  })  : _setup = setup,
        _draw = draw;

  final Future<void> Function(Sketch sketch) _setup;
  final void Function(Sketch sketch) _draw;

  @override
  Future<void> setup() async {
    if (_setup != null) {
      return _setup.call(this);
    }
  }

  @override
  void draw() {
    _draw?.call(this);
  }
}

abstract class SketchContext {
  /// All tools needed to paint a Flutter UI with Processing APIs.
  ///
  /// The `paintingContext` is configured by Flutter integration code. It's
  /// then used by the implementation of the Processing APIs to orchestrate
  /// expected Processing behavior.
  ///
  /// The `paintingContext` should never be set or altered by an implementing
  /// `Sketch`. Instead, it should be considered private to the
  /// flutter_processing package for internal orchestration.
  SketchPaintingContext paintingContext;
}

abstract class Sketch extends SketchContext
    with SketchConstants, SketchColor, Sketch2DPrimitives {
  /// The setup() function is run once, when the program starts. It's used
  /// to define initial environment properties such as screen size and to
  /// load media such as images and fonts as the program starts.
  Future<void> setup() async {}

  /// Called directly after setup(), the draw() function continuously executes
  /// the lines of code contained inside its block until the program is stopped
  /// or noLoop() is called. draw() is called automatically and should never be
  /// called explicitly. All Processing programs update the screen at the end of
  /// draw(), never earlier.
  ///
  /// To stop the code inside of draw() from running continuously, use noLoop(),
  /// redraw() and loop(). If noLoop() is used to stop the code in draw() from
  /// running, then redraw() will cause the code inside draw() to run a single
  /// time, and loop() will cause the code inside draw() to resume running
  /// continuously.
  ///
  /// The number of times draw() executes in each second may be controlled with
  /// the frameRate() function.
  ///
  /// It is common to call background() near the beginning of the draw() loop to
  /// clear the contents of the window, as shown in the first example above.
  /// Since pixels drawn to the window are cumulative, omitting background()
  /// may result in unintended results.
  void draw() {}
}

class SketchPaintingContext {
  SketchPaintingContext({
    @required Size size,
    @required Canvas canvas,
  })  : _size = size,
        _canvas = canvas {
    _strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1;
    _fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
  }

  Size get size => _size;
  Size _size;

  Canvas get canvas => _canvas;
  Canvas _canvas;

  get strokePaint => _strokePaint;
  Paint _strokePaint;

  get fillPaint => _fillPaint;
  Paint _fillPaint;
}
