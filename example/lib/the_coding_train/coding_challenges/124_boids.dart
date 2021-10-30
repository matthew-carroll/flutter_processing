import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';

class CodingTrainBoidsScreen extends StatefulWidget {
  const CodingTrainBoidsScreen({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _CodingTrainBoidsScreenState createState() => _CodingTrainBoidsScreenState();
}

class _CodingTrainBoidsScreenState extends State<CodingTrainBoidsScreen> {
  @override
  Widget build(BuildContext context) {
    return ProcessingDemo(
      sketchDemoController: widget.sketchDemoController,
      createSketch: () {
        return _BoidsSketch();
      },
    );
  }
}

class _BoidsSketch extends Sketch {
  late _Flock _flock;

  @override
  Future<void> setup() async {
    size(width: 640, height: 360);

    _flock = _Flock();
    for (int i = 0; i < 150; i += 1) {
      _flock.addBoid(_Boid(
        random(width / 2),
        random(height / 2),
      ));
    }
  }

  @override
  Future<void> draw() async {
    background(color: Color.fromARGB(255, 50, 50, 50));
    _flock.update(this);
  }
}

class _Flock {
  List<_Boid> _boids = [];

  void addBoid(_Boid boid) => _boids.add(boid);

  void update(Sketch sketch) {
    for (_Boid boid in _boids) {
      boid.update(sketch, _boids);
    }
  }
}

class _Boid {
  _Boid(double x, double y) : _position = PVector(x, y) {
    _velocity = PVector.random2D();
    _acceleration = PVector(0, 0);
  }

  final _maxSpeed = 2.0;
  final _maxForce = 0.03;
  final _boidRadius = 2.0;

  PVector _position;
  late PVector _velocity;
  late PVector _acceleration;

  void _applyForce(PVector force) {
    _acceleration.add(force);
  }

  void update(Sketch sketch, List<_Boid> boids) {
    _flock(boids);
    _move();
    _borders(sketch.width, sketch.height);
    _paint(sketch);
  }

  void _flock(List<_Boid> boids) {
    final separation = _separate(boids);
    final alignment = _align(boids);
    final cohesion = _cohesion(boids);

    separation.mult(1.5);
    alignment.mult(1.0);
    cohesion.mult(1.0);

    _applyForce(separation);
    _applyForce(alignment);
    _applyForce(cohesion);
  }

  PVector _separate(List<_Boid> boids) {
    final desiredSeparation = 25.0;
    final steer = PVector(0, 0);
    int count = 0;

    // For every boid in the system, check if it's too close.
    for (_Boid other in boids) {
      if (other == this) {
        continue;
      }

      final distance = _position.dist(other._position);

      if (distance < desiredSeparation) {
        // Calculate vector pointing away from neighbor
        final normal = _position - other._position;
        normal.normalize();
        normal.div(distance);

        // Adjust steering direction
        steer.add(normal);

        count += 1;
      }
    }

    if (count > 0) {
      steer.div(count);
    }

    if (steer.mag > 0) {
      steer
        ..normalize()
        ..mult(_maxSpeed)
        ..sub(_velocity)
        ..limit(_maxForce);
    }

    return steer;
  }

  PVector _align(List<_Boid> boids) {
    final neighborDistance = 50.0;
    final sum = PVector(0, 0);
    int count = 0;

    for (_Boid other in boids) {
      if (other == this) {
        continue;
      }

      final distance = _position.dist(other._position);
      if (distance < neighborDistance) {
        sum.add(other._velocity);
        count += 1;
      }
    }

    if (count > 0) {
      sum.div(count);
      sum.mag = _maxSpeed;

      final steer = sum.copy()..sub(_velocity);
      steer.limit(_maxForce);
      return steer;
    } else {
      return PVector(0, 0);
    }
  }

  PVector _cohesion(List<_Boid> boids) {
    final neighborDistance = 50.0;
    final sum = PVector(0, 0);
    int count = 0;

    for (final other in boids) {
      if (other == this) {
        continue;
      }

      final distance = _position.dist(other._position);
      if (distance < neighborDistance) {
        sum.add(other._position);
        count += 1;
      }
    }
    if (count > 0) {
      sum.div(count);
      return _seek(sum);
    } else {
      return PVector(0, 0);
    }
  }

  /// Calculates and applies a steering force towards a target
  /// STEER = DESIRED - VELOCITY
  PVector _seek(PVector target) {
    // Pointing from position to target
    final desired = target.copy()..sub(_position);

    // Scale to maximum speed
    desired.mag = _maxSpeed;

    // Steering = Desired - Velocity
    final steer = desired.copy()..sub(_velocity);
    steer.limit(_maxForce);
    return steer;
  }

  void _move() {
    _velocity
      ..add(_acceleration)
      ..limit(_maxSpeed);

    _position.add(_velocity);

    _acceleration.mult(0);
  }

  void _borders(int width, int height) {
    if (_position.x < -_boidRadius) {
      _position.x = width + _boidRadius;
    }
    if (_position.y < -_boidRadius) {
      _position.y = height + _boidRadius;
    }
    if (_position.x > width + _boidRadius) {
      _position.x = -_boidRadius;
    }
    if (_position.y > height + _boidRadius) {
      _position.y = -_boidRadius;
    }
  }

  void _paint(Sketch s) {
    // We add (pi / 2) because the boid triangle is drawn
    // pointing down, but the direction of the zero vector
    // points to the right. Add 90 degrees to the heading
    // for the velocity vector direction to make sense as
    // a visual direction for the boid triangle.
    final directionOfMotion = _velocity.heading + (pi / 2);

    s
      ..fill(color: Color.fromARGB(255, 200, 200, 200))
      ..stroke(color: Colors.white)
      ..pushMatrix()
      ..translate(x: _position.x, y: _position.y)
      ..rotate(directionOfMotion.toDouble())
      ..beginShape(ShapeMode.triangles)
      ..vertex(0, -_boidRadius * 2)
      ..vertex(-_boidRadius, _boidRadius * 2)
      ..vertex(_boidRadius, _boidRadius * 2)
      ..endShape()
      ..popMatrix();
  }
}
