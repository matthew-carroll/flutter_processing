import 'package:flutter/widgets.dart';

class Processing extends StatelessWidget {
  const Processing({
    Key key,
    @required this.sketch,
  }) : super(key: key);

  final Sketch sketch;

  @override
  Widget build(BuildContext context) {
    // TODO: implement animation frames, keyboard input, mouse input
    return CustomPaint(
      size: Size.infinite,
      painter: _SketchPainter(
        sketch: sketch,
      ),
    );
  }
}

abstract class Sketch {
  // TODO: find a way to allow for sketch implementations to avoid
  //       subclassing Sketch.
  void setup() {}

  void draw() {}

  Canvas canvas;
  Size size;

  void background({
    @required Color color,
  }) {
    assert(canvas != null);
    assert(size != null);

    final paint = Paint()..color = color;
    canvas.drawRect(Offset.zero & size, paint);
  }

  // TODO: implement all other Processing APIs
}

class _SketchPainter extends CustomPainter {
  _SketchPainter({
    @required this.sketch,
  }) : assert(sketch != null);

  final Sketch sketch;

  @override
  void paint(Canvas canvas, Size size) {
    sketch
      ..canvas = canvas
      ..size = size
      ..setup()
      ..draw();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
