import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

/// Adapted from: https://openprocessing.org/sketch/394718
class SolarStormSketch extends Sketch {
  static const particleCount = 1000;
  final vx = List<double>.filled(particleCount, 0.0);
  final vy = List<double>.filled(particleCount, 0.0);
  final x = List<double>.filled(particleCount, 0.0);
  final y = List<double>.filled(particleCount, 0.0);
  final ax = List<double>.filled(particleCount, 0.0);
  final ay = List<double>.filled(particleCount, 0.0);

  final magnetism = 10.0;
  final radius = 1;
  final gensoku = 0.95;

  @override
  void setup() {
    size(width: 1200, height: 800);

    noStroke();
    // fill(color: Colors.black);
    // ellipseMode(RADIUS);
    background(color: Colors.black);
    // TODO: implement blend mode
    // blendMode(ADD);

    for (var i = 0; i < particleCount; i++) {
      x[i] = random(width);
      y[i] = random(height);
      vx[i] = 0;
      vy[i] = 0;
      ax[i] = 0;
      ay[i] = 0;
    }
  }

  @override
  Future<void> draw() async {
    await loadPixels();
    for (var i = 0; i < particleCount; i++) {
      var distance = dist(
        Offset(mouseX.toDouble(), mouseY.toDouble()),
        Offset(x[i], y[i]),
      );
      if (distance > 3) {
        ax[i] = magnetism * (mouseX - x[i]) / (distance * distance);
        ay[i] = magnetism * (mouseY - y[i]) / (distance * distance);
      }
      vx[i] += ax[i];
      vy[i] += ay[i];

      vx[i] = vx[i] * gensoku;
      vy[i] = vy[i] * gensoku;

      x[i] += vx[i];
      y[i] += vy[i];

      var sokudo = dist(Offset(0, 0), Offset(vx[i], vy[i]));
      var r = map(sokudo, 0, 5, 0, 255).toInt();
      var g = map(sokudo, 0, 5, 64, 255).toInt();
      var b = map(sokudo, 0, 5, 128, 255).toInt();
      // TODO: for some reason, the circles are filling with black,
      //       even when requesting Colors.red.
      // fill(color: Color.fromARGB(32, r, g, b));
      // fill(color: Colors.red);
      // circle(center: Offset(x[i], y[i]), diameter: 2.0 * radius);
      if (x[i] >= 0 && x[i] < width && y[i] >= 0 && y[i] < height) {
        set(x: x[i].floor(), y: y[i].floor(), color: Color.fromARGB(32, r, g, b));
      }
    }
    await updatePixels();
  }
}
