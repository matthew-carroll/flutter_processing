import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class CodingTrainRandomWalkerScreen extends StatefulWidget {
  const CodingTrainRandomWalkerScreen({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _CodingTrainRandomWalkerScreenState createState() => _CodingTrainRandomWalkerScreenState();
}

class _CodingTrainRandomWalkerScreenState extends State<CodingTrainRandomWalkerScreen> {
  late int x;
  late int y;

  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) {
        s
          ..size(width: 400, height: 400)
          ..background(color: const Color(0xFF444444));

        x = (s.width / 2).round();
        y = (s.height / 2).round();
      },
      draw: (s) {
        s
          ..noStroke()
          ..fill(color: Colors.black)
          ..circle(center: Offset(x.toDouble(), y.toDouble()), diameter: 4);

        final randomDirection = Random().nextInt(4);
        switch (randomDirection) {
          case 0:
            x += 1;
            break;
          case 1:
            x -= 1;
            break;
          case 2:
            y += 1;
            break;
          case 3:
            y -= 1;
            break;
        }
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
