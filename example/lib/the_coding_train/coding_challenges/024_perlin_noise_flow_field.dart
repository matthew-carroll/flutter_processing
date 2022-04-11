import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

class PerlinNoiseFlowFieldSketch extends Sketch {
  static const _pixelsPerFlowGrid = 10;
  static const _particleCount = 10000;

  late List<List<PVector>> _flowField;
  late List<_Particle> _particles;

  @override
  void setup() {
    size(width: 1000, height: 800);

    final cols = (width / _pixelsPerFlowGrid).round();
    final rows = (height / _pixelsPerFlowGrid).round();

    _flowField = List<List<PVector>>.generate(
      cols,
      (_) => List<PVector>.filled(
        rows,
        PVector(0, 0),
      ),
    );
    for (int y = 0; y < rows; y += 1) {
      for (int x = 0; x < cols; x += 1) {
        final flowFieldVector = PVector.fromAngle(
          // Change the "z" value to get a different flow field pattern.
          noise(x: x * 3.0, y: y * 3.0, z: 1000) * pi,
        );

        _flowField[x][y] = flowFieldVector;
      }
    }

    _particles = <_Particle>[];
    for (int i = 0; i < _particleCount; i += 1) {
      _particles.add(
        _Particle(
          position: PVector(random(0, width), random(0, height)),
          velocity: PVector.fromAngle(random(0, TWO_PI) * 5),
          maxSpeed: 5,
        ),
      );
    }

    background(color: Colors.deepPurple);
  }

  @override
  void draw() {
    // This paints the flow field perlin noise gradient, and also paints
    // little lines showing the flow direction throughout the grid.
    // for (int x = 0; x < _flowField.length; x += 1) {
    //   for (int y = 0; y < _flowField[x].length; y += 1) {
    //     noStroke();
    //     fill(color: HSVColor.fromAHSV(1.0, 0.0, 0.0, (_flowField[x][y].heading + PI) / TWO_PI).toColor());
    //     rect(
    //         rect: Rect.fromLTWH(x * _pixelsPerFlowGrid.toDouble(), y * _pixelsPerFlowGrid.toDouble(),
    //             _pixelsPerFlowGrid.toDouble(), _pixelsPerFlowGrid.toDouble()));
    //
    //     stroke(color: Colors.black);
    //     strokeWeight(1);
    //     pushMatrix();
    //     translate(x: x * _pixelsPerFlowGrid.toDouble(), y: y * _pixelsPerFlowGrid.toDouble());
    //     rotate(_flowField[x][y].heading.toDouble());
    //     line(Offset(0, 0), Offset(_pixelsPerFlowGrid.toDouble(), 0));
    //     popMatrix();
    //   }
    // }

    for (final particle in _particles) {
      final flowFieldX = (particle.position.x.clamp(0, width - 1) / _pixelsPerFlowGrid).floor();
      final flowFieldY = (particle.position.y.clamp(0, height - 1) / _pixelsPerFlowGrid).floor();
      particle.applyForce(_flowField[flowFieldX][flowFieldY]);
      particle.move();

      // Draw a line between the particles previous position and
      // current position.
      stroke(color: Colors.purpleAccent.withOpacity(0.1));
      // This stroke interprets the flow field under the particle as a color.
      // stroke(
      //     color: HSVColor.fromAHSV(1.0, 360 * (_flowField[flowFieldX][flowFieldY].heading + PI) / TWO_PI, 1.0, 1.0)
      //         .toColor()
      //         .withOpacity(0.1));
      strokeWeight(2);
      line(particle.previousPosition.toOffset(), particle.position.toOffset());

      // This draws a circle for each particle. It might be useful to see
      // each particle, but it's unnecessary for rendering because we're
      // already drawing a line for the particles motion.
      // noStroke();
      // fill(color: Color(0xFF444444).withOpacity(0.1));
      // circle(center: particle.position.toOffset(), diameter: 2);

      // If the particle moved off-screen, move it back on.
      if (particle.left >= width) {
        particle.position = PVector(0, particle.position.y);
        particle.previousPosition = particle.position;
      }
      if (particle.right <= 0) {
        particle.position = PVector(width, particle.position.y);
        particle.previousPosition = particle.position;
      }
      if (particle.top >= height) {
        particle.position = PVector(particle.position.x, 0);
        particle.previousPosition = particle.position;
      }
      if (particle.bottom <= 0) {
        particle.position = PVector(particle.position.x, height);
        particle.previousPosition = particle.position;
      }
    }
  }
}

class _Particle {
  _Particle({
    required this.position,
    required PVector velocity,
    double maxSpeed = 5.0,
    PVector? acceleration,
  })  : previousPosition = position,
        _velocity = velocity,
        _maxSpeed = maxSpeed,
        _acceleration = acceleration ?? PVector(0, 0);

  PVector position;
  PVector previousPosition;

  double get left => position.x - 1;
  double get right => position.x + 1;
  double get top => position.y - 1;
  double get bottom => position.y + 1;

  PVector _velocity;
  final double _maxSpeed;

  PVector _acceleration;

  void move() {
    previousPosition = position;

    _velocity += _acceleration;
    _velocity.limit(_maxSpeed);
    position += _velocity;
    _acceleration.mult(0);
  }

  void applyForce(PVector force) {
    _acceleration += force;
  }
}
