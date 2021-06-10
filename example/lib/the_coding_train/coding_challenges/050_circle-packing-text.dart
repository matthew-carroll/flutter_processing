import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_sketch_display.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Circle Packing Text',
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
  String get gifFilepath => '/Users/matt/Pictures/050_circle-packing-text.gif';

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

  final _newCirclesPerFrame = 5;
  final _maxNewCircleAttempts = 100;

  final _whitePixels = <Pixel>[];
  final _circles = <Circle>[];

  late Image _textImage;

  bool _isDoneGeneratingCircles = false;

  @override
  Future<void> setup() async {
    size(width: 800, height: 400);

    _textImage = await loadImage('assets/coding-train/flutter-text.png');

    final imageBytes = (await _textImage.toByteData()) as ByteData;
    for (int col = 0; col < _textImage.width; col += 1) {
      for (int row = 0; row < _textImage.height; row += 1) {
        final pixelOffset = ((row * _textImage.width) + col) * 4;
        final rgbaColor = imageBytes.getUint32(pixelOffset);
        final argbColor = ((rgbaColor & 0x000000FF) << 24) | ((rgbaColor & 0xFFFFFF00) >> 8);

        if (argbColor == 0xFFFFFFFF) {
          _whitePixels.add(Pixel(col, row));
        }
      }
    }

    _gifSaver.startRecordingGif();
  }

  @override
  Future<void> draw() async {
    background(color: Colors.black);
    // image(
    //   image: _textImage,
    // );

    _generateNewCircles();

    for (final circle in _circles) {
      // Prevent the circle from expanding beyond the canvas.
      if (circle.isAgainstEdges(Size(width.toDouble(), height.toDouble()))) {
        circle.stopGrowing();
      }

      // Prevent the circle from expanding into another circle.
      if (circle.isGrowing) {
        for (final otherCircle in _circles) {
          if (circle == otherCircle) {
            continue;
          }

          if (circle.overlaps(otherCircle)) {
            circle.stopGrowing();
            otherCircle.stopGrowing();
          }
        }
      }

      // Grow and paint the circle.
      circle
        ..grow()
        ..paint(this);
    }

    await _gifSaver.saveGifFrameIfDesired(this);
    if (_isDoneGeneratingCircles) {
      await _gifSaver.saveGifToFile();
    }
  }

  void _generateNewCircles() {
    for (int i = 0; i < _newCirclesPerFrame; ++i) {
      late Offset randomOffset;
      bool overlapsOtherCircle = false;
      int attempts = 0;
      do {
        randomOffset = _whitePixels[random(_whitePixels.length).floor()].toOffset();

        overlapsOtherCircle = false;
        for (final circle in _circles) {
          if (circle.contains(randomOffset)) {
            overlapsOtherCircle = true;
            break;
          }
        }

        attempts += 1;
        if (attempts >= _maxNewCircleAttempts) {
          noLoop();
          _isDoneGeneratingCircles = true;
          print('FILLED ALL SPACE');
          return;
        }
      } while (overlapsOtherCircle);

      _circles.add(Circle(
        offset: randomOffset,
        radius: 1,
      ));
    }
  }
}

class Pixel {
  const Pixel(this.x, this.y);

  final int x;
  final int y;

  Offset toOffset() => Offset(x.toDouble(), y.toDouble());
}

class Circle {
  Circle({
    required Offset offset,
    required double radius,
  })  : _offset = offset,
        _radius = radius;

  Offset _offset;
  double _radius;
  final _growSpeed = 0.5;
  final _strokeWeight = 2.0;

  bool _isGrowing = true;
  bool get isGrowing => _isGrowing;

  bool isAgainstEdges(Size screenBoundary) {
    final screenRect = Offset.zero & screenBoundary;
    final boundaryRect = Rect.fromCircle(center: _offset, radius: _radius);

    return (boundaryRect.left <= screenRect.left ||
        boundaryRect.top <= screenRect.top ||
        boundaryRect.right >= screenRect.right ||
        boundaryRect.bottom >= screenRect.bottom);
  }

  bool contains(Offset offset) {
    return (offset - _offset).distance <= _radius + _strokeWeight;
  }

  bool overlaps(Circle other) {
    return (other._offset - _offset).distance <= (other._radius + _radius);
  }

  void grow() {
    if (_isGrowing) {
      _radius += _growSpeed;
    }
  }

  void stopGrowing() {
    _isGrowing = false;
  }

  void paint(Sketch s) {
    s
      ..stroke(color: Colors.white)
      ..strokeWeight(2)
      ..fill(color: Colors.black)
      ..circle(center: _offset, diameter: 2 * _radius);
  }
}
