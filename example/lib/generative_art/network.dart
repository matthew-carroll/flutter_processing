import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

class NetworkSketch extends Sketch {
  static const _nodeCount = 75;
  static const _maxSpeed = 0.75;
  static const _minDiameter = 10;
  static const _maxDiameter = 50;
  static const _maxEdgeLength = 200;
  static const _maxEdgeWidth = 5;
  static const _nodeColor = Colors.purpleAccent;
  static final _edgeColor = Colors.deepPurple.withOpacity(0.2);

  final _nodes = <_Node>[];

  @override
  void setup() {
    size(width: 1000, height: 800);

    for (int i = 0; i < _nodeCount; i += 1) {
      _nodes.add(_Node(
        position: PVector(
          random(0, width),
          random(0, height),
        ),
        velocity: PVector.random2D() * _maxSpeed,
        diameter: random(_minDiameter, _maxDiameter),
      ));
    }
  }

  @override
  void draw() {
    background(color: const Color(0xFF333333));

    stroke(color: _edgeColor);
    for (final node1 in _nodes) {
      for (final node2 in _nodes) {
        final distance = node1.position.dist(node2.position);
        if (distance < _maxEdgeLength) {
          final edgeThickness = map(distance, 0, _maxEdgeLength, _maxEdgeWidth, 0).toDouble();
          strokeWeight(edgeThickness);
          line(node1.position.toOffset(), node2.position.toOffset());
        }
      }
    }

    noStroke();
    for (final node in _nodes) {
      fill(
          color: HSVColor.fromColor(_nodeColor)
              .withValue(
                map(node.diameter, _minDiameter, _maxDiameter, 0.9, 0.5).toDouble(),
              )
              .toColor());
      circle(center: node.position.toOffset(), diameter: node.diameter);

      node.move();
      if (node.left > width) {
        node.position = PVector(-node.diameter / 2, node.position.y);
      }
      if (node.right < 0) {
        node.position = PVector(width + (node.diameter / 2), node.position.y);
      }
      if (node.top > height) {
        node.position = PVector(node.position.x, -node.diameter / 2);
      }
      if (node.bottom < 0) {
        node.position = PVector(node.position.x, height + (node.diameter / 2));
      }
    }
  }
}

class _Node {
  _Node({
    required this.position,
    required PVector velocity,
    required this.diameter,
  }) : _velocity = velocity;

  PVector position;

  double get left => position.x - (diameter / 2);
  double get right => position.x + (diameter / 2);
  double get top => position.y - (diameter / 2);
  double get bottom => position.y + (diameter / 2);

  final PVector _velocity;

  final double diameter;

  void move() {
    position += _velocity;
  }
}
