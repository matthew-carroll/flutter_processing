import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perlin Noise Prototype',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PerlinNoisePrototype(),
    );
  }
}

class PerlinNoisePrototype extends StatefulWidget {
  @override
  _PerlinNoisePrototypeState createState() => _PerlinNoisePrototypeState();
}

class _PerlinNoisePrototypeState extends State<PerlinNoisePrototype> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: PerlinNoiseDemoSketch(width: 200, height: 200),
        ),
      ),
    );
  }
}

class PerlinNoiseDemoSketch extends Sketch {
  PerlinNoiseDemoSketch({
    required this.width,
    required this.height,
    this.animateZIndex = false,
  });

  final int width;
  final int height;
  final bool animateZIndex;

  double z = 0;

  @override
  Future<void> setup() async {
    size(width: width, height: height);
  }

  @override
  Future<void> draw() async {
    await loadPixels();

    noiseDetail(octaves: 8);

    final increment = 1.5;
    double x = 0;
    double y = 0;
    for (int col = 0; col < width; col += 1) {
      for (int row = 0; row < height; row += 1) {
        // final grayAmount = s.random(0, 256).floor();

        final perlinNoiseValue = noise(x: x, y: y, z: z);
        final grayAmount = (((perlinNoiseValue + 1.0) / 2.0) * 255).round();

        final color = Color.fromARGB(255, grayAmount, grayAmount, grayAmount);

        set(x: col, y: row, color: color);

        y += increment;
      }
      x += increment;
      y = 0;
    }

    await updatePixels();

    z += 5;

    if (!animateZIndex) {
      noLoop();
    }
  }
}
