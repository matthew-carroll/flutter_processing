import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_sketch_display.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phyllotaxis',
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

class _HomeScreenState extends ProcessingState<HomeScreen> {
  late Sketch _sketch;

  @override
  void initState() {
    super.initState();
    _sketch = CirclePackingSketch(this);
  }

  @override
  void reassemble() {
    super.reassemble();
    _sketch = CirclePackingSketch(this);
  }

  @override
  int get gifFps => 30;

  @override
  Duration get gifDuration => const Duration(seconds: 13);

  @override
  String get gifFilepath => '/Users/matt/Pictures/030_phyllotaxis.gif';

  @override
  Sketch createSketch() {
    return _sketch;
  }
}

class CirclePackingSketch extends Sketch {
  CirclePackingSketch(
    ProcessingState gifSaver,
  ) : _gifSaver = gifSaver;

  final ProcessingState _gifSaver;

  final dotRadius = 3;
  final dotDistanceMultiplier = 6;
  int n = 0;

  @override
  Future<void> setup() async {
    size(width: 400, height: 400);

    _gifSaver.startRecordingGif();
  }

  @override
  Future<void> draw() async {
    background(color: Colors.black);

    translate(x: width / 2, y: height / 2);

    final baseAngle = n * 0.3;
    for (int i = 0; i < n; i += 1) {
      final angle = i * (137.5 / 360) * (2 * pi) + baseAngle;
      final radius = dotDistanceMultiplier * sqrt(i);
      final x = radius * cos(angle);
      final y = radius * sin(angle);
      final hue = i / 3.0 % 360;

      fill(color: HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor());
      noStroke();
      circle(center: Offset(x, y), diameter: dotRadius * 2);
    }

    n += 5;
    n.clamp(0, 2000);

    await _gifSaver.saveGifFrameIfDesired(this);
  }
}
