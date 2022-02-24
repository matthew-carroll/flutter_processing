import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

/// Adapted from: https://openprocessing.org/sketch/394718
class SolarStormSketch extends Sketch {
  static const _particleCount = 1000;

  final _magnetism = 10.0;
  final _radius = 1;
  final _friction = 0.05;

  final _particles = <_Particle>[];

  @override
  void setup() {
    size(width: 1200, height: 800);

    background(color: Colors.black);

    for (var i = 0; i < _particleCount; i++) {
      _particles.add(
        _Particle(position: PVector(random(width), random(height))),
      );
    }
  }

  @override
  Future<void> draw() async {
    noStroke();
    blendMode = BlendMode.plus;

    for (var i = 0; i < _particles.length; i++) {
      final particle = _particles[i];

      final distanceToMouse = dist(
        Offset(mouseX.toDouble(), mouseY.toDouble()),
        particle.position.toOffset(),
      );

      if (distanceToMouse > 3) {
        particle.acceleration = PVector(
          _magnetism * (mouseX - particle.position.x) / (distanceToMouse * distanceToMouse),
          _magnetism * (mouseY - particle.position.y) / (distanceToMouse * distanceToMouse),
        );
      }

      particle
        ..applyAcceleration()
        ..applyFrictionPercent(_friction)
        ..move();

      var speed = particle.velocity.mag;
      var r = map(speed, 0, 5, 0, 255).toInt();
      var g = map(speed, 0, 5, 64, 255).toInt();
      var b = map(speed, 0, 5, 128, 255).toInt();
      fill(color: Color.fromARGB(32, r, g, b));

      if (particle.isInWindow(width, height)) {
        circle(center: particle.position.toOffset(), diameter: 2.0 * _radius);
      }
    }
  }
}

class _Particle {
  _Particle({
    required this.position,
  })  : velocity = PVector(0, 0),
        acceleration = PVector(0, 0);

  PVector position;
  PVector velocity;
  PVector acceleration;

  void move() {
    position = position + velocity;
  }

  void applyAcceleration() {
    velocity = velocity + acceleration;
  }

  void applyFrictionPercent(double percent) {
    velocity = velocity * (1.0 - percent);
  }

  bool isInWindow(num width, num height) {
    return position.x >= 0 && position.x < width && position.y >= 0 && position.y < height;
  }
}
