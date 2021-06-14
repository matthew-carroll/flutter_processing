import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circle Packing',
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
  Sketch _sketch = MetaBallsSketch();

  @override
  void reassemble() {
    super.reassemble();
    _sketch = MetaBallsSketch();
  }

  @override
  Widget build(BuildContext context) {
    return Processing(
      sketch: _sketch,
    );
  }
}

class MetaBallsSketch extends Sketch {
  final _blobCount = 6;
  final _blobRadius = 30.0;
  final _blobSpeed = 5.0;

  final _blobs = <Blob>[];

  @override
  Future<void> setup() async {
    size(width: 400, height: 400);

    for (int i = 0; i < _blobCount; i += 1) {
      _blobs.add(
        Blob(
          offset: Offset(random(width), random(height)),
          velocity: Offset.fromDirection(random(2 * pi), _blobSpeed),
          radius: _blobRadius,
        ),
      );
    }
  }

  @override
  Future<void> draw() async {
    background(color: Colors.black);

    await loadPixels();

    for (int col = 0; col < width; col += 1) {
      for (int row = 0; row < height; row += 1) {
        double sum = 0;
        for (final blob in _blobs) {
          final distance = (Offset(col.toDouble(), row.toDouble()) - blob.offset).distance;

          // Add to brightness
          sum += 0.75 * blob._radius / distance;

          // Colors
          // sum += 50 * blob.radius / distance;
        }

        // Brightness
        set(x: col, y: row, color: HSVColor.fromAHSV(1.0, 0.0, 0.0, sum.clamp(0.0, 1.0)).toColor());

        // Colors
        // set(x: col, y: row, color: HSVColor.fromAHSV(1.0, sum % 360, 1.0, 1.0).toColor());
      }
    }

    await updatePixels();

    final screenSize = Size(width.toDouble(), height.toDouble());
    for (final blob in _blobs) {
      blob.move(screenSize);
      // blob.paint(this);
    }
  }
}

class Blob {
  Blob({
    required Offset offset,
    required Offset velocity,
    required double radius,
  })  : _offset = offset,
        _velocity = velocity,
        _radius = radius;

  Offset _offset;
  Offset get offset => _offset;

  Offset _velocity;

  double _radius;
  double get radius => _radius;

  void move(Size screenSize) {
    if (_offset.dx <= 0 || _offset.dx >= screenSize.width) {
      _velocity = Offset(-_velocity.dx, _velocity.dy);
    }
    if (_offset.dy <= 0 || _offset.dy >= screenSize.height) {
      _velocity = Offset(_velocity.dx, -_velocity.dy);
    }

    _offset += _velocity;
  }

  void paint(Sketch s) {
    s
      ..strokeWeight(2)
      ..stroke(color: Colors.white)
      ..noFill()
      ..circle(center: _offset, diameter: _radius * 2);
  }
}
