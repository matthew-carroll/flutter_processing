import 'dart:math';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:fast_noise/fast_noise.dart';

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
      home: PerlinNoiseDemo(),
    );
  }
}

class PerlinNoiseDemo extends StatefulWidget {
  @override
  _PerlinNoiseDemoState createState() => _PerlinNoiseDemoState();
}

class _PerlinNoiseDemoState extends State<PerlinNoiseDemo> {
  final perlinNoise = PerlinNoise(
    octaves: 4,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: Sketch.simple(
            setup: (s) async {
              s.size(width: 250, height: 250);
            },
            draw: (s) async {
              await s.loadPixels();

              for (int col = 0; col < s.width; ++col) {
                for (int row = 0; row < s.height; ++row) {
                  final widthPercent = col / s.width;
                  final heightPercent = row / s.height;

                  final perlinValue = perlinNoise.getPerlin3(
                    widthPercent * 1000,
                    heightPercent * 1000,
                    s.frameCount.toDouble(),
                  );

                  final grayAmount = (perlinValue * 0xFF).round();
                  // final grayAmount = (s.random(1) * 0xFF).round();

                  final pixelColor = Color.fromARGB(0xFF, grayAmount, grayAmount, grayAmount);

                  s.set(
                    x: col,
                    y: row,
                    color: pixelColor,
                  );
                }
              }

              await s.updatePixels();
            },
          ),
        ),
      ),
    );
  }
}
