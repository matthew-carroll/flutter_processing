import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

class CirclePackingSketch extends Sketch {
  final _newCirclesPerFrame = 100;
  final _maxNewCircleAttempts = 100;

  final _circles = <Circle>[];

  @override
  void setup() {
    size(width: 800, height: 400);

    _circles.add(Circle(offset: const Offset(400, 200), radius: 1));
  }

  @override
  void draw() {
    background(color: Colors.black);

    final didFindRoom = _generateNewCircles();
    if (!didFindRoom) {
      noLoop();
    }

    final screenSize = Size(width.toDouble(), height.toDouble());
    for (final circle in _circles) {
      if (circle.isAgainstEdges(screenSize)) {
        circle.stopGrowing();
      }

      if (circle.isGrowing) {
        for (final otherCircle in _circles) {
          if (otherCircle == circle) {
            continue;
          }

          if (circle.overlaps(otherCircle)) {
            circle.stopGrowing();
          }
        }
      }

      circle
        ..grow()
        ..paint(this);
    }
  }

  /// Generates a group of new circles, if there is room to do so.
  ///
  /// Returns `true` if new circles were added, or `false` if there
  /// wasn't enough room.
  bool _generateNewCircles() {
    for (int i = 0; i < _newCirclesPerFrame; ++i) {
      late Offset randomOffset;
      bool overlapsOtherCircle = false;
      int attempts = 0;
      do {
        randomOffset = Offset(random(width), random(height));

        overlapsOtherCircle = false;
        for (final circle in _circles) {
          if (circle.contains(randomOffset)) {
            overlapsOtherCircle = true;
            break;
          }
        }

        attempts += 1;
        if (attempts >= _maxNewCircleAttempts) {
          return false;
        }
      } while (overlapsOtherCircle);

      _circles.add(Circle(
        offset: randomOffset,
        radius: 1,
      ));
    }
    return true;
  }
}

class Circle {
  Circle({
    required Offset offset,
    required double radius,
  })  : _offset = offset,
        _radius = radius;

  final Offset _offset;
  double _radius;

  bool _isGrowing = true;
  bool get isGrowing => _isGrowing;

  final double _strokeWeight = 2;

  bool isAgainstEdges(Size screenSize) {
    final boundaryRect = Rect.fromCircle(center: _offset, radius: _radius);

    return boundaryRect.left <= 0 ||
        boundaryRect.top <= 0 ||
        boundaryRect.right >= screenSize.width ||
        boundaryRect.bottom >= screenSize.height;
  }

  bool contains(Offset offset) {
    return (offset - _offset).distance <= _radius + _strokeWeight;
  }

  bool overlaps(Circle other) {
    return (other._offset - _offset).distance <= (other._radius + _radius);
  }

  void grow() {
    if (_isGrowing) {
      _radius += 0.5;
    }
  }

  void stopGrowing() {
    _isGrowing = false;
  }

  void paint(Sketch s) {
    s
      ..strokeWeight(_strokeWeight)
      ..stroke(color: Colors.white)
      ..fill(color: Colors.black)
      ..circle(center: _offset, diameter: _radius * 2);
  }
}
