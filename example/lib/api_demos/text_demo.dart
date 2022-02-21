import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class TextSketchDemo extends StatefulWidget {
  const TextSketchDemo({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _TextSketchDemoState createState() => _TextSketchDemoState();
}

class _TextSketchDemoState extends State<TextSketchDemo> {
  @override
  Widget build(BuildContext context) {
    return ProcessingDemo(
      createSketch: createSketch,
      sketchDemoController: widget.sketchDemoController,
    );
  }

  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) async {
        s
          ..size(width: 400, height: 400)
          ..textSize(128)
          ..text("word", 40, 120)
          ..text("word", 40, 240)
          ..text("word", 40, 360);
      },
    );
  }
}
