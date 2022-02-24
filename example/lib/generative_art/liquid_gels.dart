import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

/// Adapted from: https://openprocessing.org/sketch/816453
class LiquidGelsSketch extends Sketch {
  @override
  void setup() {
    size(width: 800, height: 800);
  }

  @override
  void draw() {
    // TODO: implement blending
    // blendMode(BLEND);
    background(color: Color.fromARGB(255, 245, 245, 245));
    // blendMode(MULTIPLY);
    noStroke();
    translate(x: width / 2, y: height / 2);

    fill(color: Color.fromARGB(255, 0, 150, 240));
    drawGel(18, 50, 20, 100);

    fill(color: Color.fromARGB(255, 240, 240, 0));
    drawGel(15, 60, 25, 120);

    fill(color: Color.fromARGB(255, 240, 0, 240));
    drawGel(12, 45, 15, 150);
  }

  void drawGel(int vNnum, int nm, int sm, int fcm) {
    pushMatrix();
    rotate(frameCount / fcm);
    final dr = TWO_PI / vNnum;
    beginShape();
    for (int i = 0; i < vNnum + 3; i++) {
      final ind = i % vNnum;
      final rad = dr * ind;
      final r =
          height * 0.3 + noise(x: frameCount / nm + ind) * height * 0.1 + sin(frameCount / sm + ind) * height * 0.05;
      // TODO: implement curve vertex
      // curveVertex(cos(rad) * r, sin(rad) * r);
    }
    endShape();
    popMatrix();
  }
}
