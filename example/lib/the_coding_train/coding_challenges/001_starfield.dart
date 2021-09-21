import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

import '../../_processing_demo_sketch_display.dart';

class CodingTrainStarfieldScreen extends StatefulWidget {
  const CodingTrainStarfieldScreen({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _CodingTrainStarfieldScreenState createState() => _CodingTrainStarfieldScreenState();
}

class _CodingTrainStarfieldScreenState extends State<CodingTrainStarfieldScreen> {
  final _stars = <Star>[];

  Sketch createSketch() {
    return Sketch.simple(
      setup: (s) async {
        s
          ..size(width: 512, height: 256)
          ..background(color: Colors.black);

        for (int i = 0; i < 100; ++i) {
          _stars.add(
            Star(
              x: s.random(-s.width / 2, s.width / 2),
              y: s.random(-s.height / 2, s.height / 2),
              z: s.random(s.width),
            ),
          );
        }
      },
      draw: (s) async {
        s.background(color: Colors.black);

        for (final star in _stars) {
          star.update(s);
        }

        for (final star in _stars) {
          star.paintStreak(s);
        }

        for (final star in _stars) {
          star.paintStar(s);
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

class Star {
  Star({
    required this.x,
    required this.y,
    required this.z,
  }) : originalZ = 0 {
    originalZ = z;
  }

  double x;
  double y;
  double z;
  double originalZ;

  void update(Sketch s) {
    z -= 30;
    originalZ -= 10;

    if (z <= 0) {
      x = s.random(-s.width / 2, s.width / 2);
      y = s.random(-s.height / 2, s.height / 2);
      z = s.random(s.width);
      originalZ = z;
    }
  }

  void paintStreak(Sketch s) {
    final center = Offset(s.width / 2, s.height / 2);

    final perspectiveOrigin = Offset(
      lerpDouble(0, s.width, x / originalZ)!,
      lerpDouble(0, s.height, y / originalZ)!,
    );
    final perspectivePosition = Offset(
      lerpDouble(0, s.width, x / z)!,
      lerpDouble(0, s.height, y / z)!,
    );

    s
      ..stroke(color: Colors.white.withOpacity(0.3))
      ..line(perspectiveOrigin + center, perspectivePosition + center);
  }

  void paintStar(Sketch s) {
    final center = Offset(s.width / 2, s.height / 2);

    final perspectiveOffset = Offset(
      lerpDouble(0, s.width, x / z)!,
      lerpDouble(0, s.height, y / z)!,
    );
    final diameter = lerpDouble(4, 0, z / s.width)!;

    s
      ..noStroke()
      ..fill(color: Colors.white)
      ..circle(center: perspectiveOffset + center, diameter: diameter);
  }
}
