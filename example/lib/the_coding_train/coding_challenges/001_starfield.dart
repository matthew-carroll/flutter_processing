import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Processing Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _stars = <Star>[];

  @override
  void reassemble() {
    super.reassemble();
    _stars.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: Sketch.simple(
            setup: (s) {
              s
                ..size(width: 1600, height: 900)
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
            draw: (s) {
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
          ),
        ),
      ),
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
    final diameter = lerpDouble(12, 0, z / s.width)!;

    s
      ..noStroke()
      ..fill(color: Colors.white)
      ..circle(center: perspectiveOffset + center, diameter: diameter);
  }
}
