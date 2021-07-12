import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perlin Noise Demo',
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

              s.noiseDetail(octaves: 24);

              double yOff = 0.0;
              for (int row = 0; row < s.height; ++row) {
                double xOff = 0.0;
                for (int col = 0; col < s.width; ++col) {
                  final perlinValue = (s.noise(x: xOff, y: yOff, z: z) + 1) / 2;

                  final grayAmount = (perlinValue * 0xFF).round();

                  final pixelColor = Color.fromARGB(0xFF, grayAmount, grayAmount, grayAmount);

                  s.set(
                    x: col,
                    y: row,
                    color: pixelColor,
                  );

                  xOff += 5;
                }
                yOff += 5;
              }

              await s.updatePixels();

              z += 10;
            },
          ),
        ),
      ),
    );
  }
}
