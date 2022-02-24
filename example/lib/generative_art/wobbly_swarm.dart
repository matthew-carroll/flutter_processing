import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

/// Adapted from: https://openprocessing.org/sketch/492096
class WobblySwarmSketch extends Sketch {
  final mass = <double>[];
  final positionX = <double>[];
  final positionY = <double>[];
  final velocityX = <double>[];
  final velocityY = <double>[];

  @override
  void setup() {
    size(width: 1200, height: 800);
  }

  @override
  void draw() {
    background(color: Color.fromARGB(255, 32, 32, 32));

    noStroke();
    fill(color: Color.fromARGB(192, 255, 255, 64));

    for (var particleA = 0; particleA < mass.length; particleA++) {
      double accelerationX = 0;
      double accelerationY = 0;

      for (var particleB = 0; particleB < mass.length; particleB++) {
        if (particleA != particleB) {
          var distanceX = positionX[particleB] - positionX[particleA];
          var distanceY = positionY[particleB] - positionY[particleA];

          var distance = sqrt(distanceX * distanceX + distanceY * distanceY);
          if (distance < 1) distance = 1;

          var force = (distance - 320) * mass[particleB] / distance;
          accelerationX += force * distanceX;
          accelerationY += force * distanceY;
        }
      }

      velocityX[particleA] = velocityX[particleA] * 0.99 + accelerationX * mass[particleA];
      velocityY[particleA] = velocityY[particleA] * 0.99 + accelerationY * mass[particleA];
    }

    for (var particle = 0; particle < mass.length; particle++) {
      positionX[particle] += velocityX[particle];
      positionY[particle] += velocityY[particle];

      circle(center: Offset(positionX[particle], positionY[particle]), diameter: 2.0 * mass[particle] * 1000);
    }
  }

  @override
  void mouseClicked() {
    addNewParticle();
  }

  @override
  void mouseDragged() {
    addNewParticle();
  }

  void addNewParticle() {
    mass.add(random(0.003, 0.03));
    positionX.add(mouseX.toDouble());
    positionY.add(mouseY.toDouble());
    velocityX.add(0);
    velocityY.add(0);
  }
}
