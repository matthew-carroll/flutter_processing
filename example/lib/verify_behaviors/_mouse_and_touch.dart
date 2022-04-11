import 'package:flutter_processing/flutter_processing.dart';

class MouseAndTouchSketch extends Sketch {
  MouseAndTouchSketch({
    required this.width,
    required this.height,
  });

  @override
  final int width;
  @override
  final int height;

  @override
  void setup() {
    size(width: width, height: height);
  }

  @override
  void draw() {
    //
  }

  @override
  void mousePressed() {
    print("Mouse pressed: ($mouseX, $mouseY)");
  }

  @override
  void mouseDragged() {
    print("Mouse dragged: ($mouseX, $mouseY)");
  }

  @override
  void mouseReleased() {
    print("Mouse released: ($mouseX, $mouseY)");
  }

  @override
  void mouseClicked() {
    print("Mouse clicked: ($mouseX, $mouseY)");
  }

  @override
  void mouseMoved() {
    print("Mouse moved: ($mouseX, $mouseY)");
  }

  @override
  void mouseWheel(double count) {
    print("Mouse wheel: $count");
  }
}
