import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Noise Prototype',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RandomNoiseDemo(),
    );
  }
}

class RandomNoiseDemo extends StatefulWidget {
  @override
  _RandomNoiseDemoState createState() => _RandomNoiseDemoState();
}

class _RandomNoiseDemoState extends State<RandomNoiseDemo> {
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
                  final grayAmount = (s.random(1) * 0xFF).round();

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
