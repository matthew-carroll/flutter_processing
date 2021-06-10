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
      title: 'Metaballs',
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
  Duration get gifDuration => const Duration(seconds: 10);

  @override
  String get gifFilepath => '/Users/matt/Pictures/028_metaballs.gif';

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

  final _blobCount = 6;
  final _blobRadius = 20.0;
  final _blobSpeed = 5.0;

  final _blobs = <Blob>[];

  @override
  Future<void> setup() async {
    size(width: 400, height: 400);

    for (int i = 0; i < _blobCount; i += 1) {
      _blobs.add(
        Blob(
          offset: Offset(random(width), random(height)),
          radius: _blobRadius,
          velocity: Offset.fromDirection(random(2 * pi), _blobSpeed),
        ),
      );
    }

    _gifSaver.startRecordingGif();
  }

  @override
  Future<void> draw() async {
    background(color: Colors.black);

    await loadPixels();

    for (int col = 0; col < width; col += 1) {
      for (int row = 0; row < height; row += 1) {
        double sum = 0;
        for (final blob in _blobs) {
          double distance = (Offset(col.toDouble(), row.toDouble()) - blob.offset).distance;

          // Brightness
          sum += 0.75 * blob.radius / distance;

          // Lots of colors
          // sum += 100 * blob.radius / distance;
        }

        // Brightness
        set(x: col, y: row, color: HSVColor.fromAHSV(1.0, 0, 0.0, sum.clamp(0.0, 1.0)).toColor());

        // Lots of colors
        // set(x: col, y: row, color: HSVColor.fromAHSV(1.0, sum % 360, 1.0, 1.0).toColor());
      }
    }

    await updatePixels();

    for (final circle in _blobs) {
      // Move and paint the circle.
      circle..move(Size(width.toDouble(), height.toDouble()));
      // ..paint(this);
    }

    await _gifSaver.saveGifFrameIfDesired(this);
  }
}

class Blob {
  Blob({
    required Offset offset,
    required double radius,
    required Offset velocity,
  })  : _offset = offset,
        _radius = radius,
        _velocity = velocity;

  Offset _offset;
  Offset get offset => _offset;

  double _radius;
  double get radius => _radius;

  Offset _velocity;

  void move(Size screenBoundary) {
    final didBounce = _bounceOffEdge(screenBoundary);

    if (!didBounce) {
      _offset += _velocity;
    }
  }

  bool _bounceOffEdge(Size screenBoundary) {
    final screenRect = Offset.zero & screenBoundary;
    final boundaryRect = Rect.fromCircle(center: _offset, radius: _radius);

    bool didBounce = false;
    if (boundaryRect.left < screenRect.left && _velocity.dx < 0) {
      _velocity = Offset(-_velocity.dx, _velocity.dy);
      didBounce = true;
    }
    if (boundaryRect.right > screenRect.right && _velocity.dx > 0) {
      _velocity = Offset(-_velocity.dx, _velocity.dy);
      didBounce = true;
    }
    if (boundaryRect.top < screenRect.top && _velocity.dy < 0) {
      _velocity = Offset(_velocity.dx, -_velocity.dy);
      didBounce = true;
    }
    if (boundaryRect.bottom > screenRect.bottom && _velocity.dy > 0) {
      _velocity = Offset(_velocity.dx, -_velocity.dy);
      didBounce = true;
    }
    return didBounce;
  }

  void paint(Sketch s) {
    s
      ..stroke(color: Colors.white)
      ..strokeWeight(2)
      ..noFill()
      ..circle(center: _offset, diameter: 2 * _radius);
  }
}
