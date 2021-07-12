import 'dart:math';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaussian Noise Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GaussianNoiseDemo(),
    );
  }
}

class GaussianNoiseDemo extends StatefulWidget {
  @override
  _GaussianNoiseDemoState createState() => _GaussianNoiseDemoState();
}

class _GaussianNoiseDemoState extends State<GaussianNoiseDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: Sketch.simple(
            setup: (s) async {
              s.size(width: 200, height: 400);
            },
            draw: (s) async {
              // Draw vertical distribution.
              for (int y = 0; y < 200; y++) {
                final x = s.randomGaussian() * 30;
                s.line(Offset(100.0, y.toDouble()), Offset(100.0 + x, y.toDouble()));
              }

              // Draw radial distribution.
              final distribution = List<double>.generate(360, (int index) {
                return s.randomGaussian() * 30;
              });

              s.translate(x: s.width / 2, y: s.height * 3 / 4);

              for (int i = 0; i < distribution.length; i++) {
                s.rotate(2 * pi / distribution.length);
                s.stroke(color: Colors.black);
                final dist = distribution[i].abs();
                s.line(Offset(0, 0), Offset(dist, 0));
              }

              s.noLoop();
            },
          ),
        ),
      ),
    );
  }
}
