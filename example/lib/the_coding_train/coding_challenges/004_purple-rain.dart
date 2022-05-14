import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class CodingTrainPurpleRainScreen extends StatefulWidget {
  const CodingTrainPurpleRainScreen({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _CodingTrainPurpleRainScreenState createState() => _CodingTrainPurpleRainScreenState();
}

class _CodingTrainPurpleRainScreenState extends State<CodingTrainPurpleRainScreen> {
  final _droplets = <Droplet>[];

  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) {
        s
          ..size(width: 256, height: 256)
          ..background(color: const Color.fromARGB(255, 200, 175, 220));

        for (int i = 0; i < 100; ++i) {
          _droplets.add(
            Droplet(
              x: s.random(s.width),
              y: s.random(-s.height, 0),
              z: s.random(1),
              length: 20,
            ),
          );
        }
      },
      draw: (s) {
        s.background(color: const Color.fromARGB(255, 200, 175, 220));

        for (final droplet in _droplets) {
          droplet
            ..fall(s)
            ..show(s);
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

class Droplet {
  Droplet({
    required this.x,
    required this.y,
    required this.z,
    required this.length,
  });

  double x;
  double y;
  double z;
  double length;

  void fall(Sketch s) {
    y += lerpDouble(8, 20, z)!;

    if (y > s.height) {
      y = 0;
      z = s.random(1);
    }
  }

  void show(Sketch s) {
    final perspectiveLength = lerpDouble(0.2 * length, length, z)!;

    s
      ..stroke(color: const Color.fromARGB(255, 128, 43, 226))
      ..line(Offset(x, y), Offset(x, y + perspectiveLength));
  }
}
