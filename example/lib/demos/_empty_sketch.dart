import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

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
  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) {
        s.size(width: 500, height: 500);
        s.background(color: const Color(0xFFFFFFFF));
        // TODO: add your setup code here
      },
      draw: (s) {
        // TODO: add your draw code here
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProcessingDemo(
      createSketch: createSketch,
      sketchDemoController: widget.sketchDemoController,
    );
  }
}
