import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

/// An empty sketch demo where developers can experiment with Flutter Processing.
class EmptySketchDemo extends StatefulWidget {
  const EmptySketchDemo({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _EmptySketchDemoState createState() => _EmptySketchDemoState();
}

class _EmptySketchDemoState extends State<EmptySketchDemo> {
  @override
  Widget build(BuildContext context) {
    return ProcessingDemo(
      createSketch: createSketch,
      sketchDemoController: widget.sketchDemoController,
    );
  }

  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) {
        s.size(width: 500, height: 500);
        s.background(color: Colors.white);
        s.noLoop();
      },
    );
  }
}
