import 'dart:ui';

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
      home: PerlinNoisePrototype(),
    );
  }
}

class PerlinNoisePrototype extends StatefulWidget {
  @override
  _PerlinNoisePrototypeState createState() => _PerlinNoisePrototypeState();
}

class _PerlinNoisePrototypeState extends State<PerlinNoisePrototype> {
  double z = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: Sketch.simple(
            setup: (s) async {
              s.size(width: 200, height: 200);
            },
            draw: (s) async {
              await s.loadPixels();

              double x = 0;
              double y = 0;
              for (int col = 0; col < s.width; col += 1) {
                for (int row = 0; row < s.height; row += 1) {
                  // final grayAmount = s.random(0, 256).floor();

                  final perlinNoiseValue = s.noise(x: x, y: y, z: z);
                  final grayAmount = (((perlinNoiseValue + 1.0) / 2.0) * 255).round();

                  final color = Color.fromARGB(255, grayAmount, grayAmount, grayAmount);

                  s.set(x: col, y: row, color: color);

                  y += 2;
                }
                x += 2;
                y = 0;
              }

              await s.updatePixels();

              z += 5;
              // s.noLoop();
            },
          ),
        ),
      ),
    );
  }
}
